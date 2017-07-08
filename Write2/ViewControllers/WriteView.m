//
//  WriteView.m
//  Write
//
//  Created by zhangjb on 13-5-8.
//  Copyright (c) 2013年 zhangjb. All rights reserved.
//

#import "WriteView.h"
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CALayer.h>


//笔画方向
typedef enum
{
    kBrushOrientation0 = 0,
    kBrushOrientation45 = 45,
    kBrushOrientation90 = 90,
    kBrushOrientation135 = 135,
    kBrushOrientation180 = 180,
    kBrushOrientation225 = 225,
    kBrushOrientation270 = 270,
    kBrushOrientation315 = 315
    
    
}kBrushOrientation;


@interface WriteView()
{
@private
    
    //上次的记录坐标
    CGPoint lastPoint;
    
    //上次的记录时间
    NSDate* lastTime;
    
    //上次的瞬间速度
    float lastSpeed;
    
    //当前笔刷
    UIImage* baseBrush;
    
    //当前笔画方向
    kBrushOrientation orientation;
    
    //笔刷池
    NSMutableDictionary* brushPool;
    
    
    //移动到本次的画笔宽度
    float curBrushWidth;
    
    //上次move的画笔宽度
    float lastBrushWidth;
    
    
    
}

@end


@implementation WriteView
@synthesize wordArrange;
@synthesize wordSize;
@synthesize startPoint;
@synthesize bgName;
@synthesize pageWidth;
@synthesize wordBlank;
@synthesize lineBlank;
@synthesize percent;
@synthesize remainTime;
@synthesize wordMode;
@synthesize animateTime;
@synthesize wordPoint;
@synthesize outPannelView;
@synthesize pageHeight;
@synthesize linenum;
@synthesize parentCtr;

#pragma mark 工具类方法
//根据名字获取图片，不采用Imagenamewithe ，存在缓存泄漏
- (UIImage*) getImageWithFilename:(NSString*)filename

{
    int t = [filename rangeOfString:@"."].location;
    NSString* pngName = [filename substringToIndex:t];
    
    return [UIImage imageNamed:pngName];
//    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:NULL];
//    
//    return  [UIImage imageWithContentsOfFile:path];
    
}

//根据不同方向获取笔刷图片名字,根据书法模式
- (NSString*)getBrushFilename
{
    NSString* name = [NSString stringWithFormat:@"brush_%d_%d.png",wordMode,orientation];
    
    
    
    return name;
    
}

//图片的等比例缩放
- (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize

{
    //图片的等比例缩放
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return  scaledImage;
    
}

//根据缩放比例获取笔刷，具备缓存功能
- (UIImage*)getImageWithSize:(int)size
{
    
    NSString* key = [NSString stringWithFormat:@"%d-%d-%d",wordMode, orientation,size];
    
    UIImage* image = [brushPool valueForKey:key];
    
    
    
    //动态加载2级笔刷
    if(image == nil)
    {
        
        NSString* basekey = [NSString stringWithFormat:@"%d-%d",wordMode, orientation];
        UIImage* baseImage = [brushPool valueForKey:basekey];
        
        if(baseImage == nil)
        {
            
            //动态加载一级笔刷
            baseImage = [self getImageWithFilename:[self getBrushFilename]];
            
            [brushPool setValue:baseImage forKey:basekey];
            
        }
        
        //缩放的倍数
        float scale =  size/baseImage.size.width;
        
        image = [self scaleImage:baseImage toScale:scale];
        [brushPool setValue:image forKey:key];
        
    }
    
    return image;
    
}


#pragma mark 初始化 相关

+ (id)sharedWriteViewWith:(CGRect)frame
{
    static WriteView* shareWriteInstance = nil;
    
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareWriteInstance = [[self alloc]initWithFrame:frame];
    });
    
    
    return shareWriteInstance;
}

-(void)setRemainTime:(float)_remainTime
{
    UIView* btn = [self viewWithTag:TAGBTNOK];
    if(_remainTime>0)
    {
        btn.hidden = YES;
    }
    else
    {
        btn.hidden = NO;
    }
    
    remainTime = _remainTime;
    
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.userInteractionEnabled = YES;
        
        //笔刷池
        brushPool = [[NSMutableDictionary alloc]init];
        
        UIButton* btn  = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 40)];
        //btn.backgroundColor = [UIColor redColor];
        btn.tag = TAGBTNOK;
        
        [btn setImage:[self getImageWithFilename:@"button-normail-ok.png"] forState:UIControlStateNormal];
        //[btn setTitle:@"OK" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(saveWrite:) forControlEvents:UIControlEventTouchUpInside];
        btn.alpha = 0.7;
        [self addSubview:btn];
        
        
        
        
        
        
        
        //默认赋值
        self.wordSize = CGSizeMake(40, 50);
        self.startPoint = CGPointMake(0, 0);
        self.wordArrange = kWordHorizontal;
        self.wordBlank = 2;
        self.lineBlank = 3;
        self.pageWidth = 300;
        self.percent = 1;
        self.remainTime = 1;
        self.wordMode = kWordNormal;
        self.animateTime = 1.0;
        self.linenum = 5;
        
        self.layer.cornerRadius = 15;
        //self.layer.cornerRadius ＝ 8;
        
        self.layer.masksToBounds = YES;
        
    }
    
    
    return self;
}


- (void)setStartPoint:(CGPoint)_startPoint
{
    startPoint = _startPoint;
    
    wordPoint = startPoint;
    
}

-(void)setBgName:(NSString *)_bgName
{
//    [bgName release];
    bgName = _bgName;
    
    if(bgName != nil)
    {
        
        UIImage* bgImage = [self getImageWithFilename:_bgName];
        
        self.backgroundColor = [UIColor colorWithPatternImage:  bgImage];
        
    }
    else
        self.backgroundColor = [UIColor clearColor];
}



#pragma mark 相关交互和逻辑

- (void)setNextWordPoint
{
    
    int nextX = wordPoint.x;
    int nextY = wordPoint.y;
    
    //水平书写的情况下
    if(wordArrange == kWordHorizontal)
    {
        
        nextX = wordPoint.x + wordBlank +wordSize.width;
        
        //超出边界
        if(nextX > startPoint.x+ pageWidth-wordSize.width-wordBlank)
        {
            nextX = startPoint.x;
            
            nextY = wordPoint.y + lineBlank + wordSize.height;
        }
        
        
    }
    
    //水平逆书的情况下
    else if (wordArrange == kWordHorizontalReverse)
    {
        nextX = wordPoint.x - wordBlank - wordSize.width;
        
        //超过左边界
        
        if (nextX < startPoint.x +wordSize.width - pageWidth)
        {
            
            nextX = startPoint.x;
            
            nextY = wordPoint.y +lineBlank + wordSize.height;
        }
    }
    //竖直书写的情况下,从右向左
    
    else if (wordArrange == kWordVertical)
    {
        nextY = wordPoint.y +lineBlank + wordSize.height;
        
        
        if (nextY > startPoint.y + pageHeight - wordSize.height - lineBlank)
        {
            nextX = wordPoint.x - wordSize.width - wordBlank;
            nextY = startPoint.y;
        }
    }
    //竖直书写的情况下,从左向右
    else if (wordArrange == kWordVerticalReverse)
    {
        nextY = wordPoint.y +lineBlank + wordSize.height;
        
        
        if (nextY > startPoint.y + pageHeight - wordSize.height - lineBlank)
        {
            nextX = wordPoint.x + wordSize.width + wordBlank;
            nextY = startPoint.y;
        }
    }
    
    
    
    
    wordPoint = CGPointMake(nextX, nextY);
    
    
}

-(void)insertBlank
{
    
    //设置下一个写入位置
    [self setNextWordPoint];
    
    NSDictionary* cursorDic = [NSDictionary dictionaryWithObjectsAndKeys:@(wordPoint.x),NOTICURSORX,@(wordPoint.y),NOTICURSORY, nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICURSOR object:self userInfo:cursorDic];
}

-(void)saveWrite:(id)sender
{
    //隐藏按钮和背景
    UIView* btn = [self viewWithTag:TAGBTNOK];
    btn.hidden = YES;
    self.backgroundColor = [UIColor clearColor];
    
    
    //截图
    UIGraphicsBeginImageContext(self.bounds.size);
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    //把字写上去
    
    UIImageView* wordview = [[UIImageView alloc]initWithFrame:self.frame];
    wordview.image = image;
    
    wordview.frame = CGRectMake(outPannelView.contentOffset.x, outPannelView.contentOffset.y, self.frame.size.width, self.frame.size.height);
    //动画，字飞上去
    [UIView animateWithDuration:animateTime animations:^
     {
         wordview.frame = CGRectMake(wordPoint.x, wordPoint.y, wordSize.width, wordSize.height);
         
     } completion:^(BOOL finished) {
         
         
     }];
    [self.outPannelView addSubview:wordview];
    //还原空白，按钮和背景
    if (bgName != NULL)
        self.backgroundColor = [UIColor colorWithPatternImage:[self getImageWithFilename:bgName]];
    if (remainTime==0)
    {
        btn.hidden = NO;
    }
    
    self.image = nil;
    
    
    
    //消失
    [self removeFromSuperview];
    
    
    
    
    
    //通知字体写完
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:wordview,NOTIIMAGE, nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIWORDCOMPLETE object:self userInfo:dic];
    
    
    //设置下一个写入位置
    [self setNextWordPoint];
    
    NSDictionary* cursorDic = [NSDictionary dictionaryWithObjectsAndKeys:@(wordPoint.x),NOTICURSORX,@(wordPoint.y),NOTICURSORY, nil];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICURSOR object:self userInfo:cursorDic];
    
    
}

#pragma mark 具体绘制方法以及相关
//求两点之间的距离
-(float)distanceBetweemPoint1:(CGPoint)p1 andPoint2:(CGPoint)p2
{
    
    CGFloat xInc = (p1.x - p2.x);
    CGFloat yInc = (p1.y - p2.y);
    return  sqrt((xInc * xInc) + (yInc * yInc));
    
}
//方向模型
-(void)processBrushImageToPoint:(CGPoint)toPoint
{
    //
    
    float divx = toPoint.x - lastPoint.x;
    
    float divy = lastPoint.y - toPoint.y;
    
    if(divx == 0)
    {
        if (divy>=0)
        {
            orientation = kBrushOrientation90;
        }
        else
        {
            orientation = kBrushOrientation270;
        }
    }
    else
    {
        
        float tan = divy/divx;
        
        
        //-22.5 -> 22.5
        if (tan<0.414&&tan>-0.44&&divx>0) {
            orientation = kBrushOrientation0;
        }
        
        //157.5 ->202.5
        else if (tan<0.414&&tan>-0.414&&divx<0)
        {
            orientation = kBrushOrientation180;
        }
        
        
        //22.5->67.5
        if (tan>=0.414 && tan<2.414 &&divx>0)
        {
            orientation = kBrushOrientation45;
        }
        
        //202.5->247.5
        else if (tan>=0.414 && tan<2.414 &&divx<0)
        {
            orientation = kBrushOrientation225;
        }
        
        if ((tan>=2.414 || tan<=-2.414)&&divy>0)
        {
            orientation = kBrushOrientation90;
        }
        else if ((tan>=2.414 || tan<=-2.414)&&divy<0)
        {
            orientation = kBrushOrientation270;
            
        }
        
        if (tan>=-2.414 && tan <=-0.414 && divx<0)
        {
            orientation = kBrushOrientation135;
        }
        if (tan>=-2.414 && tan <=-0.414 && divx>0)
        {
            orientation = kBrushOrientation315;
        }
    }
    
    
    
   // orientation = kBrushOrientation0;
    
//    [baseBrush release];
//    
    baseBrush = [self getImageWithFilename:[self getBrushFilename]] ;
}

//笔刷宽度模型
-(void)processBrushWidth:(float)speed
{
    speed = MIN(speed, lastSpeed*3);
    speed = MAX(speed, lastSpeed/3);
    speed = MAX(50, speed);
    speed = log2f(speed);
    
    //最大时候speed12时候的笔刷宽度
    int n = 8;
    float scale = 1;
    
    if(lastBrushWidth == 0)
        lastBrushWidth = baseBrush.size.width*percent;
    
    
    float sensitive = 1;
    
    switch (wordMode)
    {
        case kWordNormal:
            
            
            sensitive = 1.25;
            break;
            
        case kWordStyle1:
            
            sensitive = 1;
            break;
        case kWordStyle2:
            
            sensitive = 1.1;
            break;
        case kWordStyle3:
            
            sensitive = 0.9;
            break;
        case kWordStyle4:
            
            sensitive = 1;
            break;
            
        default:
            sensitive = 1;

            break;
    }
    
    scale  = ((n -32)*speed/6.0 + 64-n)/32.0;
    scale = 1-(1-scale)/sensitive;
    
    curBrushWidth =scale*baseBrush.size.width*percent;
    
    curBrushWidth = MAX(1, curBrushWidth);
    
    curBrushWidth = MIN(curBrushWidth, baseBrush.size.width*percent);
    
}

//画线条，重点
-(void)drawLineToPoint:(CGPoint)toPoint toSpeed:(float)toSpeed
{
    //选择什么笔刷
    [self processBrushImageToPoint:toPoint];
    
    //选择笔刷宽度
    [self processBrushWidth:toSpeed];
    
    
    int count = MAX(ceilf(sqrtf((toPoint.x - lastPoint.x) * (toPoint.x - lastPoint.x) + (toPoint.y - lastPoint.y) * (toPoint.y - lastPoint.y))), 1);
    
    
    float xInc = (toPoint.x-lastPoint.x)/count;
    float yInc = (toPoint.y - lastPoint.y)/count;
    
    
    
    float divBrush = (curBrushWidth -lastBrushWidth)/count;
    
    
    UIGraphicsBeginImageContext(self.frame.size);
    
    [self.image drawInRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    
    
	for(int  i = 1; i < count; ++i)
    {
        
        float x = lastPoint.x + xInc*i;
        float y = lastPoint.y +yInc*i;
        
        
        float curWidth = (lastBrushWidth + divBrush*i);
        
        
       UIImage* curImage = [self getImageWithSize:curWidth] ;
        
	  	[curImage drawAtPoint:CGPointMake(x-curImage.size.width/2.0, y-curImage.size.height/2.0)];
        
	}
    
    self.image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
}

//滑动时候的处理逻辑
- (void) processTouch:(UITouch *) touch
{
    
    CGPoint  curPoint = [touch locationInView:self];
    
    float distance = [self distanceBetweemPoint1:curPoint andPoint2:lastPoint];
    
    NSDate* time = [NSDate date];
    NSTimeInterval  moveTime = [time timeIntervalSinceDate:lastTime];
    
//    [lastTime  release];
    lastTime = time;
    
    float speed = distance/moveTime;
    
    [self drawLineToPoint:curPoint toSpeed:speed];
    
    
    lastPoint = curPoint;
    lastSpeed = speed;
    
    lastBrushWidth = curBrushWidth;
    
}


#pragma mark 屏幕事件函数

-(void)doAutoTime
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(saveWrite:) withObject:nil afterDelay:remainTime];
}
//接触屏幕
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    if(remainTime>0)
        [self doAutoTime];
    
    UITouch *touch = [touches anyObject];
    
    lastPoint = [touch locationInView:self];
    
//    [lastTime release];
    lastTime = [NSDate date];
    
    lastSpeed = 0;
    
    lastBrushWidth = 0;
}



-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(remainTime>0)
        [self doAutoTime];
    
    UITouch * touch = [touches anyObject];
    
    
    [self processTouch:touch];
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(remainTime>0)
        [self doAutoTime];
    
    UITouch * touch = [touches anyObject];
    
    
    [self processTouch:touch];
    
    
//    int youmi = [[[Env sharedInstance] getDyncValue:@"youmi_brush"] intValue];
//    if (rand()%100 < youmi)
//    {
//        
//            [CocoBVideo cBIsHaveVideo:^(int isHaveVideoStatue) {
//                NSLog(@"video is %d",isHaveVideoStatue);
//                
//                [CocoBVideo cBVideoPlay:self.parentCtr cBVideoPlayFinishCallBackBlock:^(BOOL isFinishPlay) {
//                    
//                    NSLog(@"isfinshplay %d",isFinishPlay);
//                } cBVideoPlayConfigCallBackBlock:^(BOOL isLegal) {
//                    NSLog(@"is legal %d",isLegal);
//                }];
//            }];
//    } 
    
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
    UITouch * touch = [touches anyObject];
    
    
    [self processTouch:touch];
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

//- (void)dealloc
//{
//    [baseBrush release];
//    
//    [brushPool release];
//    
//    [super dealloc];
//}

@end

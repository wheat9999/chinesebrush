//
//  AGMainController.m
//  Write2
//
//  Created by zhjb on 14-6-5.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "AGMainController.h"
#import "CheckVersion.h"
#import "Reachability.h"
#import "DeviceUtil.h"
#import "UIImage+SplitImageIntoTwoParts.h"
#import "BaseDAO.h"
#import "SlideController.h"
#import "UIActionSheet+Blocks.h"

#import "DeviceUtil.h"
#import "WriteUtil.h"
#import "JSONKit.h"


@interface AGMainController ()
{
    WriteView* wView;
    
    SlideController* slideController;
    
    BOOL isSlidUp;
    
    CGRect winSize;
    
    float moveHeight;
    
    BOOL isWriting;
    
    UIImageView* cursorView;
    
    UIButton* delBtn;
    
    UIScrollView* pannelView;
    
    CGPoint lastOffset;
    
    float edgex;
    
    float edgey;
    
    float min_offsetx;
    
    float pannelWidth;
    
    float pannelHeight;
    
    NSTimer* insertBlankTimer;
    
    IBOutlet UILabel* lbPaomadeng;
    
    NSTimer* time;
    
    NSMutableArray* wordImageArray;
}

-(void)changeEditState:(BOOL)_isWriting;

@end

@implementation AGMainController

@synthesize btn;
@synthesize exerciseState;

- (void)flickerCursor
{
    cursorView.hidden = !cursorView.hidden;
}

-(void)alertUpdate:(NSString *)strContent
{
    if (![strContent isEqualToString:@""]) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"有新版本啦"
                                                     message:strContent
                                                    delegate:self
                                           cancelButtonTitle:@"取消"
                                           otherButtonTitles:@"亲,升级吧",nil] ;
        
        for(UIView *subview in av.subviews)
        {
            if([[subview class] isSubclassOfClass:[UILabel class]])
            {
                UILabel *label = (UILabel*)subview;
                
                if (![label.text isEqualToString:@"有新版本啦"]) {
                    
                    label.textAlignment = NSTextAlignmentLeft;
                }
                
            }
        }
        
        [av show];
        
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [alertView cancelButtonIndex])
    {
        NSURL *url = [NSURL URLWithString:APP_DownloadURL];
        [[UIApplication sharedApplication] openURL:url];
    }
}



- (void)viewDidLoad
{
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
    
    NSTimeInterval oldCheck = [[[NSUserDefaults standardUserDefaults] valueForKey:CHECKTIME] doubleValue];
    
    BOOL needCheck = NO;
    
    if (oldCheck> 0 && (now -oldCheck>60*60*24*7))
    {
        needCheck = YES;
    }
    else if (oldCheck == 0)
    {
        
        [[NSUserDefaults standardUserDefaults] setValue:@(now) forKey:CHECKTIME];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    //网络能连接
    if (needCheck&&[AGHttpUtil netReachable])
    {
        //一周检查一次
        [[NSUserDefaults standardUserDefaults] setValue:@(now) forKey:CHECKTIME];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSDictionary* resultDic =    [[CheckVersion  sharedController] requestVersionXML];
        
        if (resultDic != nil)
        {
            NSString *version = [resultDic objectForKey:@"version"];
            NSString *dese = [resultDic objectForKey:@"releaseNotes"];
            if (![version isEqualToString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]])
            {
                
                [self alertUpdate:dese];
                
                
            }
        }
        
        
    }
    else
    {
        sleep(1);
    }
    
    [super viewDidLoad];
    
    edgex = 10;
    edgey = 10;
    min_offsetx = 0;
    winSize = [DeviceUtil getWinSize];
    
    
    //设置wview的大小
    float writeWidth = StoreFloat(WRITEWIDTH);
    
   
    float writeHeight = StoreFloat(WRITEHEIGHT);
   
   
    wView = [WriteView sharedWriteViewWith:CGRectMake((winSize.size.width - writeWidth)/2,
                                                          (winSize.size.height- writeHeight)/2,
                                                          writeWidth, writeHeight)];
    wView.parentCtr = self;
   
    
    //设置排版和行字
    kWordArrange arrange = StoreInt(ARRANGE);

    int linenum = StoreInt(LINENUM);
    
   
    [self changeArrange:arrange andNum:linenum];
        
        
   
    
    
    //设置笔刷
    float percent = StoreFloat(BRUSHWIDTH);
    
   
    wView.percent = percent;
    
    

    
    //设置字体
    
        wView.wordMode = StoreInt(BRUSHMODE);
    
    
    //自动停留时间
    
        wView.remainTime = StoreFloat(REMAINTIME);
    
    
    //设置动画时间
    
        wView.animateTime = StoreFloat(ANNIMATIONTIME);
    
    
    //设置字体的大小
    
    wView.wordSize = CGSizeMake(StoreFloat(WORDWIDTH), StoreFloat(WORDHEIGHT));
    
    
    [self changeWordSize:wView.wordSize];
    
    
    
    
    pannelView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,winSize.size.width, winSize.size.height)];
    
    
    
    
    
    [self.view addSubview:pannelView];
    pannelView.userInteractionEnabled = NO;
    
    
    //self.view.clipsToBounds = NO;
    
    
    wView.outPannelView = pannelView;
    
    CGSize btnSize = CGSizeMake(80, 40);
    
    self.btn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btn.frame = CGRectMake(winSize.size.width/2-btnSize.width/2, winSize.size.height-btnSize.height, btnSize.width, btnSize.height);
    [self.view addSubview:btn];
    
    //paomadeng
//    lbPaomadeng = [[UILabel alloc]initWithFrame:CGRectMake(0, 0,winSize.size.width, 30)];
//    lbPaomadeng.backgroundColor = [UIColor clearColor];
//    lbPaomadeng.textColor = [UIColor colorWithRed:108/255.0 green:47/255.0 blue:151/255.0 alpha:1];
//    lbPaomadeng.font = [UIFont systemFontOfSize:24];
//    [self.view addSubview:lbPaomadeng];
    paomadengBgView.hidden = YES;
    
    
    [self changeEditState:YES];
    moveHeight = winSize.size.height;
    
    
    [self.btn addTarget:self action:@selector(dragEnded:withEvent: )forControlEvents: UIControlEventTouchUpInside |
     UIControlEventTouchUpOutside];
    
    
    slideController = [[UIStoryboard storyboardWithName:@"Slide" bundle:[NSBundle mainBundle]] instantiateInitialViewController];
    
    
    slideController.view.frame = CGRectMake(0, winSize.size.height, winSize.size.width, winSize.size.height);
    slideController.mainBoardCtrl = self;
    [self.view addSubview:slideController.view];
    
    //光标
    cursorView = [[UIImageView alloc]initWithFrame:CGRectMake(wView.startPoint.x, wView.startPoint.y, wView.wordSize.width, wView.wordSize.height)];
    
    
    cursorView.image =  [UIImage imageNamed:@"guangbiao"];
    [pannelView addSubview:cursorView];
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(flickerCursor) userInfo:nil repeats:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(writeComplete:) name:NOTICURSOR object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ImageComplete:) name:NOTIWORDCOMPLETE object:nil];
    
    
    //删除按钮
    delBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, wView.wordSize.width, wView.wordSize.height)];
    [delBtn setImage:[UIImage getImageWithName:@"button-del.png"] forState:UIControlStateNormal];
    //[delBtn setTitle:@"Del" forState:UIControlStateNormal];
    [delBtn addTarget:self action:@selector(delWord:) forControlEvents:UIControlEventTouchUpInside];
    delBtn.alpha = 0.8;
    //delBtn.backgroundColor = [UIColor redColor];
    
    //pannel增加单击手势
    UITapGestureRecognizer *singleTouch=[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(changeCursorPosition:)];
    [pannelView addGestureRecognizer:singleTouch];
//    [singleTouch release];
//    
//    slideController.mainBoardCtrl = self;
    
    //设置手写背景图
   
    
    
    wView.bgName = [NSString stringWithFormat:@"write_bg%d.png",StoreInt(WRITEBG)];
    
    //设置背景图
    
        NSString* bgName = [NSString stringWithFormat:@"pannel_bg%d.png",StoreInt(PANNELBG)];
        pannelView.backgroundColor = [UIColor colorWithPatternImage:[UIImage getImageWithName:bgName]];
   
    
    UILongPressGestureRecognizer* longRecognizer;
    longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    
    // doubleRecognizer.numberOfTapsRequired = 2; // 双击
    //关键语句，给self.view添加一个手势监测；
    [self.view addGestureRecognizer:longRecognizer];
    
    
    HttpUtil* http = [AGHttpUtil new];
    
    NSString* url = [[Env sharedInstance] getUrlWithApi:@"action_add"];
    
    
    NSDictionary* data = @{@"uuid":[WriteUtil getToken],
                          @"name":@"MainView",
                          @"version":[[Env sharedInstance] getDyncValue:@"version"],
                          @"extra":@"none"};
    
    
    [http getRemoteDataWithUrl:url andUrlType:URLGET andData:data andFiles:nil andJson:NO andFinishCallbackBlock:^(NSData * response) {
        
        NSString* res = [[NSString alloc]initWithData:response encoding:NSUTF8StringEncoding];
        
        NSLog(@"response is %@",res);
        ;
    } andDelegate:nil];
    
    wordImageArray = [NSMutableArray new];
    
    [self performSelector:@selector(jumpStockView) withObject:nil afterDelay:0.5];
    
    
    //add advert
    
//    adView.requiredContentSizeIdentifiers = [NSSet setWithObject:ADBannerContentSizeIdentifierPortrait];
//    adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
   
    if ([[[Env sharedInstance] getDyncValue:@"iad"] boolValue])
    {
        adView.delegate = self;
        adView.frame = CGRectOffset(adView.frame, 0, 100);
    }
    else
    {
        adView.hidden = YES;
        adView = nil;
    }
    
    
    [self getConfig];
    
    
    
}

-(void)getConfig
{
    HttpUtil* http = [HttpUtil new];
    
    NSString* url = @"http://115.29.237.213/writeapp/index.php?r=conf/list";
    [http getRemoteDataWithUrl:url andUrlType:URLGET andData:nil andFiles:nil andJson:NO andFinishCallbackBlock:^(NSData *resp) {
        NSString* response = [[NSString alloc]initWithData:resp encoding:NSUTF8StringEncoding];
        
        if (response)
        {
            NSDictionary* dic =   [response objectFromJSONString];
            
            if (dic)
            {
                NSArray* confArray = [dic valueForKey:@"data"];
                for (NSDictionary* confItem in confArray)
                {
                    NSString* action = [confItem valueForKey:@"action"];
                    NSString* value = [confItem valueForKey:@"value"];
                    
                    [[Env sharedInstance] addDynamicValue:value andKey:action];
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CONF" object:nil];
                [self toPopView];
                
                
            }
            
        }
        
       
    } andDelegate:nil];
    
}

-(void)toPopView
{
    if ([[[Env sharedInstance]getDyncValue:@"pop"] boolValue])
    {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"StockGame" bundle:nil];
        
        UIViewController* ctr = [sb instantiateInitialViewController];
        
        [self presentViewController:ctr animated:YES completion:^{
            ;
        }];

    }
}

-(void) bannerViewDidLoadAd:(ADBannerView *)banner
{
    if(!bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOn"  context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, -100);
        [UIView commitAnimations];
        bannerIsVisible = YES;
        btn.frame = CGRectOffset(btn.frame, 0, -banner.frame.size.height);
    }
}

-(void) bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    if(bannerIsVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff"  context:NULL];
        banner.frame = CGRectOffset(banner.frame, 0, 100);
        btn.frame = CGRectOffset(btn.frame, 0, banner.frame.size.height);
        [UIView commitAnimations];
        bannerIsVisible = NO;
    }
}

-(void)jumpStockView
{
//    NSString* stockStr = Store(@"stock");
//    NSArray* stockArray = [stockStr objectFromJSONString];
    
    NSArray* stockArray = [[NSUserDefaults standardUserDefaults] valueForKey:@"codes"];
    
    if ([stockArray count]>0)
    {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Stock" bundle:nil];
        
        UIViewController* ctr = [sb instantiateInitialViewController];
        
        [self presentViewController:ctr animated:YES completion:^{
            ;
        }];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
  
}

-(void)insertBlank
{
    [wView insertBlank];
    lastOffset = pannelView.contentOffset;
}
-(void)longPress:(UILongPressGestureRecognizer*)gest
{
    if (!isWriting)
    {
        //开始长按
        if (gest.state == 1) {
            insertBlankTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(insertBlank) userInfo:nil repeats:YES];
        }
        if (gest.state == 3) {
            [insertBlankTimer invalidate];
        }
        
    }
    
}

-(void)ImageComplete:(NSNotification*)noti
{

    NSDictionary* userDic = [noti userInfo];
    
    UIImage* image = [userDic valueForKey:NOTIIMAGE];
    
    [wordImageArray addObject:image];
}

-(void)writeComplete:(NSNotification*)noti
{
    cursorView.hidden = NO;
    NSDictionary* userDic = [noti userInfo];
    int pointx = [[userDic valueForKey:NOTICURSORX] intValue];
    
    int pointy = [[userDic valueForKey:NOTICURSORY] intValue];
    
    cursorView.frame = CGRectMake(pointx, pointy, cursorView.frame.size.width, cursorView.frame.size.height);
    
    
    int offsetX = pannelView.contentOffset.x;
    int offsetY = pannelView.contentOffset.y;
    if(pannelView.contentOffset.x + winSize.size.width < pointx+wView.wordSize.width + wView.wordBlank)
    {
        offsetX = pointx - winSize.size.width+wView.wordSize.width + wView.wordBlank;
    }
    if (pannelView.contentOffset.x>pointx)
    {
        offsetX = pointx;
    }
    
    float visibleHeight = winSize.size.height;
    
    if (exerciseState)
    {
        visibleHeight -= DEFAULT_EXAMHEIGHT;
    }
    if(pannelView.contentOffset.y +visibleHeight<pointy +wView.wordSize.height +wView.lineBlank)
    {
        offsetY = pointy - visibleHeight +wView.wordSize.height +wView.lineBlank;
    }
    
    if (pannelView.contentOffset.y>pointy)
    {
        offsetY = pointy;
    }
    
    
    
    
    if (pannelView.contentOffset.x <min_offsetx)
    {
        min_offsetx = pannelView.contentOffset.x;
    }
    
    
    [UIView animateWithDuration:1 animations:^{
        pannelView.contentOffset = CGPointMake(offsetX, offsetY);
    }];
    
    float newPannelWidth = MAX(pannelView.contentSize.width, offsetX+winSize.size.width);
    float newPannelHeight = MAX(pannelView.contentSize.height, offsetY +visibleHeight);
    
    
    pannelView.contentSize = CGSizeMake(newPannelWidth,newPannelHeight);
    
    
}


- (void) dragMoving: (UIControl *) c withEvent:ev
{
    CGPoint newPoint = [[[ev allTouches] anyObject] locationInView:self.view];
    
    newPoint.y = MAX(newPoint.y, c.frame.size.height/2);
    newPoint.y = MIN(winSize.size.height - c.frame.size.height/2, newPoint.y);
    newPoint.x = MAX(newPoint.x, c.frame.size.width/2);
    newPoint.x = MIN(winSize.size.width - c.frame.size.width/2,newPoint.x);
    
    
    c.center = newPoint;
    
    CGRect slideframe = slideController.view.frame;
    
    slideframe.origin.y = c.frame.origin.y + c.frame.size.height;
    
    slideController.view.frame = slideframe;
    
    //记录最大值
    if (isSlidUp)
    {
        if (newPoint.y>moveHeight)
        {
            moveHeight = newPoint.y;
        }
    }
    else
    {
        if (newPoint.y<moveHeight)
        {
            moveHeight = newPoint.y;
        }
    }
}

- (void)toSlidUp
{
    isSlidUp = YES;
    moveHeight = 0;
    
    CGRect btnframe = btn.frame;
    CGRect slideframe = slideController.view.frame;
    //slideController.newDocBtn.hidden = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        
        btn.frame = CGRectMake(btnframe.origin.x, -btnframe.size.height, btnframe.size.width, btnframe.size.height);
        
        slideController.view.frame = CGRectMake(0, 0, slideframe.size.width, slideframe.size.height);
    }];
    
    //self.view.userInteractionEnabled = NO;
}

-(void)toSlidDown
{
    isSlidUp = NO;
    moveHeight = winSize.size.height;
    
    CGRect btnframe = btn.frame;
    CGRect slideframe = slideController.view.frame;
    
    float adHeight  = 0;
    if (bannerIsVisible) {
        adHeight = adView.frame.size.height;
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        
        btn.frame = CGRectMake(btnframe.origin.x, winSize.size.height-btnframe.size.height-adHeight, btnframe.size.width, btnframe.size.height);
        
        slideController.view.frame = CGRectMake(0, slideframe.size.height, slideframe.size.width, slideframe.size.height);
    }];
    
    // self.view.userInteractionEnabled = YES;
}

-(void)delWord:(id)sender
{
    
    UIImageView* wordImage = (UIImageView*)delBtn.superview;
    [wordImage removeFromSuperview];
    
    
    
    wView.wordPoint = wordImage.frame.origin;
    cursorView.frame = CGRectMake(wordImage.frame.origin.x, wordImage.frame.origin.y, cursorView.frame.size.width, cursorView.frame.size.height);
    
    lastOffset = pannelView.contentOffset;
    
    [wordImageArray removeObject:wordImage];
    
}

-(void)touchWord:(UITapGestureRecognizer*) gesture
{
    UIImageView* wordImage = (UIImageView*)gesture.view;
    
    if(delBtn.superview != NULL)
        [delBtn removeFromSuperview];
    [wordImage addSubview:delBtn];
    
    
}

-(void)addWordInteraction:(BOOL)interaction
{
    NSArray* subViews =  pannelView.subviews;
    
    
    for (UIView* subView in subViews)
    {
        
        if ([subView isKindOfClass:[UIImageView class]] && subView != cursorView)
        {
            if (interaction)
            {
                subView.userInteractionEnabled = YES;
                
                UITapGestureRecognizer *singleTouch=[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(touchWord:)];
                [subView addGestureRecognizer:singleTouch];
               // [singleTouch release];
            }
            else
            {
                subView.userInteractionEnabled = NO;
                UITapGestureRecognizer *singleTouch=[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(touchWord:)];
                [subView removeGestureRecognizer:singleTouch];
               // [singleTouch release];
                
            }
            
        }
    }
    
    
}

-(void)judgeOffsetNegative
{
    if(min_offsetx<0)
    {
        CGPoint offset = pannelView.contentOffset;
        
        NSArray* wordImages = pannelView.subviews;
        
        //全部右移
        for (UIView* wordImage in wordImages)
        {
            CGRect wordRect = wordImage.frame;
            wordRect.origin.x += - min_offsetx;
            wordImage.frame = wordRect;
        }
        CGSize pannelSize = pannelView.contentSize;
        pannelSize.width += -min_offsetx;
        
        pannelView.contentSize = pannelSize;
        
        NSLog(@"wordpoint1:%f-%f",wView.wordPoint.x,wView.wordPoint.y);
        CGPoint newWordPoint = wView.wordPoint;
        newWordPoint.x += -min_offsetx;
        
        wView.wordPoint = newWordPoint;
        NSLog(@"wordpoint2:%f-%f",wView.wordPoint.x,wView.wordPoint.y);
        [self positionCursor:wView.wordPoint];
        
        offset.x = 0;
        pannelView.contentOffset = offset;
        
        
        
        wView.startPoint = CGPointMake(wView.startPoint.x-min_offsetx, wView.startPoint.y);
        
        min_offsetx = 0;
        
    }
    
}


-(void)changeEditState:(BOOL)_isWriting
{
    isWriting = _isWriting;
    if (isWriting)
    {
        if (delBtn.superview != NULL)
        {
            [delBtn removeFromSuperview];
        }
        
        //[btn setTitle:@"手写" forState:UIControlStateNormal];
        
        [btn setImage:[UIImage getImageWithName:@"button-normail-main.png"] forState:UIControlStateNormal];
        //[self.btn setTitle:@"移动" forState:UIControlEventTouchDown];
        [self.btn addTarget:self action:@selector(dragMoving:withEvent: )forControlEvents: UIControlEventTouchDragInside];
        
        [self addWordInteraction:NO];
        pannelView.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:0.5 animations:^{
            pannelView.contentOffset = lastOffset;
        }];
    }
    else
    {
        //从右向左写的情况
        [self judgeOffsetNegative];
        
        lastOffset = pannelView.contentOffset;
        
        [btn setImage:[UIImage getImageWithName:@"button-normail-main-edit.png"] forState:UIControlStateNormal];
        
        [self.btn  removeTarget:self action:@selector(dragMoving:withEvent: )forControlEvents: UIControlEventTouchDragInside];
        
        [self addWordInteraction:YES];
        pannelView.userInteractionEnabled = YES;
        
    }
}

- (void) dragEnded: (UIControl *) c withEvent:ev
{
    CGPoint newPoint = [[[ev allTouches] anyObject] locationInView:self.view];
    if (isSlidUp)
    {
        if(newPoint.y>moveHeight-20)
            [self toSlidDown];
        else
            [self toSlidUp];
        
    }
    else
    {
        if(moveHeight>= winSize.size.height-10)
        {
            [self changeEditState:!isWriting];
            return;
        }
        
        if (newPoint.y<moveHeight+20)
        {
            [self toSlidUp];
        }
        else
        {
            [self toSlidDown];
        }
    }
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
    
    if (isWriting&&!isSlidUp)
    {
        
        [self.view insertSubview:wView belowSubview:btn];
        [wView touchesBegan:touches withEvent:event];
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (isWriting&&!isSlidUp)
    {
        
        [wView touchesMoved:touches withEvent:event];
    }
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (isWriting&&!isSlidUp)
    {
        
        [wView touchesEnded:touches withEvent:event];
    }
    
    
    
    
    
}

- (void)positionCursor:(CGPoint)position
{
    wView.wordPoint = CGPointMake(position.x, position.y);
    cursorView.frame = CGRectMake(position.x, position.y, cursorView.frame.size.width, cursorView.frame.size.height);
}

-(void)changeCursorPosition:(UIGestureRecognizer*)gesture
{
    CGPoint s = [gesture locationInView:pannelView];
    
    
    if(wView.wordArrange == kWordHorizontal || wView.wordArrange == kWordVerticalReverse)
    {
        
        int xIndex = (s.x - wView.startPoint.x)/(wView.wordSize.width+wView.wordBlank);
        
        int yIndex = (s.y - wView.startPoint.y)/(wView.wordSize.height+wView.lineBlank);
        
        [self positionCursor:CGPointMake(xIndex*(wView.wordSize.width+wView.wordBlank)+wView.startPoint.x, yIndex*(wView.wordSize.height+wView.lineBlank)+wView.startPoint.y)];
        
        
    }
    else if(wView.wordArrange == kWordHorizontalReverse || wView.wordArrange == kWordVertical)
    {
        
        
        int xIndex = (wView.startPoint.x-s.x)/(wView.wordSize.width+wView.wordBlank)+1;
        
        int yIndex = (s.y - wView.startPoint.y)/(wView.wordSize.height+wView.lineBlank);
        
        [self positionCursor:CGPointMake(wView.startPoint.x-xIndex*(wView.wordSize.width+wView.wordBlank), yIndex*(wView.wordSize.height+wView.lineBlank)+wView.startPoint.y)];
        
        
        
    }
    
    
    
    if (delBtn.superview != NULL) {
        [delBtn removeFromSuperview];
    }
    
    lastOffset = pannelView.contentOffset;
    
}

- (void)clearPannel
{
    NSArray* wordImages = pannelView.subviews;
    
    for (UIView* subView in wordImages)
    {
        [subView removeFromSuperview];
    }
    
    [pannelView addSubview:cursorView];
    
    //[self positionCursor:CGPointMake(wView.startPoint.x, wView.startPoint.y)];
    
    
    [self rebuildPannel];
    
    [wordImageArray removeAllObjects];
    
}

- (UIImage*)getPannelImage
{
    
    if(UIGraphicsBeginImageContextWithOptions !=NULL)
    {
        UIGraphicsBeginImageContextWithOptions(pannelView.contentSize, NO, 0.0);
    }else{
        
        UIGraphicsBeginImageContext(pannelView.contentSize);
    }
    
    //获取图像
    [pannelView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    
    
    return image;
}



- (void)savePannel
{
    
    
    UIImageWriteToSavedPhotosAlbum([self getImage], nil, nil, nil);
    
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"保存成功" message:@"已保存至相册" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
   // [alert release];
    
    
    
    
}
- (UIImage*)getImage
{
    [self judgeOffsetNegative];
    
    
    
    UIImageView* bgimage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, pannelView.contentSize.width, pannelView.contentSize.height)];
    
    NSString* bgName = [NSString stringWithFormat:@"pannel_bg%d.png",StoreInt(PANNELBG)];
    
    
    bgimage.backgroundColor = [UIColor colorWithPatternImage: [UIImage getImageWithName:bgName]];
    [pannelView insertSubview:bgimage atIndex:0];
    
    pannelView.clipsToBounds = NO;
    cursorView.hidden = YES;
    UIImage* image = [self getPannelImage];
    cursorView.hidden = NO;
    pannelView.clipsToBounds = YES;
    [bgimage removeFromSuperview];
   // [bgimage release];
    
    
    return image;
    
}
- (void)changeBrush:(float)percent
{
    wView.percent = percent;
}

- (void)changeRemainTime:(float)_time
{
    wView.remainTime = _time;
}

- (void)changeAnimationTime:(float)_time
{
    wView.animateTime = _time;
}

-(void)rebuildPannel
{
    if (wView.wordArrange == kWordHorizontal)
    {
        wView.startPoint = CGPointMake(edgex, edgey);
        wView.pageWidth = (wView.wordSize.width + wView.wordBlank)*wView.linenum+edgex;
        
    }
    else if (wView.wordArrange == kWordHorizontalReverse)
    {
        wView.startPoint = CGPointMake(winSize.size.width-wView.wordSize.width-wView.wordBlank-edgex, edgey);
        wView.pageWidth = (wView.wordSize.width + wView.wordBlank)*wView.linenum+edgex;
        
        
    }
    
    else if (wView.wordArrange == kWordVertical)
    {
        wView.startPoint = CGPointMake(winSize.size.width-wView.wordSize.width-wView.wordBlank-edgex, edgey);
        wView.pageHeight = (wView.wordSize.height + wView.lineBlank)*wView.linenum+edgey;
        
        
    }
    
    else if (wView.wordArrange == kWordVerticalReverse)
    {
        wView.startPoint = CGPointMake(edgex, edgey);
        wView.pageHeight = (wView.wordSize.height + wView.lineBlank)*wView.linenum+edgey;
        
    }
    pannelView.contentSize = CGSizeMake(winSize.size.width, winSize.size.height);
    pannelView.contentOffset = CGPointMake(0, 0);
    [self positionCursor:wView.startPoint];
}

- (void)changeArrange:(kWordArrange)newArrange andNum:(int)num
{
    wView.wordArrange = newArrange;
    wView.linenum = num;
    [self rebuildPannel];
   
}

- (void)changeWordSize:(CGSize)newWordSize
{
    wView.wordSize = newWordSize;
    wView.wordBlank = newWordSize.width/20;
    wView.lineBlank = newWordSize.height/20;
    CGRect cursorFrame  = cursorView.frame;
    cursorFrame.size.height = newWordSize.height;
    cursorFrame.size.width = newWordSize.width;
    cursorView.frame = cursorFrame;
    
    
    delBtn.frame = CGRectMake(0, 0, wView.wordSize.width, wView.wordSize.height);
    
    [self rebuildPannel];
    
    
}

- (void)changeWriteSize:(CGSize)newWriteSize
{
    wView.frame =  CGRectMake((winSize.size.width - newWriteSize.width)/2,
                              (winSize.size.height- newWriteSize.height)/2,
                              newWriteSize.width, newWriteSize.height);
}

- (void)changePannelBg:(int)bgIndex
{
    NSString* bgName = [NSString stringWithFormat:@"pannel_bg%d",bgIndex];
    pannelView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:bgName]];
}

- (void)changeWriteBg:(int)bgIndex
{
    NSString* bgName = [NSString stringWithFormat:@"write_bg%d.png",bgIndex];
    
    wView.bgName = bgName;
}
- (void)changeWordMode:(int)wordMode
{
    wView.wordMode = wordMode;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)subPaomadengFrame
{
    float div = (10+StoreFloat(PAOMADENGSPEED))/10;
    
    CGRect newRect = lbPaomadeng.frame;
    newRect.origin.x -=div;
    
    lbPaomadeng.frame = newRect;
    
    if (lbPaomadeng.frame.size.width + lbPaomadeng.frame.origin.x < 5)
    {
        [self performSelectorOnMainThread:@selector(stop) withObject:nil waitUntilDone:YES];
    }
   
    
}

-(void)setPaomadeng:(NSString*)content
{
    
    pannelView.frame = CGRectMake(0, DEFAULT_EXAMHEIGHT,winSize.size.width, winSize.size.height-DEFAULT_EXAMHEIGHT);
    
    paomadengBgView.hidden = NO;
    
    lbPaomadeng.text = content;
    [lbPaomadeng sizeToFit];
    CGRect frame = lbPaomadeng.frame;
    frame.origin.x = winSize.size.width-200;
    
    lbPaomadeng.frame = frame;
    
    time = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(subPaomadengFrame) userInfo:nil repeats:YES];
    
   
    
    
}

-(void)stop
{
    paomadengBgView.hidden = YES;
    pannelView.frame = CGRectMake(0, 0,winSize.size.width, winSize.size.height);
    
    [time invalidate];
}

-(IBAction)stopPaomadeng
{
    
    RIButtonItem* btn0 = [RIButtonItem itemWithLabel:@"取消"];
    RIButtonItem* btn1 = [RIButtonItem itemWithLabel:@"退出" action:^{
        [self stop];
    }];
    UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"确定退出吗" cancelButtonItem:btn0 destructiveButtonItem:btn1 otherButtonItems: nil];
    
    [sheet showInView:self.view];
   
}


-(IBAction)addSpeed:(id)sender
{
    int speed = StoreInt(PAOMADENGSPEED);
    
    if (speed<40) {
        speed++;
        
        Update(PAOMADENGSPEED, I2S(speed));
    }
    
}

-(IBAction)subSpeed:(id)sender
{
    int speed = StoreInt(PAOMADENGSPEED);
    
    if (speed>-5)
    {
        speed--;
        
        Update(PAOMADENGSPEED, I2S(speed));
    }
   
}

-(int)getWordNum
{
    
    
    return [wordImageArray count];
}

@end

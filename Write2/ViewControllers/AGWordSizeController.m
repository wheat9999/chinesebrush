//
//  AGWordSizeController.m
//  Write2
//
//  Created by zhjb on 14-6-9.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "AGWordSizeController.h"
#import "AGMainController.h"
#import "DeviceUtil.h"

@interface AGWordSizeController ()
{
    IBOutlet UIImageView* wordImage;
    
    CGPoint lastPoint1;
    
    CGPoint lastPoint2;
    
    BOOL isMoving;
    
    CGRect winSize;
    
}

@end

@implementation AGWordSizeController
@synthesize mainBoardCtrl = _mainBoardCtrl;
@synthesize mode = _mode;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    winSize = [DeviceUtil getWinSize];
    // Do any additional setup after loading the view from its nib.
    
    
    int imgWidth;
    int imgHeight;
    
    if (_mode == 0)
    {
        imgWidth = StoreInt(WORDWIDTH);
        imgHeight = StoreInt(WORDHEIGHT);
        
        wordImage.image = [UIImage imageNamed:@"wordsize"];
    }
    else
    {
        imgWidth = StoreInt(WRITEWIDTH);
        imgHeight = StoreInt(WRITEHEIGHT);
        
        NSString* bgName = [NSString stringWithFormat:@"write_bg%d",StoreInt(WRITEBG)];
        wordImage.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:bgName]];
        
       
    }
    
     wordImage.frame = CGRectMake((winSize.size.width-imgWidth)/2, (winSize.size.height-imgHeight)/2, imgWidth, imgHeight);
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    isMoving = NO;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([touches count] == 2)
    {
        
        UITouch* newTouch1 =   [[touches allObjects] objectAtIndex:0];
        UITouch* newTouch2 = [[touches allObjects] objectAtIndex:1];
        
        CGPoint newPoint1 = [newTouch1 locationInView:self.view];
        CGPoint newPoint2 = [newTouch2 locationInView:self.view];
        
        if (!isMoving)
        {
            lastPoint1 = newPoint1;
            lastPoint2 = newPoint2;
            
            isMoving = YES;
            
            return;
        }
        
        
        
        
        float lastDisX = fabsf(lastPoint1.x - lastPoint2.x);
        
        float lastDisY = fabsf(lastPoint1.y - lastPoint2.y);
        
        float curDisX = fabsf(newPoint1.x - newPoint2.x);
        
        float curDisY = fabsf(newPoint1.y - newPoint2.y);
        
        lastDisX = MAX(2,lastDisX);
        lastDisY = MAX(2,lastDisY);
        
        curDisX = MAX(2, curDisX);
        curDisY = MAX(2, curDisY);
        
        float scaleX = curDisX/lastDisX;
        float scaleY = curDisY/lastDisY;
        
        
        
        
        float wordWidth = wordImage.frame.size.width*scaleX;
        float wordHeight = wordImage.frame.size.height*scaleY;
        
        wordWidth = MIN( winSize.size.width,wordWidth);
        
        wordHeight = MIN(winSize.size.height, wordHeight);
        
        wordImage.frame = CGRectMake((winSize.size.width-wordWidth)/2, (winSize.size.height-wordHeight)/2, wordWidth, wordHeight);
        
        lastPoint1 = newPoint1;
        lastPoint2 = newPoint2;
        
        isMoving = YES;
        
    }
    
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    isMoving = NO;
}



-(IBAction)save:(id)sender
{
   
    if (_mode == 0) {
        Update(WORDWIDTH, I2S((int)wordImage.frame.size.width));
        Update(WORDHEIGHT, I2S((int)wordImage.frame.size.height));
        
        [_mainBoardCtrl changeWordSize:CGSizeMake(wordImage.frame.size.width, wordImage.frame.size.height)];
    }
    else
    {
        //必须为偶数
        int writeWidth = ((int)wordImage.frame.size.width)/2*2;
        int writeHeight = ((int)wordImage.frame.size.height)/2*2;
        
        Update(WRITEWIDTH, I2S(writeWidth));
        Update(WRITEHEIGHT, I2S(writeHeight));
        
        [_mainBoardCtrl changeWriteSize:CGSizeMake(writeWidth, writeHeight)];
    }
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}


-(IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end

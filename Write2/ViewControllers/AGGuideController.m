//
//  AGGuideController.m
//  Write2
//
//  Created by zhjb on 14-6-5.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "AGGuideController.h"
#import "DeviceUtil.h"
#import "AGAppDelegate.h"
#import "UIImage+SplitImageIntoTwoParts.h"
#import "BaseDAO.h"

@interface AGGuideController ()
{
    IBOutlet UIScrollView* myScrollView;
    
    IBOutlet UIButton* gotoMainViewBtn;
    
    IBOutlet UIImageView* imgLast;
    
    IBOutlet UIPageControl* pageCtr;
    
   
    
}
@property (nonatomic,strong) UIImageView *left;
@property (nonatomic,strong) UIImageView *right;
@end

@implementation AGGuideController

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
    
    NSArray* list =  [[BaseDAO sharedInstance] getList:@"Config" andCondition:@{@"key":@"used"}];
    
    if ([list count] > 0)
    {
        
        
        float appVersion = [[[Env sharedInstance] getDyncValue:@"version"] floatValue];
        
        float lastVersion = StoreFloat(@"app_version");
        
        
        if (appVersion == lastVersion)
        {
            [self jumpMainView];
            return;
        }
        
    }
    
    
    
    
    myScrollView.contentSize = CGSizeMake(320*4, myScrollView.frame.size.height);
    CGRect rect = myScrollView.frame;
    rect.size.width = 320;
    myScrollView.frame = rect;
    pageCtr.numberOfPages = 4;
    pageCtr.currentPage = 0;
    
    
    
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

-(void)jumpMainView
{
    AGAppDelegate* delegate = (AGAppDelegate*)  [UIApplication sharedApplication].delegate;
    
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    
    delegate.window.rootViewController = [sb instantiateInitialViewController];
}

-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    if ([animationID isEqualToString:@"split"] && finished) {
        
        [self.left removeFromSuperview];
        [self.right removeFromSuperview];
        
        CATransition *animation = [CATransition animation];
        [animation setDuration:1.0f];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
        [animation setType:kCATransitionFade];
        [animation setSubtype:kCATransitionFade];
        [self.view.superview.layer addAnimation:animation forKey:@"FadeIn"];
        
       
        [self jumpMainView];
        
        

        
        
    }
}

- (IBAction)gotoMainView:(id)sender {
    
   
    NSString* appVersion = [[Env sharedInstance] getDyncValue:@"version"];
    
    NSArray* list =  [[BaseDAO sharedInstance] getList:@"Config" andCondition:@{@"key":@"used"}];
    
    //第一次
    if ([list count] == 0)
    {
        NSString* dicPath = [[NSBundle mainBundle] pathForResource:@"Default" ofType:@"plist"];
        NSDictionary* dic = [NSDictionary dictionaryWithContentsOfFile:dicPath];
        
        [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [[BaseDAO sharedInstance] insert:@"Config" andValue:@{@"key": key,@"value":obj}];
        }];
        
        
        [[BaseDAO sharedInstance] insert:@"Config" andValue:@{@"key":@"app_version",@"value":appVersion}];
    }
    else
    {
        [[BaseDAO sharedInstance] update:@"Config" andCondition:@{@"key":@"app_version"} andValue:@{@"value":appVersion}];
    }
   
    
    
    
    [gotoMainViewBtn setHidden:YES];
    NSArray *array = [UIImage splitImageIntoTwoParts:imgLast.image];
    self.left = [[UIImageView alloc] initWithImage:[array objectAtIndex:0]];
    self.right = [[UIImageView alloc] initWithImage:[array objectAtIndex:1]];
    
    
    self.left.frame = CGRectMake(0, 0, [DeviceUtil getWinSize].size.width, [DeviceUtil getWinSize].size.height);
    self.right.frame = CGRectMake(0, 0, [DeviceUtil getWinSize].size.width, [DeviceUtil getWinSize].size.height);
    [self.view addSubview:self.left];
    [self.view addSubview:self.right];
    [myScrollView setHidden:YES];
    [pageCtr setHidden:YES];
    self.left.transform = CGAffineTransformIdentity;
    self.right.transform = CGAffineTransformIdentity;
    
    [UIView beginAnimations:@"split" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDuration:1.0f];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    
    self.left.transform = CGAffineTransformMakeTranslation(-200 ,0);
    self.right.transform = CGAffineTransformMakeTranslation(180 ,0);
    [UIView commitAnimations];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = self.view.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageCtr.currentPage = page;
    
   
}


@end

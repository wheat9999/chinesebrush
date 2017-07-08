//
//  CustomCamera.m
//  CameraTapper
//
//  Created by Jeffrey Berthiaume on 3/9/10.
//  Copyright 2010 pushplay.net. All rights reserved.
//

#import "CustomCamera.h"
#import "DeviceUtil.h"


@implementation CustomCamera
@synthesize descHint;

-(UIView *)findView:(UIView *)aView withName:(NSString *)name{
    Class cl = [aView class];
    NSString *desc = [cl description];
    
    if ([name isEqualToString:desc])
        return aView;
    
    for (NSUInteger i = 0; i < [aView.subviews count]; i++)
    {
        UIView *subView = [aView.subviews objectAtIndex:i];
        subView = [self findView:subView withName:name];
        if (subView)
            return subView;
    }
    return nil;
}

- (void)hideOverlay
{
    cameraOverlayView.hidden = YES;
}
-(void)showOverlay
{
    cameraOverlayView.hidden = NO;
}

-(void)printSubView:(UIView*)sub
{
    NSLog(@"sub is %@",[[sub class] description]);
    
    if ([sub isKindOfClass:[UIButton class]])
    {
        
        //找到拍照按钮
        if ([[[sub class] description] isEqualToString:@"PLCameraButton"])
        {
            // sub.hidden = YES;
            [((UIButton*)sub) addTarget:self action:@selector(hideOverlay) forControlEvents:UIControlEventTouchUpInside];
        }
       
    }
    
    if ([sub.subviews count] > 0)
    {
        for (UIView* _su in sub.subviews) {
            [self printSubView:_su];
        }
    }
}

-(void)addSomeElements:(UIViewController *)viewController{
    
    
    UIView *PLCameraView=[self findView:viewController.view withName:@"PLCameraView"];
    
    [self printSubView:PLCameraView];
    
    UIView *bottomBar=[self findView:PLCameraView withName:@"PLCropOverlayBottomBar"];
    UIImageView *bottomBarImageForSave = [bottomBar.subviews objectAtIndex:0];
    //找到重拍按钮
    UIButton *retakeButton=[bottomBarImageForSave.subviews objectAtIndex:0];
    
    
    [retakeButton addTarget:self action:@selector(showOverlay) forControlEvents:UIControlEventTouchUpInside];
   
    
//    [retakeButton setTitle:@"重拍" forState:UIControlStateNormal];  //左下角按钮
//    UIButton *useButton=[bottomBarImageForSave.subviews objectAtIndex:1];
//    [useButton setTitle:@"上传" forState:UIControlStateNormal];  //右下角按钮
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addSomeElements:self.topViewController];
}

- (void)addBounds
{
    
   
    
    float height = [DeviceUtil getDeviceHeight] -54;
    
    
    cameraOverlayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, height)];
    cameraOverlayView.backgroundColor = [UIColor clearColor];
    
    float boundWidth = height*0.7;
    float boundHeight = boundWidth*0.618;
    
    float startX = (320 - boundHeight)/2;
    float startY = (height - boundWidth)/2;
    
    UIColor* boundColor = [UIColor greenColor];
    float boundLineWidth = 1;
    
    UIView* view1 = [[UIView alloc]initWithFrame:CGRectMake(startX, startY, boundLineWidth, boundWidth)];
    UIView* view2 = [[UIView alloc]initWithFrame:CGRectMake(startX, startY, boundHeight, boundLineWidth)];
    
    UIView* view3 = [[UIView alloc]initWithFrame:CGRectMake(startX+boundHeight, startY, boundLineWidth, boundWidth)];
    
    UIView* view4 = [[UIView alloc]initWithFrame:CGRectMake(startX, startY+ boundWidth, boundHeight, boundLineWidth)];
    
    view1.backgroundColor = boundColor;
    view2.backgroundColor = boundColor;
    view3.backgroundColor = boundColor;
    view4.backgroundColor = boundColor;
    
    [cameraOverlayView addSubview:view1];
    [cameraOverlayView addSubview:view2];
    [cameraOverlayView addSubview:view3];
    [cameraOverlayView addSubview:view4];
    
    
    
    
    //UIImageView *cameraOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"camera_overlay.png"]];
	cameraOverlayView.alpha = 0.0f;
    //cameraOverlayView.frame = CGRectMake(0, 0, 320, 480);
	//self.cameraOverlayView = cameraOverlayView;
    
    [self.cameraOverlayView addSubview:cameraOverlayView];
    
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(140, 120,200, 20)];
    label.center = cameraOverlayView.center;
    label.text = descHint;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.transform = CGAffineTransformMakeRotation( M_PI/2 );
    label.numberOfLines = 1;
    [cameraOverlayView addSubview:label];
    
    
    
    
	
	// animate the fade in after the shutter opens
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelay:2.2f];
	cameraOverlayView.alpha = 1.0f;
	[UIView commitAnimations];
}




-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self addBounds];
    
    
    
    
    
    
	
	
}



-(void)takePicture
{
    [super takePicture];
    
    NSLog(@"in take");
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	// override the touches ended method so tapping the screen will take a picture
	//[self takePicture];
}

- (void)viewDidDisappear:(BOOL)animated {
	// make sure to call the same method on the super class!!!
	[super viewDidDisappear:animated];
}



@end

//
//  CoverSegue.m
//  Write2
//
//  Created by mac on 15/7/14.
//  Copyright (c) 2015年 zhjb. All rights reserved.
//

#import "CoverSegue.h"

@implementation CoverSegue

-(void)removeView
{
     UIViewController* dest = self.destinationViewController;
    
    [dest.view removeFromSuperview];
    
}

-(void)perform
{
   UIViewController* dest = self.destinationViewController;
   UIViewController* source =  self.sourceViewController;
    [source.view addSubview:dest.view];
    
    [self performSelector:@selector(removeView) withObject:self afterDelay:5];
    
}

@end

//
//  AGProgressHUD.m
//  Write2
//
//  Created by zhjb on 14-6-9.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "AGProgressHUD.h"
#import "ProgressHUD.h"
#import "AGAppDelegate.h"

@implementation AGProgressHUD




+ (void)showWithStatus:(NSString*)status
{
    [ProgressHUD show:status];
}
+ (void)showSuccessWithStatus:(NSString*)string
{
    [ProgressHUD showSuccess:string];
}
+ (void)showErrorWithStatus:(NSString *)string
{
    [ProgressHUD showError:string];
}

+ (void)dismiss
{
    [ProgressHUD dismiss];
}

@end

//
//  AGProgressHUD.h
//  Write2
//
//  Created by zhjb on 14-6-9.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AGProgressHUD : NSObject

+ (void)showWithStatus:(NSString*)status;
+ (void)showSuccessWithStatus:(NSString*)string;
+ (void)showErrorWithStatus:(NSString *)string;
+ (void)dismiss;

@end

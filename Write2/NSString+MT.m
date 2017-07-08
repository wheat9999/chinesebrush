//
//  NSString+MT.m
//  microtask
//
//  Created by zhjb on 14-1-10.
//  Copyright (c) 2014年 百度中国. All rights reserved.
//

#import "NSString+MT.h"

#import "LogHelper.h"

@implementation NSString (MT)

-(NSString*)getFileNameFromPath
{
    
    
    int loc =  [self rangeOfString:@"/" options:NSBackwardsSearch].location;
    
    if (loc == NSNotFound)
    {
        [LogHelper log:@"Not a path string" as:LogLevelError from:self];
        return self;
    }
    
    return [self substringFromIndex:loc+1];
    
}

-(NSString*)getFileNameFromUrl
{
    //获取文件名字
    NSUInteger loc =   [self rangeOfString:@"_" options:NSBackwardsSearch].location;
    
    if (loc == NSNotFound)
    {
        [LogHelper log:@"Not a url string" as:LogLevelError from:self];
        return self;
    }
    return  [self substringFromIndex:loc+1];
}

-(NSDate*)toStandardDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    
    
    NSDate *destDate= [dateFormatter dateFromString:self];
    
    return destDate;
}

//- (NSString *)base64Encode
//{
//    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
//    //转换到base64
//    data = [GTMBase64 encodeData:data];
//    NSString * base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    return base64String;
//}
//
//- (NSString *)base64Decode
//{
//    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
//    //转换到base64
//    data = [GTMBase64 decodeData:data];
//    NSString * base64String = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    return base64String;
//}

-(UIColor *)getColor
{
    if ([self length] == 0) {
        return nil;
    }
    
        NSString *cString = [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
        
        // String should be 6 or 8 characters
        if ([cString length] < 6) {
            return [UIColor clearColor];
        }
        
        // strip 0X if it appears
        if ([cString hasPrefix:@"0X"])
            cString = [cString substringFromIndex:2];
        if ([cString hasPrefix:@"#"])
            cString = [cString substringFromIndex:1];
        if ([cString length] != 6)
            return [UIColor clearColor];
        
        // Separate into r, g, b substrings
        NSRange range;
        range.location = 0;
        range.length = 2;
        
        //r
        NSString *rString = [cString substringWithRange:range];
        
        //g
        range.location = 2;
        NSString *gString = [cString substringWithRange:range];
        
        //b
        range.location = 4;
        NSString *bString = [cString substringWithRange:range];
        
        // Scan values
        unsigned int r, g, b;
        [[NSScanner scannerWithString:rString] scanHexInt:&r];
        [[NSScanner scannerWithString:gString] scanHexInt:&g];
        [[NSScanner scannerWithString:bString] scanHexInt:&b];
        
        return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];  
    
}
@end

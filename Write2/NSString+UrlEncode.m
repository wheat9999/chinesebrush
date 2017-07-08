//
//  NSString+UrlEncode.m
//  iteststore
//
//  Created by Admin on 13-11-13.
//  Copyright (c) 2013年 Admin. All rights reserved.
//

#import "NSString+UrlEncode.h"

@implementation NSString (UrlEncode)

- (NSString *)urlEncode {
    NSString *str = [self copy];
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    // TODO: use for loop
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    str = [str stringByReplacingOccurrencesOfString:@"\"" withString:@"%22"];
    str = [str stringByReplacingOccurrencesOfString:@"#" withString:@"%23"];
    str = [str stringByReplacingOccurrencesOfString:@"$" withString:@"%24"];
    str = [str stringByReplacingOccurrencesOfString:@"&" withString:@"%26"];
    str = [str stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    str = [str stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
    str = [str stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
    str = [str stringByReplacingOccurrencesOfString:@":" withString:@"%3A"];
    str = [str stringByReplacingOccurrencesOfString:@";" withString:@"%3B"];
    str = [str stringByReplacingOccurrencesOfString:@"<" withString:@"%3C"];
    str = [str stringByReplacingOccurrencesOfString:@"=" withString:@"%3D"];
    str = [str stringByReplacingOccurrencesOfString:@">" withString:@"%3E"];
    str = [str stringByReplacingOccurrencesOfString:@"?" withString:@"%3F"];
    str = [str stringByReplacingOccurrencesOfString:@"@" withString:@"%40"];
    str = [str stringByReplacingOccurrencesOfString:@"[" withString:@"%5B"];
    str = [str stringByReplacingOccurrencesOfString:@"]" withString:@"%5D"];
    str = [str stringByReplacingOccurrencesOfString:@"^" withString:@"%5E"];
    str = [str stringByReplacingOccurrencesOfString:@"`" withString:@"%60"];
    str = [str stringByReplacingOccurrencesOfString:@"{" withString:@"%7B"];
    str = [str stringByReplacingOccurrencesOfString:@"}" withString:@"%7D"];
    str = [str stringByReplacingOccurrencesOfString:@"\\" withString:@"%5C"];
    str = [str stringByReplacingOccurrencesOfString:@"|" withString:@"%7C"];
    return str;
}

@end

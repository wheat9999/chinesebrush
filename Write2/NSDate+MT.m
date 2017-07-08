//
//  NSDate+MT.m
//  microtask
//
//  Created by zhjb on 14-1-8.
//  Copyright (c) 2014年 百度中国. All rights reserved.
//

#import "NSDate+MT.h"

@implementation NSDate (MT)

-(NSString*)toStandardYYYYMMDD
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    
    NSString *destDateString = [dateFormatter stringFromDate:self];
    
    
    return destDateString;
}

-(NSString*)toStandardful
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    
    NSString *destDateString = [dateFormatter stringFromDate:self];
    
    
    return destDateString;
    
}

-(NSString*)toFielName
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss-SSS"];
    
    
    NSString *destDateString = [dateFormatter stringFromDate:self];
    
    
    return destDateString;
}

///获得日期的数字形式
-(int)toIntFormate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    
    
    NSString *destDateString = [dateFormatter stringFromDate:self];
    
    
    return [destDateString intValue];

}


@end

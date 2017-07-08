//
//  DateHelper.m
//  microtask
//
//  Created by Admin on 14-1-8.
//  Copyright (c) 2014年 百度中国. All rights reserved.
//

#import "DateHelper.h"

@implementation DateHelper
+(NSString*) getDateString{
    return [DateHelper getDateStringWithFormat:@"yyyy/MM/dd HH:mm:ss.SSS"];
}

+(NSString*) getDateStringForFileName{
    return [DateHelper getDateStringWithFormat:@"yyyy-MM-dd HH-mm-ss-SSS"];
}

+(NSString*) getDateStringWithFormat: (NSString*) format{
    return [DateHelper getDateStringWithFormat:format forDate:[NSDate date]];
}

+(NSString*) getDateStringWithFormat: (NSString*) format forDate: (NSDate*) date{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:date];
}
@end

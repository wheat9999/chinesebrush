//
//  DateHelper.h
//  microtask
//
//  Created by Admin on 14-1-8.
//  Copyright (c) 2014年 百度中国. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateHelper : NSObject
+(NSString*) getDateString;
+(NSString*) getDateStringForFileName;
+(NSString*) getDateStringWithFormat: (NSString*) format;
+(NSString*) getDateStringWithFormat: (NSString*) format forDate: (NSDate*) date;
@end

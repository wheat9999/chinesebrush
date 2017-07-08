//
//  LogHelper.h
//  microtask
//
//  Created by Admin on 14-1-7.
//  Copyright (c) 2014年 百度中国. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LogLevel){
    LogLevelVerbose = 0,
    LogLevelInfo = 1,
    LogLevelWarning = 2,
    LogLevelError = 3
};

@interface LogHelper : NSObject
+(void) start;
+(void) log:(NSString*) content as: (LogLevel) level fromTag: (NSString*) tag;
+(void) log:(NSString*) content as: (LogLevel) level from: (NSObject*) sender;
+(void) log:(NSString*) content fromTag: (NSString*) tag;
+(void) log:(NSString*) content from: (NSObject*) sender;
+(void) log:(NSString*) formateStr,...;
//+(void) zip;
+(void) close;

@end

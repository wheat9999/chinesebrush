//
//  AppFolderHelper.m
//  microtask
//
//  Created by Admin on 14-1-7.
//  Copyright (c) 2014年 百度中国. All rights reserved.
//

#import "AppFolderHelper.h"
#import "LogHelper.h"

@implementation AppFolderHelper
+(NSString*) getTempFolder{
    return NSTemporaryDirectory();
}

+(NSString*) getDocumentFolder{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

+(NSString*) getLogFolder{
    NSString* logPath = [NSString stringWithFormat:@"%@/Log", [self getDocumentFolder]];
    if(![[NSFileManager defaultManager] fileExistsAtPath:logPath]){
        NSError* error = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:logPath withIntermediateDirectories:YES attributes:nil error:&error];
        if(error != nil){
            [LogHelper log:[NSString stringWithFormat:@"Failed to create log directory: %@", error] as:LogLevelError from:nil];
           
            return nil;
        }
    }
    return logPath;
}
///获取cache目录
+(NSString*)getCacheFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,  NSUserDomainMask, YES);
    return  [paths objectAtIndex:0];
    
}

+(NSString*)getPhotoCachePath
{
    
    NSString* photoCachePath = [[self getCacheFolder] stringByAppendingString:@"/photo"];
    
    
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:photoCachePath])
    {
        [fm createDirectoryAtPath:photoCachePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [LogHelper log:[NSString stringWithFormat:@"photoC ----%@",photoCachePath] from:nil];
    
    
    return photoCachePath;
}


+(NSString*)getLogZipPath
{
    
    return [NSTemporaryDirectory() stringByAppendingString:@"/test.zip"];
}

///获取Mainbundle路径
+(NSString*)getBundlePath:(NSString*)fileName
{
    NSUInteger loc = [fileName rangeOfString:@"." options:NSBackwardsSearch].location;
    
    if (loc != NSNotFound) {
        NSString* path=  [[NSBundle mainBundle] pathForResource:[fileName substringToIndex:loc] ofType:[fileName substringFromIndex:loc+1]];
        
        return path;
    }
    else
    {
        return nil;
    }
    
}
@end

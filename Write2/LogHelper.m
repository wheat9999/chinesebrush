//
//  LogHelper.m
//  microtask
//
//  Created by Admin on 14-1-7.
//  Copyright (c) 2014年 百度中国. All rights reserved.
//

#import "LogHelper.h"
#import "AppFolderHelper.h"
#import "DateHelper.h"
//#import "ZipWriteStream.h"
//#import "ZipFile.h"
//#import <ZipArchive.h>
@implementation LogHelper
const int MAX_TRACE_LOG_FILE = 5;
static NSFileHandle* _handle = nil;
+(void) shrinkLogFolder: (NSString*) folder{
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folder error:nil];
    NSMutableArray* traceLogFiles = [NSMutableArray array];
    if(files != nil){
        //Find all trace files
        for (NSString* file in files) {
            if([file hasPrefix:@"trace-"]){
                [traceLogFiles addObject:file];
            }
        }
        //Count in the new generated file
        int totalFiles = MAX_TRACE_LOG_FILE - 1;
        if(totalFiles < 0) totalFiles = 0;
        
        //Sort by date
        if([traceLogFiles count] >= totalFiles){
            [traceLogFiles sortUsingComparator:^NSComparisonResult(NSString* pathA, NSString* pathB) {
                NSDictionary* fileAttrA = [[NSFileManager defaultManager] attributesOfItemAtPath:[folder stringByAppendingPathComponent:pathA] error:nil];
                NSDate* dateA = fileAttrA == nil ? nil : [fileAttrA fileModificationDate];
                NSDictionary* fileAttrB = [[NSFileManager defaultManager] attributesOfItemAtPath:[folder stringByAppendingPathComponent:pathB] error:nil];
                NSDate* dateB = fileAttrB == nil ? nil : [fileAttrB fileModificationDate];
                return [dateA compare:dateB];
            }];
            
            //Remove old files
            int diff = [traceLogFiles count] - totalFiles;
            for(int i = 0; i < diff; i++){
                NSString* path = [traceLogFiles objectAtIndex:i];
                NSLog(@"Removing old log file: %@", [traceLogFiles objectAtIndex:i]);
                [[NSFileManager defaultManager] removeItemAtPath:[folder stringByAppendingPathComponent:path] error: nil];
            }
        }
    }
}

+(void) start{
    if(_handle == nil){
        //init file logger
        NSString* logFolder = [AppFolderHelper getLogFolder];
        if(logFolder != nil){
            [self shrinkLogFolder: logFolder];
            NSString* logFile = [NSString stringWithFormat:@"%@/trace-%@.log", logFolder, [DateHelper getDateStringForFileName]];
            if(![[NSFileManager defaultManager] fileExistsAtPath:logFile]){
                [[NSFileManager defaultManager] createFileAtPath:logFile contents:nil attributes:nil];
            }
            _handle = [NSFileHandle fileHandleForWritingAtPath:logFile];
        }
    }
}
+(void) close{
    if(_handle != nil){
        [_handle closeFile];
        _handle = nil;
    }
    
}

//+(void) zip{
//    
//    ZipArchive* zipFile = [[ZipArchive alloc]init];
//    
//    NSString* path = [NSString stringWithFormat:@"%@/%@", [AppFolderHelper getTempFolder], @"test.zip" ];
//    
//    [zipFile CreateZipFile2:path];
//    
//    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[AppFolderHelper getLogFolder] error:nil];
//    for(NSString* file in files)
//    {
//        [zipFile addFileToZip:file newname:file];
//    }
//    if([zipFile CloseZipFile2])
//    {
//        NSLog(@"Create zip file success.");
//        
//    }

    
    
//    ZipFile *zipFile = [[ZipFile alloc] initWithFileName:[NSString stringWithFormat:@"%@/%@", [AppFolderHelper getTempFolder], @"test.zip" ]mode:ZipFileModeCreate];
//    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[AppFolderHelper getLogFolder] error:nil];
//    for(NSString* file in files){
//        ZipWriteStream *stream = [zipFile writeFileInZipWithName:file compressionLevel:ZipCompressionLevelDefault];
//        [stream writeData:[NSData dataWithContentsOfFile:[[AppFolderHelper getLogFolder] stringByAppendingPathComponent:file]]];
//        [stream finishedWriting];
//    }
//    [zipFile close];

//}
+(void) log:(NSString*) content fromTag: (NSString*) source{
    [self log:content as: LogLevelInfo fromTag:source];
}

+(void) log:(NSString*) content as:(LogLevel) level fromTag: (NSString*) source{
    if(content == nil) return;
    NSString* fullContent = [NSString stringWithFormat:@"[%@][%@][%@]%@\n", [DateHelper getDateString], [self logLevelDisplayNames][@(level)], source, content];
    NSLog(@"%@", content);
    if(_handle != nil && level >= LogLevelInfo){
        NSData* data =  [fullContent dataUsingEncoding:NSUTF8StringEncoding];
        [_handle seekToEndOfFile];
        [_handle writeData:data];
    }
}

+(void) log:(NSString*) content from: (NSObject*) sender{
    [self log:content as: LogLevelInfo from:sender];
}

+(void) log:(NSString*) content as:(LogLevel) level from: (NSObject*) sender{
    if(sender != nil){
        [self log:content as:level fromTag:NSStringFromClass([sender class])];
    }else{
        [self log:content as:level fromTag:@"NULL"];
    }
}

+(void) log:(NSString*) formateStr,...
{
    if (!formateStr)
        
      return;
    
    va_list arglist;
    
    va_start(arglist, formateStr);
    
    NSString *outStr = [[NSString alloc] initWithFormat:formateStr arguments:arglist];
    
    va_end(arglist);
    
    [self log:outStr from:nil];
}

+(NSDictionary*) logLevelDisplayNames{
    return @{
             @(LogLevelVerbose):@"VERBOSE",
             @(LogLevelInfo):@"INFO",
             @(LogLevelWarning):@"WARNING",
             @(LogLevelError):@"ERROR",
             };
}
@end

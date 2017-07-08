//
//  AppFolderHelper.h
//  microtask
//
//  Created by Admin on 14-1-7.
//  Copyright (c) 2014年 百度中国. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 获取应用文件夹路径的帮助类
@interface AppFolderHelper : NSObject
/// 获取应用临时目录
+(NSString*) getTempFolder;
/// 获取库文件目录
+(NSString*) getDocumentFolder;
/// 获取日志目录
+(NSString*) getLogFolder;

///获取cache目录
+(NSString*)getCacheFolder;

///获取图片保存目录
+(NSString*)getPhotoCachePath;

///获取压缩日志路径
+(NSString*)getLogZipPath;

///获取Mainbundle路径
+(NSString*)getBundlePath:(NSString*)fileName;
@end

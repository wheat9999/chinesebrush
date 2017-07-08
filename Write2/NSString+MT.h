//
//  NSString+MT.h
//  microtask
//
//  Created by zhjb on 14-1-10.
//  Copyright (c) 2014年 百度中国. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MT)

///普通路径中解析文件名
-(NSString*)getFileNameFromPath;

///url中解析文件名
-(NSString*)getFileNameFromUrl;

///文件名转成标准日期
-(NSDate*)toStandardDate;

///// base64编码
//- (NSString *)base64Encode;
//
///// base64解码
//- (NSString *)base64Decode;

-(UIColor*)getColor;
@end

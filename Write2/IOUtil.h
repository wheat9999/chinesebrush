//
//  IOUtil.h
//  microtask
//
//  Created by zhjb on 14-1-14.
//  Copyright (c) 2014年 百度中国. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IOUtil : NSObject

///通用方法，保存图片
+(void)saveImage:(UIImage*)image andAbsPath:(NSString*)path;

///通用方法，删除文件
+(void)delWithAbsPath:(NSString*)path;

///通用方法，获取图像
+(UIImage*)getImageWithAbsPath:(NSString*)path;

///拍照，保存图片
+(NSString*)saveImage:(UIImage*)image;

///根据图片名删除图片
+(void)delImageWithName:(NSString*)name;

///保存头像
+(void)savePortrait:(UIImage*)image;

///获取头像
+(UIImage*)getPortrait;

///调整图片旋转
+ (UIImage *)fixOrientation:(UIImage *)aImage;


@end

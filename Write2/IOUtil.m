//
//  IOUtil.m
//  microtask
//
//  Created by zhjb on 14-1-14.
//  Copyright (c) 2014年 百度中国. All rights reserved.
//

#import "IOUtil.h"
#import "NSDate+MT.h"
#import "LogHelper.h"
#import "AppFolderHelper.h"
#define PORTRAITNAME @"portrait.png"


@implementation IOUtil

+ (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

///通用，保存图片
+(void)saveImage:(UIImage*)image andAbsPath:(NSString*)path
{
    if (image == nil) {
        [LogHelper log:@"image can not nil" as:LogLevelError from:nil];
        return;
    }
    
     [UIImageJPEGRepresentation(image, 1) writeToFile:path atomically:YES];
    
}

///通用，删除文件
+(void)delWithAbsPath:(NSString*)path
{
    NSFileManager* fm = [NSFileManager defaultManager];
    
    if ([fm fileExistsAtPath:path])
    {
         [fm removeItemAtPath:path error:nil];
    }
    
   
}

///通用，获取图像
+(UIImage*)getImageWithAbsPath:(NSString*)path
{
    UIImage* imgPortrait = [[UIImage alloc]initWithContentsOfFile:path];
    
    return imgPortrait;
}


+(NSString*)saveImage:(UIImage*)image
{
    
    NSString* fileName = [[NSDate date]toFielName];
    
    NSString* absPath = [[AppFolderHelper getPhotoCachePath] stringByAppendingFormat:@"/%@.png",fileName];
    
    [self saveImage:image andAbsPath:absPath];
    
 
    return absPath;
}



+(void)delImageWithName:(NSString*)name
{
    NSString* absPath = [[AppFolderHelper getPhotoCachePath] stringByAppendingFormat:@"/%@",name];
    
    [self delWithAbsPath:absPath];
    
}

+(void)savePortrait:(UIImage*)image
{
    NSString* absPath = [[AppFolderHelper getPhotoCachePath] stringByAppendingFormat:@"/%@",PORTRAITNAME];
    
    [self delWithAbsPath:absPath];
    
    NSData *imagedata=UIImagePNGRepresentation(image);
    
    [imagedata writeToFile:absPath atomically:YES];
    

}

+(UIImage*)getPortrait
{
    NSString* absPath = [[AppFolderHelper getPhotoCachePath] stringByAppendingFormat:@"/%@",PORTRAITNAME];
    
    return [self getImageWithAbsPath:absPath];
}


@end

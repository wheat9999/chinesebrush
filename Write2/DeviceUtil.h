//
//  DeviceUtil.h
//  microtask
//
//  Created by zhjb on 14-4-9.
//  Copyright (c) 2014年 百度中国. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceUtil : NSObject

+(float)getIOSVersion;

+(float)getDeviceHeight;

+ (NSString*)getDeviceType;

+(NSString*)getUUID;

+(CGRect)getWinSize;



@end

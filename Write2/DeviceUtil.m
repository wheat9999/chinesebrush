//
//  DeviceUtil.m
//  microtask
//
//  Created by zhjb on 14-4-9.
//  Copyright (c) 2014年 百度中国. All rights reserved.
//

#import "DeviceUtil.h"

#import "sys/utsname.h"

@implementation DeviceUtil

+(float)getIOSVersion
{
    return  [[[UIDevice currentDevice] systemVersion] floatValue];
}

+(float)getDeviceHeight
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    
    return rect.size.height;
}


+ (NSString*)getDeviceType
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    NSDictionary* dic = @
    {
        @"iphone5,1":@"iphone5(移动,联通)",
        @"iphone5,2":@"iphone5(移动,电信,联通)",
        @"iphone4,1":@"iphone4S",
        @"iphone3,1":@"iphone4(移动,联通)",
        @"iphone3,2":@"iphone4(联通)",
        @"iphone3,3":@"iphone4(电信)",
        @"iphone2,1":@"iphone3GS",
        @"iphone1,2":@"iphone3G",
        @"iphone1,1":@"iphone",
        @"ipad1,1":@"ipad 1",
        @"ipad2,1":@"ipad 2(Wifi)",
        @"ipad2,2":@"ipad 2(GSM)",
        @"ipad2,3":@"ipad 2(CDMA)",
        @"ipad2,4":@"ipad 2(32nm)",
        @"ipad2,5":@"ipad mini(Wifi)",
        @"ipad2,6":@"ipad mini(GSM)",
        @"ipad2,7":@"ipad mini(CDMA)",
        @"ipad3,1":@"ipad 3(Wifi)",
        @"ipad3,2":@"ipad 3(CDMA)",
        @"ipad3,3":@"ipad 3(4G)",
        @"ipad3,4":@"ipad 4(Wifi)",
        @"ipad3,5":@"ipad 4(4G)",
        @"ipad3,6":@"ipad 4(CDMA)",
        @"ipod5,1":@"ipod touch 5",
        @"ipod4,1":@"ipod touch 4",
        @"ipod3,1":@"ipod touch 3",
        @"ipod2,1":@"ipod touch 2",
        @"ipod1,1":@"ipod touch"
        };
    
    
    NSString* deviceType = [dic valueForKey:[deviceString lowercaseString] ];
    
    if (deviceType) {
        return deviceType;
    }
    else
    {
        return deviceString;
    }
}

+(NSString*)getUUID
{
//    CFUUIDRef puuid = CFUUIDCreate( nil );
//    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
//    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
//    CFRelease(puuid);
//    CFRelease(uuidString);
//    return result;
    
    
    return [NSString stringWithFormat:@"UUID-%@",  [[[UIDevice currentDevice] identifierForVendor]UUIDString]];
}

+(CGRect)getWinSize
{
    
    return   [[ UIScreen mainScreen ] bounds ];
}
@end

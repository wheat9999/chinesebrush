//
//  MathUtil.m
//  microtask
//
//  Created by zhjb on 14-4-9.
//  Copyright (c) 2014年 百度中国. All rights reserved.
//

#import "MathUtil.h"

#import <math.h>
@class CTGPS;

@implementation MathUtil

+ (float)getDisWithGps1:(CGPoint)gps1 andGps2:(CGPoint)gps2
{
    float R = 6370996.81;
    float  pi = 3.1415926;
    
    float lng1 = gps1.x;
    float lng2 = gps2.x;
    float lat1 = gps1.y;
    float lat2 = gps2.y;
    
    double ar = cos(lat1*pi/180 )*cos(lat2*pi/180)*cos(lng1*pi/180 -lng2*pi/180)+
    sin(lat1*pi/180 )*sin(lat2*pi/180);
    
    
   float dis =   R*acos(ar);
    
    return dis;
}
@end

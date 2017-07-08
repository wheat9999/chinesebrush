//
//  StringUtil.m
//  GameWorld
//
//  Created by zhjb on 14-5-9.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "StringUtil.h"

@implementation StringUtil

+(NSString*)getStringWithInt:(int)value
{
    return [NSString stringWithFormat:@"%d",value];
}


+(NSString*)getFileNameFromPath:(NSString*)pathName
{
    
    
    int loc =  [pathName rangeOfString:@"/" options:NSBackwardsSearch].location;
    
    if (loc == NSNotFound)
    {
        return pathName;
    }
    
    return [pathName substringFromIndex:loc+1];
    
}


@end

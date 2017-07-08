//
//  Env.m
//  GameWorld
//
//  Created by zhjb on 14-5-9.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "Env.h"
@interface Env ()
{
    
    NSDictionary* configDic;
    
    
    NSMutableDictionary* dynDic;
}
@end
@implementation Env

static Env* _instance;
+(Env*)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [self new];
        [_instance initParam];
        
    });
    
    return _instance;
}

-(void)initParam
{
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"API" ofType:@"plist"];
    configDic = [NSDictionary dictionaryWithContentsOfFile:path];
    
    dynDic = [NSMutableDictionary new];
    
    NSDictionary *infoDic = [[NSBundle mainBundle] infoDictionary];
    NSString* appVersion = [infoDic objectForKey:@"CFBundleVersion"];
    NSString* appName = [infoDic objectForKey:@"CFBundleDisplayName"];
    
    [dynDic setValue:appVersion forKey:@"version"];
    [dynDic setObject:appName forKey:@"appname"];
    
}

-(id)getConfigValue:(NSString*)keyPath
{
    return [configDic valueForKeyPath:keyPath];
}

-(void)addDynamicValue:(id)value andKey:(NSString*)key
{
    [dynDic setValue:value forKey:key];
}

-(id)getDyncValue:(NSString*)key
{
    return [dynDic valueForKey:key];
}

-(NSString*)getUrlWithApi:(NSString*)keyPath
{
    NSString* host = [[Env sharedInstance] getConfigValue:@"api_host"];
    NSString* apiKeyPath = [NSString stringWithFormat:@"api.%@",keyPath];
    NSString* api = [self getConfigValue:apiKeyPath];
    
    return  [NSString stringWithFormat:@"%@/%@",host,api];
    
}
@end

//
//  Env.h
//  GameWorld
//
//  Created by zhjb on 14-5-9.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Env : NSObject

+(Env*)sharedInstance;


-(id)getConfigValue:(NSString*)keyPath;

-(void)addDynamicValue:(id)value andKey:(NSString*)key;

-(id)getDyncValue:(NSString*)key;

-(NSString*)getUrlWithApi:(NSString*)keyPath;
@end

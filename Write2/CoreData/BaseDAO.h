//
//  BaseDAO.h
//  DuoYing
//
//  Created by zhjb on 14-5-16.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseDAO : NSObject

+(BaseDAO*)sharedInstance;

-(void)insert:(NSString*)entity andValue:(NSDictionary*)dic;

-(void)update:(NSString*)entity andCondition:(NSDictionary*)condDic andValue:(NSDictionary*)dic;

-(NSArray*)getList:(NSString*)entity andCondition:(NSDictionary*)condDic;

-(NSArray*)getList:(NSString*)entity andCondition:(NSDictionary*)condDic andSort:(NSArray*)sortArray;

-(void)remove:(NSString*)entity andCondition:(NSDictionary*)condDic;
@end

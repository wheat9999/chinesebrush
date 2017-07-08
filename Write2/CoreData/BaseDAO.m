//
//  BaseDAO.m
//  DuoYing
//
//  Created by zhjb on 14-5-16.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "BaseDAO.h"
#import "DataManager.h"
#import <CoreData/CoreData.h>

@implementation BaseDAO


static BaseDAO* _instance;
+(BaseDAO*)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    
    return _instance;
}

-(void)insert:(NSString*)entity andValue:(NSDictionary*)dic
{
     NSManagedObjectContext* context = [DataManager sharedCDataManager].managedObjectContext;
    
    NSManagedObject* item = [NSEntityDescription insertNewObjectForEntityForName:entity inManagedObjectContext:context];
    
    [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
     {
        [item setValue:obj forKey:key];
    }];
    
    [context save:nil];
    
}

-(void)update:(NSString*)entity andCondition:(NSDictionary*)condDic andValue:(NSDictionary*)dic
{
    NSManagedObjectContext* context = [DataManager sharedCDataManager].managedObjectContext;
    
    
    NSArray *fetchResult = [self getList:entity andCondition:condDic];
    
    if ([fetchResult count] == 0) {
        NSLog(@"不存在该记录");
        return;
    }
    
    else
    {
        
        for (NSManagedObject* ex_item in fetchResult)
        {
            [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [ex_item setValue:obj forKey:key];
            }];
        }
        
        [context save:nil];
    }
    
   
}

-(NSArray*)getList:(NSString*)entity andCondition:(NSDictionary*)condDic andSort:(NSArray*)sortArray
{
    
    NSManagedObjectContext* context = [DataManager sharedCDataManager].managedObjectContext;
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entity];
    
    NSMutableString* mutablePre = [NSMutableString new];
    
    [condDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        //只处理整数
        if ([obj isKindOfClass:[NSNumber class]])
        {
            [mutablePre appendFormat:@"%@ == %d and",key,[obj intValue]];
        }
        else if([obj isKindOfClass:[NSString class]])
        {
            [mutablePre appendFormat:@"%@ == '%@' and",key,obj];
        }
        else
        {
            [mutablePre appendFormat:@"%@ == %@ and",key,obj];
            
        }
        
    }];
    
    NSString* pre = [mutablePre substringToIndex:[mutablePre length]-4];
    
    fetchRequest.predicate = [NSPredicate predicateWithFormat:pre];
    
    if (sortArray)
    {
        [fetchRequest setSortDescriptors:sortArray];
    }
    
    
    NSArray *fetchResult = [context executeFetchRequest:fetchRequest error:nil];
    
    return fetchResult;
    
}


-(NSArray*)getList:(NSString*)entity andCondition:(NSDictionary*)condDic
{
    
   return  [self getList:entity andCondition:condDic andSort:nil];
}

-(void)remove:(NSString*)entity andCondition:(NSDictionary*)condDic
{
    NSManagedObjectContext* context = [DataManager sharedCDataManager].managedObjectContext;
    
    
    NSArray *fetchResult = [self getList:entity andCondition:condDic];
    
    if ([fetchResult count] == 0)
    {
        NSLog(@"不存在该记录");
        return;
    }
    else
    {
        
        for (NSManagedObject* delItem in fetchResult)
        {
            [context deleteObject:delItem];
        }
        
        [context save:nil];

    }

}

@end

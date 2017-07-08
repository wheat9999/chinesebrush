//
//  DataManager.h
//  DuoYing
//
//  Created by zhjb on 14-5-16.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseDAO.h"

///CoreData上下文封装类
@interface DataManager : NSObject

+(DataManager*)sharedCDataManager;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)saveContext;

@end

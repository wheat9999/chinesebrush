//
//  StockUtil.h
//  Write2
//
//  Created by zhjb on 14-7-1.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocketUtil.h"


@class BSModel;
@class KLine;

typedef enum
{
    RequestBs = 0,
    RequestKline
}RequestType;

@interface StockUtil : NSObject
{
    void (^finishCallbackBlockBS)(BSModel *);
    
    void (^finishCallbackBlockKLine)(NSArray*);
    
    NSString* bufferedCode;
    
    int num;
    
    int type;
    
    RequestType requestType;
    
    volatile BOOL StockReady;
    
    NSMutableArray* RequestArray;
    
    NSTimer* schedule;
    
    
}

+ (StockUtil *)sharedInstance;


-(void)addQueue:(NSDictionary*)data FinishCallbackBlock:(void(^)(id))block;


-(void)disConnect;

@end

//
//  StockUtil.m
//  Write2
//
//  Created by zhjb on 14-7-1.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "StockUtil.h"
#import "BSModel.h"
#define SOCKET_TIME 0.1


@implementation StockUtil

+ (StockUtil *)sharedInstance {
    static StockUtil *sharedInstance = nil;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
    
}

-(id)init
{
    if (self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(overHQConnection:) name:HQ_CONNECT object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(overBS:) name:BS_SUCC object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(overKLine:) name:KLINE_SUCC object:nil];
        
        finishCallbackBlockBS = nil;
        finishCallbackBlockKLine = nil;
        
        StockReady = YES;
        RequestArray = [NSMutableArray new];
        
        schedule = nil;
        
       
        
    }
    
    return self;
    
}

-(void)overHQConnection:(NSNotification*)noti

{
    if (requestType == RequestBs)
    {
        NSDictionary* dic = @{@"request":@"bs",@"code":bufferedCode};
        [[SocketUtil sharedInstance] sendRequest:dic];
    }
    else
    {
        NSDictionary* dic = @{@"request":@"kline",@"code":bufferedCode,@"num":@(num),@"type":@(type)};
        [[SocketUtil sharedInstance] sendRequest:dic];
        
    }
    
    
}

-(void)overBS:(NSNotification*)noti
{
    BSModel* bs = [noti object];
    
    finishCallbackBlockBS(bs);
    
    [RequestArray removeObjectAtIndex:0];
    StockReady = YES;
    
}

-(void)overKLine:(NSNotification*)noti
{
    NSArray* klineArray = [noti object];
    
    
    finishCallbackBlockKLine(klineArray);
    
    [RequestArray removeObjectAtIndex:0];
    
    StockReady = YES;
}

-(void)getBSModelWithCode:(NSString*)code FinishCallbackBlock:(void (^)(BSModel *))block
{
    finishCallbackBlockBS = block;
    
    if (![SocketUtil sharedInstance].ready)
    {
        bufferedCode = code;
        requestType = RequestBs;
        [[SocketUtil sharedInstance] initSocket];
    }
    else
    {
        
        NSDictionary* dic = @{@"request":@"bs",@"code":code};
        [[SocketUtil sharedInstance] sendRequest:dic];
    }
}

-(void)getKLineWithCode:(NSString*)code andNum:(int)_num andType:(int)_type FinishCallbackBlock:(void (^)(NSArray*))block
{
    finishCallbackBlockKLine = block;
    
    if (![SocketUtil sharedInstance].ready)
    {
        bufferedCode = code;
        num = _num;
        type = _type;
        requestType = RequestKline;
        [[SocketUtil sharedInstance] initSocket];
    }
    else
    {
        NSDictionary* dic = @{@"request":@"kline",@"code":code,@"num":@(num),@"type":@(type)};
        [[SocketUtil sharedInstance] sendRequest:dic];
    }
}

-(void)addQueue:(NSDictionary*)data FinishCallbackBlock:(void(^)(id))block
{
        
    [RequestArray addObject:@{@"data": data,@"block":block}];
    if (schedule == nil) {
        schedule = [NSTimer scheduledTimerWithTimeInterval:SOCKET_TIME target:self selector:@selector(runSchedule) userInfo:nil repeats:YES];
    }
}

-(void)runSchedule
{
    if ([RequestArray count]>0 && StockReady)
    {
        StockReady = NO;
        NSDictionary* dic = [RequestArray objectAtIndex:0];
        
        NSDictionary* data = [dic valueForKey:@"data"];
        id block  = [dic valueForKey:@"block"];
        
        [self getStockDataWithDic:data FinishCallbackBlock:block];
        
        NSLog(@"**************%@--%@**************",[data valueForKey:@"code"],[data valueForKey:@"request"]);
    }
}

-(void)getStockDataWithDic:(NSDictionary*)data FinishCallbackBlock:(void(^)(id))block
{
   
        StockReady = NO;
        NSString* request = [data valueForKey:@"request"];
        
        NSString* code = [data valueForKey:@"code"];
        
        if ([request isEqualToString:@"kline"])
        {
            
            int _num = [[data valueForKey:@"num"] intValue];
            int _type = [[data valueForKey:@"type"] intValue];
            
            [self getKLineWithCode:code andNum:_num andType:_type FinishCallbackBlock:block];
        }
        else if ([request isEqualToString:@"bs"])
        {
            [self getBSModelWithCode:code FinishCallbackBlock:block];
        }
   
}

-(void)disConnect
{
    [RequestArray removeAllObjects];
    [schedule invalidate];
    schedule = nil;
    StockReady = YES;
    [[SocketUtil sharedInstance] close];
}

@end

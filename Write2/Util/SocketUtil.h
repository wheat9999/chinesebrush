//
//  SocketUtil.h
//  Write2
//
//  Created by zhjb on 14-7-1.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#define HQ_CONNECT @"hq_connect"
#define BS_SUCC @"bs_success"
#define KLINE_SUCC @"kline_success"

@interface SocketUtil : NSObject<AsyncSocketDelegate>
{
    AsyncSocket* socket;
    
    NSDictionary* hqIP;
    
    
}
@property(nonatomic,assign)BOOL ready;
@property(nonatomic,assign)BOOL hqConnect;

+ (SocketUtil *)sharedInstance;

- (void)initSocket;


- (void)sendRequest:(NSDictionary*)data;

-(void)close;
@end

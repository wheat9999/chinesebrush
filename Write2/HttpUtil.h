//
//  HttpUtil.h
//  GameWorld
//
//  Created by zhjb on 14-5-10.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import <Foundation/Foundation.h>
#define TIMEOUT 30
#define  MTBOUNDARY @"BoundaryuwYcfA2AIgxqIxA0278"

typedef enum
{
    URLPOST,
    URLGET,
}URLType;

@protocol  HttpUtilDelegate<NSObject>

-(void)httpDidSuccess:(id)data;
-(void)httpDidFail:(NSDictionary*)dic;
-(void)httpLoadingProgress:(int)progress andTotal:(int)total;

@end

@interface HttpUtil : NSObject

@property(nonatomic,strong) void (^finishCallbackBlock)(NSData *);
@property(nonatomic,retain)NSMutableURLRequest* request;
@property(nonatomic,retain)NSURLConnection* connection;
@property(nonatomic,retain)NSMutableData* resultData;
@property(nonatomic,retain)id<HttpUtilDelegate> delegate;
@property(nonatomic,assign)int contentSize;

//统一方法
- (void)getRemoteDataWithUrl:(NSString*)url andUrlType:(URLType)urlType andData:(NSDictionary*)data andFiles:(NSDictionary*)files andJson:(BOOL)isJson andFinishCallbackBlock:(void (^)(NSData *))block andDelegate:(id<HttpUtilDelegate>)delegate;


+(BOOL)netReachable;
@end

//
//  AGHttpUtil.m
//  Write2
//
//  Created by zhjb on 14-6-8.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "AGHttpUtil.h"
#import "Reachability.h"
#import "AGProgressHUD.h"


@implementation AGHttpUtil

-(void)getRemoteDataWithUrl:(NSString *)url andUrlType:(URLType)urlType andData:(NSDictionary *)data andFiles:(NSDictionary *)files andJson:(BOOL)isJson andFinishCallbackBlock:(void (^)(NSData *))block andDelegate:(id<HttpUtilDelegate>)delegate
{
    if (![AGHttpUtil netReachable])
    {
        [AGProgressHUD showErrorWithStatus:@"请检查网络"];
        
        return;
    }
    
    [super getRemoteDataWithUrl:url andUrlType:urlType andData:data andFiles:files andJson:isJson andFinishCallbackBlock:block andDelegate:delegate];
}

+(BOOL)netReachable
{
    if ([Reachability reachabilityForInternetConnection].currentReachabilityStatus == NotReachable)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}
@end

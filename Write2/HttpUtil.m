//
//  HttpUtil.m
//  GameWorld
//
//  Created by zhjb on 14-5-10.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "HttpUtil.h"
#import "NSString+UrlEncode.h"
#import "StringUtil.h"

@implementation HttpUtil
@synthesize finishCallbackBlock = _finishCallbackBlock;
@synthesize request = _request;
@synthesize connection = _connection;
@synthesize resultData = _resultData;
@synthesize delegate = _delegate;
@synthesize contentSize = _contentSize;

- (id)init {
    
    if (self = [super init])
    {
        _request = [NSMutableURLRequest new];
        [_request setTimeoutInterval:TIMEOUT];
        [_request setValue:@"XMLHttpRequest" forHTTPHeaderField: @"X-Requested-With"];
        
        
    }
    return self;
   
}

- (NSString *)paramsEncode:(NSDictionary *)params {
    __block NSString *result = @"";
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        result = [result stringByAppendingFormat:@"%@=%@&",
                  [[key description] urlEncode] ,
                  [[obj description] urlEncode]
                  ];
    }];
    if ([result length] > 0) {
        result = [result substringToIndex:([result length] - 1)];
    }
    return result;
}

- (void)get:(NSString *)url withData:(NSDictionary *)data {
    //self.request = [NSMutableURLRequest new];
    //self.status = CTHTTPApiStatusPrepare;
    
    if (data)
    {
        if([url rangeOfString:@"?"].location == NSNotFound)
        {
            url = [url stringByAppendingFormat:@"?%@",[self paramsEncode:data]];
        }
        else
        {
            url = [url stringByAppendingFormat:@"&%@",[self paramsEncode:data]];
        }
    }
    

    
    [self.request setURL:[NSURL URLWithString:url]];
    [self.request setHTTPMethod:@"GET"];
    
    _connection = [[NSURLConnection new] initWithRequest:_request delegate:self startImmediately:NO];
    [_connection start];
}

//封装http部分的属性部分
- (NSMutableData*)postPropertyWrapper:(NSDictionary*)data
{
    NSMutableData* newBodyData = [NSMutableData new];
    
    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        NSMutableString *resultString = [[NSMutableString alloc]init];
        [resultString appendFormat:@"--%@\r\n",MTBOUNDARY];
        [resultString appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        [resultString appendFormat:@"%@\r\n", obj];
        [newBodyData appendData:[resultString dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    return newBodyData;
}

//判断文件类型，根据需求可以持续增加
- (NSString*)getTypeFromPath:(NSString*)path
{
    NSString* type = nil;
    
    NSString* lowerPath = [path lowercaseString];
    
    if ([lowerPath hasSuffix:@"png"])
    {
        type = @"image/png";
    }
    else if ([lowerPath hasSuffix:@"log"])
    {
        type = @"text/plain";
    }
    else if ([lowerPath hasSuffix:@"txt"])
    {
        type = @"text/plain";
    }
    else if ([lowerPath hasSuffix:@"rar"])
    {
        type = @"application/octet-stream ";
    }
    else if ([lowerPath hasSuffix:@"zip"])
    {
        type = @"application/x-zip-compressed";
    }
    
    
    return type;
}

//封装httpbody里面的文件部分
- (NSMutableData*)postFileWrapper:(NSDictionary*)files
{
    
    NSMutableData* newBodyData = [NSMutableData new];
    
    
    [files enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        NSString* fileName = [StringUtil getFileNameFromPath:obj];
        
        NSString* fileType = [self getTypeFromPath:obj];
        
        NSData* fileData = [NSData dataWithContentsOfFile:obj];
        
        NSMutableString *resultString = [NSMutableString new];
        [resultString appendFormat:@"--%@\r\n",MTBOUNDARY];
        [resultString appendFormat:@"Content-Disposition: form-data; name=\"%@\";filename=\"%@\"\r\n",key,fileName];
        [resultString appendFormat:  @"Content-Type: %@\r\n\r\n",fileType];
        [newBodyData appendData:[resultString dataUsingEncoding:NSUTF8StringEncoding]];
        [newBodyData appendData:fileData];
        [newBodyData appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    return newBodyData;
}


- (void)post:(NSString *)url withData:(NSDictionary *)data withFiles:(NSDictionary *)files
{
    
    // header
    _request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                       timeoutInterval:TIMEOUT];
    
    [_request setHTTPMethod:@"POST"];
    
    NSString* contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", MTBOUNDARY];
    [self.request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    //设置body
    
    NSData* appendFileData = [self postFileWrapper:files];
    
    // NSData* appendProData = [ [CTHTTPApi paramsEncode:data] dataUsingEncoding:NSUTF8StringEncoding];
    NSData* appendProData = [self postPropertyWrapper:data];
    
    
    
    NSMutableData* body = [[NSMutableData alloc]init];
    
    [body appendData:appendProData];
    [body appendData:appendFileData];
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", MTBOUNDARY] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
    NSString *contentLength = [NSString stringWithFormat:@"%d", [body length]];
    [self.request setValue:contentLength forHTTPHeaderField:@"Content-Length"];
    
    [self.request setHTTPBody:body];

    _connection = [[NSURLConnection new] initWithRequest:self.request delegate:self startImmediately:NO];
    [_connection start];
    
}

- (void)post:(NSString *)url withJSON:(NSDictionary *)jsonObject {
   
    
    // header
    _request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                       cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                   timeoutInterval:TIMEOUT];
    
    [_request setHTTPMethod:@"POST"];
    [self.request setURL:[NSURL URLWithString:url]];
    
    
    NSData *jsonRawData = [NSJSONSerialization dataWithJSONObject:jsonObject options:0 error:nil];
    
    [self.request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self.request setHTTPBody:jsonRawData];
    
    
    _connection = [[NSURLConnection new] initWithRequest:self.request delegate:self startImmediately:NO];
    [_connection start];
}

//统一方法
- (void)getRemoteDataWithUrl:(NSString*)url andUrlType:(URLType)urlType andData:(NSDictionary*)data andFiles:(NSDictionary*)files andJson:(BOOL)isJson andFinishCallbackBlock:(void (^)(NSData *))block andDelegate:(id<HttpUtilDelegate>)delegate
{
    
    
    if (urlType == URLGET)
    {
        [self get:url withData:data];
        
    }
    else
    {
        
        if (!isJson)
        {
            [self post:url withData:data withFiles:files];
        }
      
        
    }
    
    _resultData = [NSMutableData new];
    _finishCallbackBlock = block;
    _delegate = delegate;
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_resultData appendData:data];
    
    int current = [_resultData length];
    
    if ([_delegate respondsToSelector:@selector(httpLoadingProgress:andTotal:)])
    {
        [_delegate httpLoadingProgress:current andTotal:_contentSize];
    }
    
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
   
    NSDictionary *dict = [(NSHTTPURLResponse *)response allHeaderFields];
    NSNumber *length = [dict objectForKey:@"Content-Length"];
    _contentSize = [length intValue];
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    if (_finishCallbackBlock)
    { // 如果设置了回调的block，直接调用
        _finishCallbackBlock(_resultData);
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    if ([_delegate respondsToSelector:@selector(httpDidFail:)])
    {
         [_delegate httpDidFail:@{@"error":error}];
    }
    
   
}




@end

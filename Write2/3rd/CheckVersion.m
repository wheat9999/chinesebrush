//
//  CheckVersion.m
//  IknowingiOS
//
//  Created by iknowing_zhaoxu on 13-1-18.
//  Copyright (c) 2013年 上海海知信息技术有限公司. All rights reserved.
//

#import "CheckVersion.h"

#import "JSONKit.h"



@implementation CheckVersion
@synthesize m_strCurrentElement;
@synthesize tempString;

static CheckVersion *checkVersionC = nil;

+(CheckVersion *) sharedController{
    @synchronized(self){
        if(checkVersionC == nil){
            checkVersionC = [[self alloc] init];
        }
    }
    return checkVersionC;
}


//- (void)dealloc
//{
//    [m_strCurrentElement release];
//    [tempString release];
//    [super dealloc];
//}


-(NSMutableDictionary *)requestVersionXML
{
    //请求网络
    NSString *requestString = [NSString stringWithFormat:APP_URL];
    
    // 数据内容转换为UTF8编码，第二个参数为数据长度
    //    NSData *requestData = [NSData dataWithBytes:[requestString UTF8String] length:[requestString length]];
    // 请求的URL地址
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:requestString]];
    //    NSLog(@"%@\n",requestString);
    // 设置请求头声明
    //    [request setValue:@"text/xml" forHTTPHeaderField:@"Content-type"];
    // 执行请求
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    // 输出返回数据
    NSString *dataPayload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSDictionary *jsonData = [dataPayload objectFromJSONString];
    NSArray *infoArray = [jsonData objectForKey:@"results"];
    if ([infoArray count] == 0) {
        return nil;
    }
    dic = [infoArray objectAtIndex:0];
    //    NSString *latestVersion = [dic objectForKey:@"version"];
    //    NSString *releaseNotes = [dic objectForKey:@"releaseNotes"];
    
    return dic;

}

@end

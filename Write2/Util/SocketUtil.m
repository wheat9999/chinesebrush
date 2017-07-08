//
//  SocketUtil.m
//  Write2
//
//  Created by zhjb on 14-7-1.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "SocketUtil.h"
#import "AsyncSocket.h"
#import "MsgWrapper.h"
#import "BSModel.h"
#import "dzhbitstream.h"
#import "KLine.h"

@implementation SocketUtil
@synthesize ready;
@synthesize hqConnect;

+ (SocketUtil *)sharedInstance {
    static SocketUtil *sharedInstance = nil;
    
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedInstance = [[self alloc] init];
        
    });
    
    return sharedInstance;
    
}

- (void)initSocket
{
    srand( (unsigned)time( NULL ) );
    
    NSArray* ips = @[
                     @{@"ip":@"222.73.34.8",@"port":@(12346)},
                     @{@"ip":@"222.73.103.42",@"port":@(12346)},
                     @{@"ip":@"61.151.252.4",@"port":@(12346)},
                     @{@"ip":@"61.151.252.14",@"port":@(12346)}
                     ];
    
    
    NSDictionary* ip = [ips objectAtIndex:rand()%4];
    
  
    
    socket = [[AsyncSocket alloc]initWithDelegate:self];
    
    hqConnect = NO;
    
    [socket connectToHost:[ip valueForKey:@"ip"] onPort:[[ip valueForKey:@"port"] intValue] error:nil];
    
}

- (void)reconnect
{
    
    
    [socket connectToHost:[hqIP valueForKey:@"ip"] onPort:[[hqIP valueForKey:@"port"] intValue] withTimeout:-1 error:nil];
    
}

-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    if (!hqConnect)
    {
        [socket writeData:[MsgWrapper getHQAddress] withTimeout:-1 tag:100];
        NSLog(@"did connect ctr %@:%d",host,port);
    }
    else
        
    {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:HQ_CONNECT object:nil];
        ready = YES;
        NSLog(@"did connect hq %@:%d",host,port);
    }
}


-(void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"disconnect");
    
    ready = NO;
    
    if (hqConnect)
    {
        [self reconnect];
    }
}
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"error");
    
    ready = NO;
    
    
}

-(void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    [socket readDataWithTimeout:-1 tag:tag];
}


-(void)parserBS:(NSData*)data
{
    BSModel* bs = [[BSModel alloc]init];
    
    unsigned char* buffer = ( unsigned char*) [data bytes];
    
    void* x = buffer+7;
    
	bs.lastClose = *(int*)x;
    
    x= buffer+11;
    
    short count = *(short*)x;
    
    if (count != 10)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:BS_SUCC object:bs];
        
        
        return;
    }
    
    
    
    //Poco::StreamCopier::copyStream(str, std::cout);
    
    int p = 13;
    
    for(int i=0;i<10;i++)
    {
        x = buffer +p+i*8;
        void* y = (char*)x+4;
        switch(i)
        {
            case 0:bs.sellPrice5 = *(int*)x;bs.sellVol5 = *(int*)y;break;
            case 1:bs.sellPrice4 = *(int*)x;bs.sellVol4 = *(int*)y;break;
            case 2:bs.sellPrice3 = *(int*)x;bs.sellVol3 = *(int*)y;break;
            case 3:bs.sellPrice2 = *(int*)x;bs.sellVol2 = *(int*)y;break;
            case 4:bs.sellPrice1 = *(int*)x;bs.sellVol1 = *(int*)y;break;
            case 5:bs.buyPrice1 = *(int*)x;bs.buyVol1 = *(int*)y;break;
            case 6:bs.buyPrice2 = *(int*)x;bs.buyVol2 = *(int*)y;break;
            case 7:bs.buyPrice3 = *(int*)x;bs.buyVol3 = *(int*)y;break;
            case 8:bs.buyPrice4 = *(int*)x;bs.buyVol4 = *(int*)y;break;
            case 9:bs.buyPrice5 = *(int*)x;bs.buyVol5 = *(int*)y;break;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BS_SUCC object:bs];
    
   
    
}

-(void)parserKLine:(NSData*)data
{
    unsigned char* buffer = ( unsigned char*) [data bytes];
    
	unsigned short exlen = 1024*10;
	
	char* ptemp = (char*)malloc(exlen*sizeof(char));
	memset(ptemp,0,extend*sizeof(char));
    
	NewExpandKLineData((JAVA_HEAD*)buffer,(JAVA_HEAD*)ptemp,&exlen);
	
    char* p = (char*)ptemp;
    p = p+8;
    short* klinenum = (short*)p;
    
    
    
    
    if(*klinenum == 0)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:KLINE_SUCC object:nil];
        return ;
    }
    
    
    
    p= p+2;
    
    int* item = (int*)p;
    
    NSMutableArray* klineArray = [[NSMutableArray alloc]init];
    
    for(int i = 0;i<*klinenum;i++)
    {
        
        int date = *item;
        
        
        item++;
        int open = *item;
        
        item++;
        int high = *item;
        
        item++;
        int low = *item;
        
        item++;
        int close = *item;
        
        item++;
        int vol = *item;
        
        item++;
        int money = *item;
        
        item++;
        
        KLine* kline = [[KLine alloc]init];
        kline.date = date;
        kline.open = open;
        kline.low = low;
        kline.high = high;
        kline.close = close;
        kline.vol = vol;
        kline.money = money;
        
        [klineArray addObject:kline];
        
       
        
        
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:KLINE_SUCC object:klineArray];
    
    
}



- (void)parserHQAddress:(NSData *)data
{
    Byte* temp = (Byte*) [data bytes];
    
    int beginIndex = -1,length = 0;
    
    
    for (int i = 0; i<100; i++)
    {
        
        unsigned char c = *(temp +i);
        
        if (beginIndex>0)
        {
            if ((c>='0' && c<='9')
                || c == '.' || c == ':')
            {
                length ++;
            }
            else
            {
                break;
            }
        }
        else if (c >='1'&& c <= '9' && i>=10)
        {
            
            beginIndex = i;
            
            length = 1;
        }
    }
    
    
    NSData* validData = [[NSData alloc]initWithBytes:temp+beginIndex length:length];
    
    NSString* s = [[NSString alloc]initWithData:validData encoding:NSUTF8StringEncoding];
    
    NSLog(@"hqaddress is: %@",s);
    
   
   
    
    NSArray* hostSeg =  [s componentsSeparatedByString:@":"];
    NSString* ip = [hostSeg objectAtIndex:0];
    int port = [[hostSeg objectAtIndex:1] intValue];
    
    [socket disconnect];
    
    [socket connectToHost:ip onPort:port withTimeout:-1 error:nil];
    hqIP = @{@"ip":ip,@"port":@(port)};
    hqConnect = YES;
}

-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data
        withTag:(long)tag
{
   
    if (tag == 100)
    {
        
        
        [self parserHQAddress:data];
    }
    //bs
    else if(tag == 200)
    {
        [self parserBS:data];
    }
    
    else if(tag == 300)
    {
        [self parserKLine:data];
    }
}

- (void)sendKLine:(NSString*)code andNum:(int)num andType:(int)type
{
    
   
    NSString* strCode;
    if ([code characterAtIndex:0] == '6')
    {
        //上证指数
        if ([code isEqualToString:@"699999"])
        {
            code = @"000001";
        }
        strCode = [NSString stringWithFormat:@"SH%@",code];
    }
    else
    {
        strCode = [NSString stringWithFormat:@"SZ%@",code];
    }
    
    [socket writeData:[MsgWrapper getKLine:strCode andLength:num andType:type] withTimeout:-1 tag:300];
    
}

- (void)sendBS:(NSString*)code
{
    
    NSString* fullCode = @"";
    
    if ([code characterAtIndex:0] == '6')
    {
        //上证指数
        if ([code isEqualToString:@"699999"])
        {
            code = @"000001";
        }
        fullCode = [NSString stringWithFormat:@"SH%@",code];
    }
    else
    {
        fullCode = [NSString stringWithFormat:@"SZ%@",code];
    }
    [socket writeData:[MsgWrapper get5BS:fullCode] withTimeout:-1 tag:200];
}

- (void)sendRequest:(NSDictionary*)data
{
    NSString* request = [data valueForKey:@"request"];
    
    NSString* code = [data valueForKey:@"code"];
    if ([request isEqualToString:@"bs"])
    {
        [self sendBS:code];
    }
    else if ([request isEqualToString:@"kline"])
    {
        int num = [[data valueForKey:@"num"] intValue];
        int type = [[data valueForKey:@"type"] intValue];
        
        [self sendKLine:code andNum:num andType:type];
    }
}

-(void)close
{
    hqConnect = NO;
    [socket disconnect];
}

@end

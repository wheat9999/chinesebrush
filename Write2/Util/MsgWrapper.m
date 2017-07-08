//
//  MsgWrapper.m
//  GST
//
//  Created by 张 军标 on 13-8-22.
//  Copyright (c) 2013年 张 军标. All rights reserved.
//

#import "MsgWrapper.h"

@implementation MsgWrapper

+(NSData*) getHQAddress
{
    Byte byte[] = {
        123,
        232,
        3,
        0,
        0,
        41,
        0,
        4,
        0,
        49,
        46,
        48,
        48,
        19,
        0,
        57,
        48,
        48,
        49,
        55,
        48,
        57,
        56,
        48,
        48,
        48,
        48,
        48,
        48,
        48,
        48,
        51,
        51,
        51,
        10,
        0,
        105,
        112,
        104,
        111,
        110,
        101,
        99,
        109,
        99,
        99,
        0,
        1
    };
    
    NSData * resp = [[NSData alloc]initWithBytes:byte length:48];
    
    
    return  resp;
}

+(NSData*) getKLine:(NSString*)code andLength:(int)length andType:(int) type
{
      Byte byte[] =
    {
        4,
        128,
        11,
        2,
        0,
        17,
        0,
        8,
        0,
        83,
        72,
        54,
        48,
        48,
        48,
        48,
        48,
        7,
        0,
        0,
        0,
        0,
        180,
        0,
        123,
        147,
        11,
        0,
        0,
        0,
        0
      };
    
    
    
    for(int i = 0;i<8;i++)
    {
        byte[9+i] = [code characterAtIndex:i];
    }
    
    byte[17] = type;
    
    
    byte[22] = length;
    
    
    NSData * resp = [[NSData alloc]initWithBytes:byte length:31];
    
    
    return  resp;
     
    
}

+(NSData*) get5BS:(NSString*)code
{
     Byte byte[] =
    {
	 3,
	156,
	 8,
	 0,
	0,
	 10,
	 0,
	8,
	 0,
	 83,
	 72,
	 54,
	 48,
	 48,
	 48,
	 48,
	 48
};

    
    for(int i = 0;i<8;i++)
    {
        byte[9+i] = [code characterAtIndex:i];
    }
    
    NSData * resp = [[NSData alloc]initWithBytes:byte length:17];
    
    
    return  resp;

}

@end

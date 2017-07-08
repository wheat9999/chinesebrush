//
//  MsgWrapper.h
//  GST
//
//  Created by 张 军标 on 13-8-22.
//  Copyright (c) 2013年 张 军标. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MsgWrapper : NSObject

+(NSData*) getHQAddress;

+(NSData*) getKLine:(NSString*)code andLength:(int)length andType:(int) type;

+(NSData*) get5BS:(NSString*)code;

@end

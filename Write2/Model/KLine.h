//
//  KLine.h
//  GST
//
//  Created by 张 军标 on 13-8-23.
//  Copyright (c) 2013年 张 军标. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KLine : NSObject
@property(nonatomic,assign)int date;
@property(nonatomic,assign)int open;
@property(nonatomic,assign)int low;
@property(nonatomic,assign)int high;
@property(nonatomic,assign)int close;
@property(nonatomic,assign)int vol;
@property(nonatomic,assign)int money;

@property(nonatomic,assign)float energy;

@property(nonatomic,assign)BOOL found;


@end

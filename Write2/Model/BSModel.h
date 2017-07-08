//
//  BSModel.h
//  GST
//
//  Created by zhangjunbiao on 13-8-23.
//  Copyright (c) 2013年 张 军标. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BSModel : NSObject

@property(nonatomic,assign)int lastClose;
@property(nonatomic,assign)int sellPrice5;
@property(nonatomic,assign)int sellVol5;
@property(nonatomic,assign)int sellPrice4;
@property(nonatomic,assign)int sellVol4;
@property(nonatomic,assign)int sellPrice3;
@property(nonatomic,assign)int sellVol3;
@property(nonatomic,assign)int sellPrice2;
@property(nonatomic,assign)int sellVol2;
@property(nonatomic,assign)int sellPrice1;
@property(nonatomic,assign)int sellVol1;
@property(nonatomic,assign)int buyPrice1;
@property(nonatomic,assign)int buyVol1;
@property(nonatomic,assign)int buyPrice2;
@property(nonatomic,assign)int buyVol2;
@property(nonatomic,assign)int buyPrice3;
@property(nonatomic,assign)int buyVol3;
@property(nonatomic,assign)int buyPrice4;
@property(nonatomic,assign)int buyVol4;
@property(nonatomic,assign)int buyPrice5;
@property(nonatomic,assign)int buyVol5;


@end

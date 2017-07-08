//
//  StockGameController.h
//  Write2
//
//  Created by mac on 15/7/11.
//  Copyright (c) 2015年 zhjb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
@class KLine;

@interface StockGameController : UIViewController<GKGameCenterControllerDelegate>
-(void)updateMyViewWithKLine:(KLine*)kline andLastKLine:(KLine*)lastKLine;

@end

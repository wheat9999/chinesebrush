//
//  StockGameView.h
//  Write2
//
//  Created by mac on 15/7/11.
//  Copyright (c) 2015年 zhjb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StockGame.h"
@class StockGameController;

@interface StockGameView : UIView
{
    int index;
    
    int max_low;
    
    int max_high;
    
    int low_graphic;
    
    int high_graphic;
    
    int max_vol;
    int min_vol;
    
    float divY0,height0,divY1,height1;
    
    float divx;
    float divxEnd;
    
    UIColor *colorPositvie;
    
    UIColor *colorNegative;
}

@property(nonatomic,retain)StockGame* stockGame;
@property(nonatomic,assign)BOOL showStockName;
@property(nonatomic,assign)StockGameController* parCtr;


-(int)getIndex;
-(BOOL)move;
-(float)getRate;

@end

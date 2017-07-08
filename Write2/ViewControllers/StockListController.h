//
//  StockListController.h
//  Write2
//
//  Created by zhjb on 14-7-1.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StockListController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray* dataArray;
    
    NSMutableDictionary* timerStockDic;
    
    NSTimer* timerIndex;
    
    NSDictionary* detailData;
    
    NSTimer* timerConnect;
}

-(void)showDetail:(NSDictionary*)data;
-(void)refreshTable;

@end

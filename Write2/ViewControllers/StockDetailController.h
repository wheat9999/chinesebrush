//
//  StockDetailController.h
//  Write2
//
//  Created by zhjb on 14-7-1.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BSModel.h"
#import "StockListController.h"

@interface StockDetailController : UIViewController

@property(nonatomic,retain)NSDictionary* data;
@property(nonatomic,assign)StockListController* delegate;


@end

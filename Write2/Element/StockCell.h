//
//  StockCell.h
//  Write2
//
//  Created by zhjb on 14-7-1.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StockListController.h"

@interface StockCell : UITableViewCell

@property(nonatomic,retain)IBOutlet UILabel* lbCode;
@property(nonatomic,retain)NSDictionary* dic;
@property(nonatomic,assign)StockListController* delegate;
-(void)rank:(NSDictionary*)dic;

@end

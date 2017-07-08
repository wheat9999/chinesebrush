//
//  StockGame.h
//  Write2
//
//  Created by mac on 15/7/11.
//  Copyright (c) 2015年 zhjb. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StockGame : NSObject

@property(nonatomic,copy)NSString* code;
@property(nonatomic,copy)NSString* name;
@property(nonatomic,retain)NSArray* quoteList;

@end

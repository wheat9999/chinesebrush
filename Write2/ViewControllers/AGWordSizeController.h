//
//  AGWordSizeController.h
//  Write2
//
//  Created by zhjb on 14-6-9.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AGMainController;

@interface AGWordSizeController : UIViewController

//  0是文字大小 1是写板大小
@property(nonatomic,assign)int mode;

@property(nonatomic,weak)AGMainController* mainBoardCtrl;
@end

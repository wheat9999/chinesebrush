//
//  SlideController.h
//  Write2
//
//  Created by zhjb on 14-6-7.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduSocialShare_Internal/BDSocialShareSDK_Internal.h>
#define PAGENUM 20
@class AGMainController;

@interface SlideController : UIViewController<UITableViewDataSource,UITableViewDelegate,BDSocialUIDelegate>



@property(nonatomic,assign)AGMainController* mainBoardCtrl;

-(void)refreshAdmin:(NSDictionary*)dic;
@end

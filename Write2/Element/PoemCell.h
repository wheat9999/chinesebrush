//
//  PoemCell.h
//  Write2
//
//  Created by zhjb on 14-6-7.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SlideController;

@interface PoemCell : UITableViewCell<UIAlertViewDelegate>
{
    IBOutlet UILabel* lbTitle;
    IBOutlet UILabel* lbContent;
    
    IBOutlet UIButton* btnAccept;
    
    IBOutlet UIButton* btnReject;
}

@property(nonatomic,strong)NSDictionary* dic;
@property(nonatomic,weak)SlideController* parCtr;
@property(nonatomic,assign)int index;
-(void)rank:(NSDictionary*)dic;

-(void)setAdmin:(BOOL)admin;
@end

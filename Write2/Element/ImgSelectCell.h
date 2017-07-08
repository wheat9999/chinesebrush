//
//  ImgSelectCell.h
//  Write2
//
//  Created by zhjb on 14-6-7.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImgSelectCell : UITableViewCell
{
    IBOutlet UIImageView* imgBg;
    
    IBOutlet UIImageView* imgChk;
    
}



-(void)rank:(NSDictionary*)dic;

@end

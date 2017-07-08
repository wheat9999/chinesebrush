//
//  DYButton.h
//  DuoYing
//
//  Created by zhjb on 14-6-27.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum
{
   DYButtonNormal = 0,
    DYButtonSelect,
    DYButtonDisabled
    
}BtnState;

@interface DYButton : UIButton

@property(nonatomic,assign)BtnState btnState;

@end

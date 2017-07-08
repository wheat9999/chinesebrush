//
//  ImgSelectCell.m
//  Write2
//
//  Created by zhjb on 14-6-7.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "ImgSelectCell.h"


@implementation ImgSelectCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)rank:(NSDictionary *)dic
{
    imgBg.image = [UIImage imageNamed:[dic valueForKey:@"bg"]];
    
    if ([[dic valueForKey:@"chk"] boolValue])
    {
        imgChk.hidden = NO;
    }
    else
    {
        imgChk.hidden = YES;
    }
}

@end

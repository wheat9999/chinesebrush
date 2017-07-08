//
//  AGButton.m
//  Write2
//
//  Created by zhjb on 14-6-9.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "AGButton.h"

@implementation AGButton

-(void)initStyle
{
    
    self.layer.borderWidth = 0.5;
    self.layer.cornerRadius = 5;
    self.layer.borderColor = [UIColor grayColor].CGColor;
    self.backgroundColor = RGB(245, 250, 252);
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setTitleColor:RGB(255, 155, 109) forState:UIControlStateHighlighted];
    
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initStyle];
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        [self initStyle];
        
    }
    return self;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

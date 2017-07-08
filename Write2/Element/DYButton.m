//
//  DYButton.m
//  DuoYing
//
//  Created by zhjb on 14-6-27.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "DYButton.h"

@implementation DYButton
@synthesize btnState = _btnState;

-(void)initMyStyle
{
    self.backgroundColor = RGB(255, 153, 0);
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateDisabled];
    [self setTitleColor:[UIColor yellowColor] forState:UIControlStateSelected];
    
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initMyStyle];
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        
        [self initMyStyle];
        
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

-(void)setBtnState:(BtnState)btnState
{
    _btnState = btnState;
    if (btnState == DYButtonNormal)
    {
        self.enabled = YES;
        self.backgroundColor = RGB(255, 153, 0);
        
        
    }
    else if (btnState == DYButtonSelect)
    {
        self.enabled = YES;
        self.backgroundColor = RGB(255, 0, 0);
        
    }
    else if (btnState == DYButtonDisabled)
    {
        self.enabled = NO;
        self.backgroundColor = [UIColor grayColor];
    }
    
}
@end

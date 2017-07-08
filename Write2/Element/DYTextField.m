//
//  DYTextField.m
//  DuoYing
//
//  Created by zhjb on 14-6-27.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "DYTextField.h"

@implementation DYTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        _borderColor = RGB(116, 116, 116);
		_cornerRadio = 5;
		_borderWidth = 1;
		_lightColor = RGB(243, 168, 51);
		_lightSize = 8;
		_lightBorderColor = RGB(235, 235, 235);
        
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beginEditing:) name:UITextFieldTextDidBeginEditingNotification object:self];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endEditing:) name:UITextFieldTextDidEndEditingNotification object:self];
		[self.layer setCornerRadius:_cornerRadio];
		[self.layer setBorderColor:_borderColor.CGColor];
		[self.layer setBorderWidth:_borderWidth];
		[self setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
		[self setBackgroundColor:[UIColor whiteColor]];
		[self.layer setMasksToBounds:NO];
        
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
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

- (void)beginEditing:(NSNotification*) notification
{
	[[self layer] setShadowOffset:CGSizeMake(0, 0)];
    [[self layer] setShadowRadius:_lightSize];
    [[self layer] setShadowOpacity:1];
    [[self layer] setShadowColor:_lightColor.CGColor];
	[self.layer setBorderColor:_lightBorderColor.CGColor];
}

- (BOOL)endEditing:(BOOL) force
{
	[[self layer] setShadowOffset:CGSizeZero];
    [[self layer] setShadowRadius:0];
    [[self layer] setShadowOpacity:0];
    [[self layer] setShadowColor:nil];
	[self.layer setBorderColor:_borderColor.CGColor];
    
    return YES;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
	CGRect inset = CGRectMake(bounds.origin.x + _cornerRadio*2,
							  bounds.origin.y,
							  bounds.size.width - _cornerRadio*2,
							  bounds.size.height);
    return inset;
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
	CGRect inset = CGRectMake(bounds.origin.x + _cornerRadio*2,
							  bounds.origin.y,
							  bounds.size.width - _cornerRadio*2,
							  bounds.size.height);
    return inset;
}

@end

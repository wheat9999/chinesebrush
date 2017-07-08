//
//  StockCell.m
//  Write2
//
//  Created by zhjb on 14-7-1.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "StockCell.h"
#import "BSModel.h"
#import "WriteUtil.h"

@interface StockCell()
{
   
    
    IBOutlet UILabel* lbLastPrice;
    
    IBOutlet UILabel* lbBuy;
    
    IBOutlet UILabel* lbSell;
    
    IBOutlet UILabel* lbBuyVol;
    
    IBOutlet UILabel* lbSellVol;
    
    IBOutlet UILabel* lbCal;
}

@end

@implementation StockCell
@synthesize dic = _dic;
@synthesize delegate;
@synthesize lbCode;

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
    _dic = dic;
    lbCode.text = [dic valueForKey:@"code"];
    BSModel* bs = [dic valueForKey:@"bs"];
    lbLastPrice.text = [NSString stringWithFormat:@"%.2f",bs.lastClose/100.0];
    
    lbBuy.text = [NSString stringWithFormat:@"%.2f",bs.buyPrice1/100.0];
    lbSell.text = [NSString stringWithFormat:@"%.2f",bs.sellPrice1/100.0];
    lbBuyVol.text = [NSString stringWithFormat:@"%d",bs.buyVol1];
    lbSellVol.text = [NSString stringWithFormat:@"%d",bs.sellVol1];
    lbCal.text = [NSString stringWithFormat:@"%.2f%%",(bs.buyPrice1-bs.lastClose)*100.0/bs.lastClose];
    [WriteUtil setLabelColor:lbCal];
    
    if ([[dic valueForKey:@"state"] intValue] == 2)
    {
        lbLastPrice.textColor = [UIColor redColor];
    }
    else
    {
        lbLastPrice.textColor = RGB(184, 134, 11);
    }
}

-(IBAction)click:(id)sender
{
    [delegate showDetail:_dic];
}
@end

//
//  StockDetailController.m
//  Write2
//
//  Created by zhjb on 14-7-1.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "StockDetailController.h"
#import "BSModel.h"
#import "JSONKit.h"
#import "ProgressHUD.h"


@interface StockDetailController()
{
    IBOutlet UITextField* tfdCode;
    
    IBOutlet UILabel* lbLastPrice;
    
    IBOutlet UILabel* lbSellPrice5;
    IBOutlet UILabel* lbSellVol5;
    
    IBOutlet UILabel* lbSellPrice4;
    IBOutlet UILabel* lbSellVol4;
    
    IBOutlet UILabel* lbSellPrice3;
    IBOutlet UILabel* lbSellVol3;
    
    IBOutlet UILabel* lbSellPrice2;
    IBOutlet UILabel* lbSellVol2;
    
    IBOutlet UILabel* lbSellPrice1;
    IBOutlet UILabel* lbSellVol1;
    
    IBOutlet UILabel* lbBuyPrice1;
    
    IBOutlet UILabel* lbBuyVol1;
    
    IBOutlet UILabel* lbBuyPrice2;
    
    IBOutlet UILabel* lbBuyVol2;
    
    IBOutlet UILabel* lbBuyPrice3;
    
    IBOutlet UILabel* lbBuyVol3;
    
    IBOutlet UILabel* lbBuyPrice4;
    
    IBOutlet UILabel* lbBuyVol4;
    
    IBOutlet UILabel* lbBuyPrice5;
    
    IBOutlet UILabel* lbBuyVol5;
    
    IBOutlet UIButton* btnTrade;
}

@end

@implementation StockDetailController
@synthesize data;
@synthesize delegate;

-(void)updateView
{
    
    if (data == nil)
    {
        lbLastPrice.hidden = YES;
        lbSellPrice1.hidden = YES;
        lbSellPrice2.hidden = YES;
        lbSellPrice3.hidden = YES;
        lbSellPrice4.hidden = YES;
        lbSellPrice5.hidden = YES;
        
        lbSellVol1.hidden = YES;
         lbSellVol2.hidden = YES;
         lbSellVol3.hidden = YES;
         lbSellVol4.hidden = YES;
         lbSellVol5.hidden = YES;
        
        lbBuyPrice1.hidden = YES;
        lbBuyPrice2.hidden = YES;
        lbBuyPrice3.hidden = YES;
        lbBuyPrice4.hidden = YES;
        lbBuyPrice5.hidden = YES;
        
        lbBuyVol1.hidden = YES;
        lbBuyVol2.hidden = YES;
        lbBuyVol3.hidden = YES;
        lbBuyVol4.hidden = YES;
        lbBuyVol5.hidden = YES;
        
        btnTrade.hidden = YES;
        return;
        
    }
    NSString* code = [data valueForKey:@"code"];
    BSModel* bs = [data valueForKey:@"bs"];
    
    tfdCode.text = code;
    lbLastPrice.text = [NSString stringWithFormat:@"%.2f",bs.lastClose/100.0];
    
    lbSellPrice5.text = [NSString stringWithFormat:@"%.2f",bs.sellPrice5/100.0];
    lbSellPrice4.text = [NSString stringWithFormat:@"%.2f",bs.sellPrice4/100.0];
    lbSellPrice3.text = [NSString stringWithFormat:@"%.2f",bs.sellPrice3/100.0];
    lbSellPrice2.text = [NSString stringWithFormat:@"%.2f",bs.sellPrice2/100.0];
    lbSellPrice1.text = [NSString stringWithFormat:@"%.2f",bs.sellPrice1/100.0];
    
    lbSellVol5.text = [NSString stringWithFormat:@"%d",bs.sellVol5];
    lbSellVol4.text = [NSString stringWithFormat:@"%d",bs.sellVol4];
    lbSellVol3.text = [NSString stringWithFormat:@"%d",bs.sellVol3];
    lbSellVol2.text = [NSString stringWithFormat:@"%d",bs.sellVol2];
    lbSellVol1.text = [NSString stringWithFormat:@"%d",bs.sellVol1];
    
    lbBuyPrice1.text = [NSString stringWithFormat:@"%.2f",bs.buyPrice1/100.0];
    lbBuyPrice2.text = [NSString stringWithFormat:@"%.2f",bs.buyPrice2/100.0];
    lbBuyPrice3.text = [NSString stringWithFormat:@"%.2f",bs.buyPrice3/100.0];
    lbBuyPrice4.text = [NSString stringWithFormat:@"%.2f",bs.buyPrice4/100.0];
    lbBuyPrice5.text = [NSString stringWithFormat:@"%.2f",bs.buyPrice5/100.0];
    
    lbBuyVol1.text = [NSString stringWithFormat:@"%d",bs.buyVol1];
    lbBuyVol2.text = [NSString stringWithFormat:@"%d",bs.buyVol2];
    lbBuyVol3.text = [NSString stringWithFormat:@"%d",bs.buyVol3];
    lbBuyVol4.text = [NSString stringWithFormat:@"%d",bs.buyVol4];
    lbBuyVol5.text = [NSString stringWithFormat:@"%d",bs.buyVol5];
    
}

-(void)refreshCode:(NSNotification*)noti
{
    NSDictionary* dic = [noti userInfo];
    
    if ([[dic valueForKey:@"code"] isEqualToString:tfdCode.text])
    {
        data = dic;
        
        [self updateView];
    }
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self updateView];
    
    [[NSNotificationCenter defaultCenter ] addObserver:self selector:@selector(refreshCode:) name:@"BS-REFRESH" object:nil];
}


-(IBAction)back:(id)sender
{
    
    [self.navigationController popViewControllerAnimated:YES];
//    [self dismissViewControllerAnimated:YES completion:^{
//        ;
//    }];
}

-(IBAction)add:(id)sender
{
    NSString* newCode = tfdCode.text;
    
    BOOL isValid = YES;
    
    if ([tfdCode.text length] != 6) {
        isValid = NO;
    }else
    {
    
    for (int i = 0; i<[newCode length]; i++) {
        
      char ch =  [newCode characterAtIndex:i];
        
        if (i == 0)
        {
            if (ch != '6' && ch != '3' && ch != '0')
            {
                isValid = NO;
                break;
            }
        }
        else
        {
            if (ch < '0' || ch >'9') {
                isValid = NO;
                break;
            }
        }
    }
    }
    if (!isValid)
    {
        [ProgressHUD showError:@"错误"];
        
        return;
    }
    
//    NSString* stockStr = Store(@"stock");
//    NSArray* stockArray = [stockStr objectFromJSONString];
    
    NSArray* stockArray = [[NSUserDefaults standardUserDefaults] valueForKey:@"codes"];
    NSMutableArray* dataArray = [NSMutableArray new];
    
    const NSString* myCode = [newCode copy];
    
    [dataArray addObject:@{@"code":myCode,@"state":@"1"}];
    
    for (NSDictionary* dic in stockArray)
    {
        NSMutableDictionary* mutableDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        
        if (![[mutableDic valueForKey:@"code"] isEqualToString:newCode])
        {
            
           [dataArray addObject:mutableDic];
        }
    }
    
   
    [[NSUserDefaults standardUserDefaults] setValue:dataArray forKey:@"codes"];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    NSString* value = [dataArray MyJSONString];
//    
//    Update(@"stock", value);
    [delegate refreshTable];
    [self back:nil];
    
}



-(IBAction)trade:(id)sender
{
    
    NSString* url = [NSString stringWithFormat:@"AMIHexinPro://hexinOwnApplicationCalls?command=gotoHQ&action=GGFS&stockcode=%@&applicationScheme=StockAssistant",tfdCode.text];
    
//    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]])
//    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
        
//    }
//    else
//    {
//        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"未安装同花顺客户端" message:@"请先下载同花顺客户端" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//        [alert show];
//        
//    }

}
@end

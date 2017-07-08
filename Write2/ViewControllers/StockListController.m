//
//  StockListController.m
//  Write2
//
//  Created by zhjb on 14-7-1.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "StockListController.h"
#import "StockUtil.h"
#import "BSModel.h"
#import "KLine.h"
#import "JSONKit.h"
#import "StockCell.h"
#import "StockDetailController.h"
#import "WriteUtil.h"
#define CODE_REFRESH_TIME 3
#define INDEX_FEFRESH_TIME 15

@interface StockListController ()
{
    IBOutlet UILabel* lb000001;
    
    IBOutlet UILabel* lb399001;
    
    IBOutlet UILabel* lb399006;
    
    IBOutlet UILabel* lb399300;
    
    IBOutlet UILabel* lb000001_last;
    
    IBOutlet UILabel* lb399001_last;
    
    IBOutlet UILabel* lb399006_last;
    
    IBOutlet UILabel* lb399300_last;
    
    IBOutlet UILabel* lb000001_cal;
    
    IBOutlet UILabel* lb399001_cal;
    
    IBOutlet UILabel* lb399006_cal;
    
    IBOutlet UILabel* lb399300_cal;
    
    
    
    IBOutlet UITableView* myTableView;
    
    IBOutlet UIButton* btnAdd;
    
   
}

@end

@implementation StockListController



-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateIndexView];
    
    timerIndex =  [NSTimer scheduledTimerWithTimeInterval:INDEX_FEFRESH_TIME target:self selector:@selector(updateIndexView) userInfo:nil repeats:YES];
    
    timerStockDic = [NSMutableDictionary new];
    
    [self refreshTable];
    
}

-(IBAction)showRecommendStock:(id)sender
{
    NSString* url = @"http://115.29.237.213/writeapp/index.php?r=recommend/list";
    
    NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
    
    NSString* response = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    NSDictionary* dic = [response objectFromJSONString];
    
    NSArray* codeArray = [dic valueForKey:@"data"];
    if ([codeArray count] == 0) {
        return;
    }
    
    for (NSDictionary* dic in codeArray)
    {
        NSMutableDictionary* mutableDic = nil;
        
        NSString* code = [dic valueForKey:@"code"];
        
        for (NSMutableDictionary* oldDic in dataArray)
        {
            if([[oldDic valueForKey:@"code"] isEqualToString:code])
            {
                mutableDic = oldDic;
                [mutableDic setValue:@"2" forKey:@"state"];
                
                break;
            }
        }
        
        if (!mutableDic)
        {
            mutableDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                          [dic valueForKey:@"code"],@"code",
                          @"2",@"state",
                          nil];
            [dataArray insertObject:mutableDic atIndex:0];
        }
       
    }

    [self refreshState];
    
}

-(void)refreshState
{
    [myTableView reloadData];
    
    NSMutableArray* codes = [NSMutableArray new];
    
    for (NSDictionary* dic in dataArray)
    {
        [codes addObject:[dic valueForKey:@"code"]];
    }
    
    [self replaceCodeUpdate:codes];
    
}

-(void)refreshTable
{
//    NSString* stockStr = Store(@"stock");
//    NSArray* stockArray = [stockStr objectFromJSONString];
    
    NSArray* stockArray = [[NSUserDefaults standardUserDefaults] valueForKey:@"codes"];
    
    NSMutableArray* newDataArray = [NSMutableArray new];
    
    for (NSDictionary* dic in stockArray)
    {
        NSMutableDictionary* mutableDic = [NSMutableDictionary dictionaryWithDictionary:dic];
        
        NSString* code = [mutableDic valueForKey:@"code"];
        
        for (NSMutableDictionary* oldDic in dataArray)
        {
            if([[oldDic valueForKey:@"code"] isEqualToString:code])
            {
                mutableDic = oldDic;
                break;
            }
        }
        
        [newDataArray addObject:mutableDic];
    }
    
    dataArray = newDataArray;
    
   
    [self refreshState];
}

-(void)updateIndexView
{
    
   
    //上证指数 699999 深圳指数399001 创业板指数399006 沪深300 399300
    
    NSDictionary* data = @{@"request":@"kline",@"code":@"699999",@"num":@(2),@"type":@(7)};
    [[StockUtil sharedInstance] addQueue:data FinishCallbackBlock:^(id  klineArray) {
         KLine* line = [klineArray objectAtIndex:1];
         KLine* line_last = [klineArray objectAtIndex:0];
        
        lb000001.text = [NSString stringWithFormat:@"%.2f",line.close/100.0];
        lb000001_last.text = [NSString stringWithFormat:@"%.2f",line_last.close/100.0];
        lb000001_cal.text = [NSString stringWithFormat:@"%.2f%%",(line.close - line_last.close)*100.0/(float)line_last.close];
        [WriteUtil setLabelColor:lb000001_cal];
        
    }];
    
    data = @{@"request":@"kline",@"code":@"399001",@"num":@(2),@"type":@(7)};
    [[StockUtil sharedInstance] addQueue:data FinishCallbackBlock:^(id  klineArray) {
        KLine* line = [klineArray objectAtIndex:1];
        KLine* line_last = [klineArray objectAtIndex:0];
        
        lb399001.text = [NSString stringWithFormat:@"%.2f",line.close/100.0];
        lb399001_last.text = [NSString stringWithFormat:@"%.2f",line_last.close/100.0];
        lb399001_cal.text = [NSString stringWithFormat:@"%.2f%%",(line.close - line_last.close)*100.0/(float)line_last.close];
        
         [WriteUtil setLabelColor:lb399001_cal];
    }];
    
    data = @{@"request":@"kline",@"code":@"399006",@"num":@(1),@"type":@(7)};
    [[StockUtil sharedInstance] addQueue:data FinishCallbackBlock:^(id  klineArray) {
        KLine* line = [klineArray objectAtIndex:1];
        KLine* line_last = [klineArray objectAtIndex:0];
        
        lb399006.text = [NSString stringWithFormat:@"%.2f",line.close/100.0];
        lb399006_last.text = [NSString stringWithFormat:@"%.2f",line_last.close/100.0];
        lb399006_cal.text = [NSString stringWithFormat:@"%.2f%%",(line.close - line_last.close)*100.0/(float)line_last.close];
         [WriteUtil setLabelColor:lb399006_cal];

    }];
    
    data = @{@"request":@"kline",@"code":@"399300",@"num":@(1),@"type":@(7)};
    [[StockUtil sharedInstance] addQueue:data FinishCallbackBlock:^(id  klineArray) {
        KLine* line = [klineArray objectAtIndex:1];
        KLine* line_last = [klineArray objectAtIndex:0];
        
        lb399300.text = [NSString stringWithFormat:@"%.2f",line.close/100.0];
        lb399300_last.text = [NSString stringWithFormat:@"%.2f",line_last.close/100.0];
        lb399300_cal.text = [NSString stringWithFormat:@"%.2f%%",(line.close - line_last.close)*100.0/(float)line_last.close];
         [WriteUtil setLabelColor:lb399300_cal];

    }];
    
  

}

-(void)disableConnectStating:(NSTimer*)timer
{
    StockCell* cell = [timer userInfo];
    
    [cell.lbCode setTextColor:RGB(242, 186, 52)];
}

-(void)updateConnectionStating:(StockCell*)cell
{
    [cell.lbCode setTextColor:[UIColor redColor]];

    timerConnect = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(disableConnectStating:) userInfo:cell repeats:NO];
}

-(void)updateCode:(NSTimer*)timer
{
    NSString* code;
    if ([timer isKindOfClass:[NSTimer class]])
    {
        code =  [timer userInfo];
    }
    else
    {
        code = (NSString*)timer;
    }
    
    NSDictionary* data = @{@"request":@"bs",@"code":code};
    [[StockUtil sharedInstance] addQueue:data FinishCallbackBlock:^(id  bs) {
        
        
        BSModel* model = (BSModel*)bs;
        
        int index = 0;
        for (NSMutableString* dic in dataArray)
        {
            if ([[dic valueForKey:@"code"] isEqualToString:code])
            {
                [dic setValue:model forKey:@"bs"];
                
                break;
            }
            
            index ++;
        }
        
        if (index<[dataArray count])
        {
            StockCell* cell =(StockCell*) [myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
            
            
            [cell rank:[dataArray objectAtIndex:index]];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"BS-REFRESH" object:nil userInfo:[dataArray objectAtIndex:index]];
            
            [self updateConnectionStating:cell];
        }
        
      
        
        
    }];

}



-(void)replaceCodeUpdate:(NSArray*)codes
{
    NSMutableArray* oldCodes = [NSMutableArray  arrayWithArray: [timerStockDic allKeys]];
    
    [oldCodes removeObjectsInArray:codes];
    
    NSMutableArray* newCodes = [NSMutableArray arrayWithArray:codes];
    [newCodes removeObjectsInArray:[timerStockDic allKeys]];
    
    for (NSString* code in oldCodes)
    {
        NSTimer* timer = [timerStockDic valueForKey:code ];
        
        [timer invalidate];
        [timerStockDic removeObjectForKey:code];
    }
    
    for (NSString* code in newCodes)
    {
        [self updateCode:code];
        
        NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:CODE_REFRESH_TIME target:self selector:@selector(updateCode:) userInfo:code repeats:YES];
        
        [timerStockDic setValue:timer forKey:code];
    }
    
    
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    return TRUE;
    
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    return UITableViewCellEditingStyleDelete;
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSMutableArray* codes = [NSMutableArray new];
    
    int index = 0;
    NSDictionary* item;
    for (NSMutableDictionary* dic in dataArray)
    {
        if (index != indexPath.row)
        {
            item = @{@"code": [[dic valueForKey:@"code"] copy] ,@"state":[[dic valueForKey:@"state"] copy]};
            [codes addObject:item];
        }
        
        index ++;
    }
    
    [[NSUserDefaults standardUserDefaults] setValue:codes forKey:@"codes"];
    [[NSUserDefaults standardUserDefaults] synchronize];
//    NSString* codesStr = [item JSONString];
//    Update(@"stock", codesStr);
    
    [self refreshTable];
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StockCell* cell = [tableView dequeueReusableCellWithIdentifier:@"stockcell"];
    
    NSDictionary* data = [dataArray objectAtIndex:indexPath.row];
    cell.delegate = self;
    [cell rank:data];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary* data = [dataArray objectAtIndex:indexPath.row];
    
    NSString* url = [NSString stringWithFormat:@"AMIHexinPro://hexinOwnApplicationCalls?command=gotoHQ&action=GGFS&stockcode=%@&applicationScheme=StockAssistant",[data valueForKey:@"code"]];
    
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
//    if ( [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:url]])
//    {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
//        
//    }
//    else
//    {
//        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"未安装同花顺客户端" message:@"请先下载同花顺客户端" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//        [alert show];
//        
//    }

}


-(IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
    
    [timerIndex invalidate];
    
    NSArray* stockTimers = [timerStockDic allValues];
    
    for (NSTimer* stockTimer in stockTimers) {
        [stockTimer invalidate];
    }
    
    
    [[StockUtil sharedInstance] disConnect];
}

-(void)showDetail:(NSDictionary*)data
{
    detailData = data;
    
    [self performSegueWithIdentifier:@"detailstock" sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"detailstock"])
    {
        StockDetailController* detail = [segue destinationViewController];
        
        detail.data =  detailData;
        detail.delegate = self;
    }
    else if ([segue.identifier isEqualToString:@"addstock"])
    {
        StockDetailController* detail = [segue destinationViewController];
        detail.delegate = self;
    }
}

@end

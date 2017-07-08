//
//  PoemCell.m
//  Write2
//
//  Created by zhjb on 14-6-7.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "PoemCell.h"
#import "KGModal.h"
#import "SlideController.h"
#import "UIAlertView+Blocks.h"
#import "HttpUtil.h"
#import "JSONKit.h"
#import "AGProgressHUD.h"
#import "AGButton.h"
#import "ProgressHUD.h"
#import "AGNewsUtil.h"

@implementation PoemCell
@synthesize dic = _dic;
@synthesize parCtr = _parCtr;
@synthesize index = _index;

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
    
    lbTitle.text = [dic valueForKey:@"title"];
    lbContent.text = [dic valueForKey:@"content"];
    
    if ([_dic valueForKey:@"time"] == nil && [[_dic valueForKey:@"author"] rangeOfString:@"http"].location != NSNotFound)
    {
        
        lbContent.text = [NSString stringWithFormat:@"%d,%@",_index,lbContent.text];
    }
}

-(UIView*)getDetailView
{
    UIView*  detailView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 260, 400)];
    detailView.backgroundColor = [UIColor whiteColor];
    
    UILabel* title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 260, 40)];
    title.textAlignment = NSTextAlignmentCenter;
    title.text = [_dic valueForKey:@"title"];
    title.font = [UIFont systemFontOfSize:20];
    [detailView addSubview:title];
    
    UIView* split = [[UIView alloc]initWithFrame:CGRectMake(0, 39, 260, 1)];
    split.backgroundColor = [UIColor grayColor];
    [detailView addSubview:split];
    
    UILabel* author = [[UILabel alloc]initWithFrame:CGRectMake(10, 45, 200, 20)];
    author.textAlignment = NSTextAlignmentLeft;
    author.text = [_dic valueForKey:@"author"];
    author.font = [UIFont systemFontOfSize:14];
    [detailView addSubview:author];
    
    UILabel* time = [[UILabel alloc]initWithFrame:CGRectMake(150, 45, 100, 20)];
    time.textAlignment = NSTextAlignmentRight;
    time.text = [[_dic valueForKey:@"time"] substringToIndex:10];
    time.font = [UIFont systemFontOfSize:14];
    [detailView addSubview:time];
    
    
    split = [[UIView alloc]initWithFrame:CGRectMake(0, 69, 260, 1)];
    split.backgroundColor = [UIColor grayColor];
    [detailView addSubview:split];
    
    
    UITextView* tvRule = [[UITextView alloc]initWithFrame:CGRectMake(10, 70, 240, 280)];
    tvRule.text = [_dic valueForKey:@"content"];
    tvRule.backgroundColor = [UIColor whiteColor];
    tvRule.font = [UIFont systemFontOfSize:14];
    tvRule.editable = NO;
    [detailView addSubview: tvRule];
    
    UIButton * btn = [[AGButton alloc]initWithFrame:CGRectMake(0, 350, 260, 40)];
    
    
    //如果是新闻栏目的话特殊处理，新闻栏目没有时间的
    if ([_dic valueForKey:@"time"] == nil && [[_dic valueForKey:@"author"] rangeOfString:@"http"].location != NSNotFound)
    {
        title.font = [UIFont systemFontOfSize:10];
        title.text = [_dic valueForKey:@"content"];
        author.text = [[_dic valueForKey:@"author"] substringToIndex:35];
        [author setFont:[UIFont systemFontOfSize:10]];
        
        time.text = [[_dic valueForKeyPath:@"title"] substringFromIndex:10];
        NSString* url = [_dic valueForKey:@"author"];
        tvRule.text = @"正在加载";
        
        HttpUtil* http = [HttpUtil new];
        
        [ProgressHUD show:@"加载中"];
        [http getRemoteDataWithUrl:url andUrlType:URLGET andData:nil andFiles:nil andJson:NO andFinishCallbackBlock:^(NSData * res) {
            
            [ProgressHUD dismiss];
            
            NSString* response =[[NSString alloc]initWithData:res encoding:NSUTF8StringEncoding];
            
            //gbk编码
            if (response == nil)
            {
            
                
                NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
                response = [[NSString alloc] initWithData:res encoding:gbkEncoding];
                
            }
            
            tvRule.text = [AGNewsUtil getAvailableNews:response];
            
        } andDelegate:nil];
        
        
        
    }
   
    [btn setTitle:@"阅 毕" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(hideModalView:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    [detailView addSubview:btn];
    
    return detailView;
}

-(void)hideModalView:(id)sender
{
    [[KGModal sharedInstance] hide];
}

-(IBAction)showDetial:(id)sender
{
    KGModal* modal = [KGModal sharedInstance];
    modal.modalBackgroundColor = [UIColor clearColor];
    modal.showCloseButton = NO;
    [modal showWithContentView:[self getDetailView]];
    
    
    
}

-(void)setAdmin:(BOOL)admin
{
    if (admin)
    {
        btnAccept.hidden = NO;
        btnReject.hidden = NO;
        lbContent.hidden = YES;
    }
    else
    {
        btnAccept.hidden = YES;
        btnReject.hidden = YES;
        lbContent.hidden = NO;
    }
}

-(IBAction)accetp:(id)sender
{
    
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"原因" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"通过", nil];

    alert.tag = 100;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    
    [alert show];
    
    
    
}

-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if (alertView.cancelButtonIndex == buttonIndex)
    {
        return;
    }
    
    UITextField *tf=[alertView textFieldAtIndex:0];
    NSString* msg = tf.text;
    
    int state;
    
    if (alertView.tag == 100)
    {
        if ([msg length] == 0) {
            msg = @"感谢！";
        }
        state = 1;
    }
    else
    {
        if ([msg length] == 0) {
            msg = @"已经有相同的内容了！";
        }
        state = 2;
        
    }
    
    
    HttpUtil* http = [AGHttpUtil new];
    
    NSString* url = [[Env sharedInstance] getUrlWithApi:@"poem_audit"];
    
    
    NSDictionary* data = @{@"id":[_dic valueForKey:@"id"],
                           @"state":I2S(state),
                           @"msg":msg};
    
    
    [http getRemoteDataWithUrl:url andUrlType:URLGET andData:data andFiles:nil andJson:NO andFinishCallbackBlock:^(NSData * response) {
        
        NSString* res = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        NSDictionary* dic = [res objectFromJSONString];
        
        BOOL valid = [[dic valueForKey:@"valid"] boolValue];
        
        if (!valid)
        {
            [AGProgressHUD showErrorWithStatus:@"失败"];
        }
        else
        {
            [AGProgressHUD dismiss];
             [_parCtr refreshAdmin:_dic];
        }
        
        
    } andDelegate:nil];

   
    [AGProgressHUD showWithStatus:@"等待"];
   
}

-(IBAction)reject:(id)sender
{
    
    
    
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"原因" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"拒绝", nil];
    
    
    alert.tag = 200;
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    
    [alert show];
    
}

@end

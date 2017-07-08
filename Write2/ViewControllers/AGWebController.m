//
//  AGWebController.m
//  Write2
//
//  Created by zhjb on 14-6-23.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "AGWebController.h"
#import "ProgressHUD.h"

@implementation AGWebController
@synthesize strUrl;



-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]]];
    myWebView.delegate = self;
    
    [ProgressHUD show:@"加载中"];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    [ProgressHUD dismiss];
}
-(IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

@end

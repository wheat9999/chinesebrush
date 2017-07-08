//
//  AGFeedBackController.m
//  Write2
//
//  Created by zhjb on 14-6-8.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "AGFeedBackController.h"
#import "AGHttpUtil.h"
#import "DeviceUtil.h"
#import "AGProgressHUD.h"
#import "JSONKit.h"
#import "WriteUtil.h"

@interface AGFeedBackController ()
{
    IBOutlet UITextField* tfdAddress;
    IBOutlet UITextView* tvContent;
    
    IBOutlet UIButton* btnSave;
}

@end

@implementation AGFeedBackController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    btnSave.hidden = YES;
    
    tvContent.layer.borderWidth = 0.5;
    tvContent.layer.borderColor = [RGB(227, 227, 227) CGColor];
    
    [tfdAddress becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

-(IBAction)save:(id)sender
{
    [tfdAddress resignFirstResponder];
    [tvContent resignFirstResponder];
    
    HttpUtil* http = [AGHttpUtil new];
    
    NSString* url = [[Env sharedInstance] getUrlWithApi:@"action_add"];
    
    NSString * content = [NSString stringWithFormat:@"%@-%@",tfdAddress.text,tvContent.text];
    NSDictionary* data = @{@"uuid":[WriteUtil getToken],
                           @"name":@"FeedBack",
                           @"version":[[Env sharedInstance] getDyncValue:@"version"],
                           @"extra":content};
    
    [AGProgressHUD showWithStatus:@"正在上传"];
    [http getRemoteDataWithUrl:url andUrlType:URLGET andData:data andFiles:nil andJson:NO andFinishCallbackBlock:^(NSData * response) {
        
        NSString* res = [[NSString alloc]initWithData:response encoding:NSUTF8StringEncoding];
        NSDictionary* dataDic = [res objectFromJSONString];

        BOOL valid = [[dataDic valueForKey:@"valid"] boolValue];
        
        if (valid)
        {
            
            [AGProgressHUD showSuccessWithStatus:@"成功"];
            
            [self performSelector:@selector(cancel:) withObject:nil afterDelay:1];
            
            
        }
        else{
            [AGProgressHUD showErrorWithStatus:@"失败"];
        }

    } andDelegate:nil];
    
 
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([tvContent.text isEqual:TVHINT]) {
        tvContent.text = @"";
    }
    
}

-(void)textViewDidChange:(UITextView *)textView
{
    
    if ([tvContent.text length]> 0&&![tvContent.text isEqualToString:TVHINT]) {
        btnSave.hidden = NO;
    }
    else
    {
        btnSave.hidden = YES;
    }
}

@end

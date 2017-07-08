//
//  AGCreatePoemController.m
//  Write2
//
//  Created by zhjb on 14-6-7.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "AGCreatePoemController.h"
#import "HttpUtil.h"
#import "DeviceUtil.h"
#import "JSONKit.h"
#import "AGProgressHUD.h"
#import <iflyMSC/IFlySpeechRecognizer.h>
#import <iflyMSC/IFlySpeechRecognizerDelegate.h>
#import <iflyMSC/IFlySpeechConstant.h>
#import "ProgressHUD.h"
#import "WriteUtil.h"



@interface AGCreatePoemController ()
{
    IBOutlet UITextField* tfdAuthor;
    
    IBOutlet UITextField* tfdTitle;
    
    IBOutlet UITextView* tvContent;
    
    IBOutlet UIButton* btnSave;
    
    IFlySpeechRecognizer* _recognizer;
    
    int editView;
}

@end

@implementation AGCreatePoemController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(IFlySpeechRecognizer*)creatRecognize
{
    IFlySpeechRecognizer* iflySpeechRecognizer = [IFlySpeechRecognizer sharedInstance];
    iflySpeechRecognizer.delegate = self;//请不要删除这句,createRecognizer是单例方法，需要重新设置代理
    [iflySpeechRecognizer setParameter:@"iat" forKey:[IFlySpeechConstant IFLY_DOMAIN]];
    [iflySpeechRecognizer setParameter:@"16000" forKey:[IFlySpeechConstant SAMPLE_RATE]];
    [iflySpeechRecognizer setParameter:@"asr.pcm" forKey:[IFlySpeechConstant ASR_AUDIO_PATH]];
    [iflySpeechRecognizer setParameter:@"plain" forKey:[IFlySpeechConstant RESULT_TYPE]];
    
    return iflySpeechRecognizer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    tfdAuthor.text = Store(@"author_name");
    
    [tfdTitle becomeFirstResponder];
    btnSave.hidden = YES;
    
    tvContent.layer.borderWidth = 0.5f;
    tvContent.layer.borderColor = [RGB(227, 227, 227) CGColor];
    
    _recognizer = [self creatRecognize];
    
    
   
    
    
    
}

-(IBAction)recognizer:(id)sender
{
    
    [_recognizer startListening];
    [ProgressHUD show:@"正在识别"];
    
    [tfdAuthor resignFirstResponder];
    [tfdTitle resignFirstResponder];
    [tvContent resignFirstResponder];
    
}


- (void) onError:(IFlySpeechError *) errorCode
{
   
}

/** 识别结果回调
 
 在识别过程中可能会多次回调此函数，你最好不要在此回调函数中进行界面的更改等操作，只需要将回调的结果保存起来。
 
 使用results的示例如下：
 <pre><code>
 - (void) onResults:(NSArray *) results{
 NSMutableString *result = [[NSMutableString alloc] init];
 NSDictionary *dic = [results objectAtIndex:0];
 for (NSString *key in dic)
 {
 //[result appendFormat:@"%@",key];//合并结果
 }
 }
 </code></pre>
 
 @param   results     -[out] 识别结果，NSArray的第一个元素为NSDictionary，NSDictionary的key为识别结果，value为置信度。
 @param   isLast      -[out] 是否最后一个结果
 */
- (void) onResults:(NSArray *) results isLast:(BOOL)isLast
{
    if (isLast)
    {
        [ProgressHUD dismiss];
    }
    
    NSMutableString *resultString = [[NSMutableString alloc] init];
    NSDictionary *dic = results[0];
    for (NSString *key in dic) {
        [resultString appendFormat:@"%@",key];
    }
    NSLog(@"听写结果：%@",resultString);
    
    if (editView == 0) {
        tfdAuthor.text = [tfdAuthor.text stringByAppendingString:resultString];
    }
    else if (editView == 1)
    {
         tfdTitle.text = [tfdTitle.text stringByAppendingString:resultString];
    }
    
    else if (editView == 2)
    {
        if ([tvContent.text isEqual:TVHINT]) {
            tvContent.text = @"";
        }
        tvContent.text = [tvContent.text stringByAppendingString:resultString];
    }
    
    [self judgeCanNext];
    
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
    
    [tfdAuthor resignFirstResponder];
    [tfdTitle resignFirstResponder];
    [tvContent resignFirstResponder];
    HttpUtil* http = [AGHttpUtil new];
    
    NSString* url = [[Env sharedInstance] getUrlWithApi:@"poem_add"];
    
    
    NSDictionary* data = @{@"title":tfdTitle.text,
                           @"content":tvContent.text,
                           @"author":tfdAuthor.text,
                           @"uuid":[WriteUtil getToken],
                           @"extra":@"none"};
    
    [AGProgressHUD showWithStatus:@"正在上传"];
    
    [http getRemoteDataWithUrl:url andUrlType:URLGET andData:data andFiles:nil andJson:NO andFinishCallbackBlock:^(NSData * response) {
        
        NSString* res = [[NSString alloc]initWithData:response encoding:NSUTF8StringEncoding];
        
        NSDictionary* dataDic = [res objectFromJSONString];
        
        BOOL valid = [[dataDic valueForKey:@"valid"] boolValue];
        
        if (valid)
        {
            
            [AGProgressHUD showSuccessWithStatus:@"我们马上回审核哦"];
            
            [self performSelector:@selector(cancel:) withObject:nil afterDelay:1];
            
            Update(@"author_name", tfdAuthor.text);
            Update(@"poem_id", [dataDic objectForKey:@"id"]);
            Update(@"poem_title", tfdTitle.text);
            
        }
        else{
            [AGProgressHUD showErrorWithStatus:@"失败"];
        }
        
    } andDelegate:nil];
    
   
}

-(IBAction)authorBeginEditing:(id)sender
{
    editView = 0;
}

-(IBAction)titleBeginEditing:(id)sender
{
    editView = 1;
}
-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([tvContent.text isEqual:TVHINT]) {
        tvContent.text = @"";
    }
    
    editView = 2;
}


-(void)judgeCanNext
{
    if ([tfdAuthor.text length] > 0 && [tfdTitle.text length] > 0 && [tvContent.text length]> 0&&![tvContent.text isEqualToString:TVHINT]) {
        btnSave.hidden = NO;
    }
    else
    {
        btnSave.hidden = YES;
    }
    
}
-(void)textViewDidChange:(UITextView *)textView
{
    [self judgeCanNext];
   
}

-(IBAction)whileEdit:(id)sender
{
    [self judgeCanNext];
}
@end

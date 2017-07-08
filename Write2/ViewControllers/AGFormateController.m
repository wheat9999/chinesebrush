//
//  AGFormateController.m
//  Write2
//
//  Created by zhjb on 14-6-9.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "AGFormateController.h"
#import "WriteView.h"
#import "AGMainController.h"
#import "AGWordSizeController.h"


@interface AGFormateController ()
{
    IBOutlet UISlider* wordNumSlider;
    
    IBOutlet UILabel* lblinenum;
    
    kWordArrange newArrange;
    
    UIImageView* checkImage;
}

@end

@implementation AGFormateController
@synthesize mainBoardCtrl = _mainBoardCtrl;

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
    
    newArrange = StoreInt(ARRANGE);
    
    UIButton* btn = (UIButton*)[self.view viewWithTag:(100+newArrange)];
    btn.selected = YES;
    
    checkImage = [[UIImageView alloc]initWithFrame: CGRectMake(btn.frame.size.width/2, 0, btn.frame.size.width/2, btn.frame.size.height/2)];
    checkImage.image = [UIImage imageNamed: @"check"];
    checkImage.alpha = 0.8;
    
    [btn addSubview:checkImage];
    
    
    int linenum = StoreInt(LINENUM);
    
    wordNumSlider.value = linenum;
    
    lblinenum.text = [NSString stringWithFormat:@"%d",linenum];
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

- (IBAction)changeArrange:(id)sender
{
    for (int i = 100; i<104; i++)
    {
        UIButton* subBtn = (UIButton*)[self.view viewWithTag:i];
        subBtn.selected = NO;
    }
    
    UIButton* btn = (UIButton*)sender;
    
    btn.selected = YES;
    
    newArrange = btn.tag - 100;
    
    [checkImage removeFromSuperview];
    
    [btn addSubview:checkImage];
    
    
}

- (IBAction)linenumchange:(id)sender
{
    int linenum = (int)wordNumSlider.value;
    
    lblinenum.text = [NSString stringWithFormat:@"%d",linenum];
}

-(IBAction)save:(id)sender
{
   
    
    Update(ARRANGE, I2S(newArrange));
    
    int linenum = (int)wordNumSlider.value;
    
    Update(LINENUM, I2S(linenum));
    
  
    
    [_mainBoardCtrl changeArrange:newArrange andNum:linenum];
    
   [self dismissViewControllerAnimated:YES completion:^{
      
   }];
}


-(IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AGWordSizeController* dest = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"wordsize"])
    {
        dest.mode = 0;
    }
    else
    {
        dest.mode = 1;
    }
    
    dest.mainBoardCtrl = _mainBoardCtrl;
}


@end

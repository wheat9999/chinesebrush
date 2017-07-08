//
//  StockGameController.m
//  Write2
//
//  Created by mac on 15/7/11.
//  Copyright (c) 2015年 zhjb. All rights reserved.
//

#import "StockGameController.h"
#import "JSONKit.h"
#import "StockGame.h"
#import "KLine.h"
#import "StockGameView.h"
#import "ProgressHUD.h"
#define CODENUM 5
#define KEY_TRANS @"key_trans"
#define KEY_MONEY @"key_money"
#define KEY_STOCK @"key_stock"
#import <BaiduSocialShare_Internal/BDSocialShareSDK_Internal.h>

@interface StockGameController ()
{
    StockGame* stockGame;
    
    IBOutlet StockGameView* stockGameView;
    
    
    IBOutlet UILabel* lbTrans;
    
    IBOutlet UILabel* lbStock;
    
    IBOutlet UILabel* lbAssets;
    
    IBOutlet UIImageView* imgStock;
    
    BOOL isOn;
    
    int transDay;
    
    float money;
    
    float stock;
    
    float rate;
    
    IBOutlet UILabel* lbClose;
    
    IBOutlet UILabel* lbRate;
    
    IBOutlet UILabel* lbOpen;
    
    IBOutlet UILabel* lbHigh;
    
    IBOutlet UILabel* lbLow;
    
    IBOutlet UIImageView* imgArrow;
    
    IBOutlet UILabel* lbStockName;
    
    IBOutlet UILabel* lbStockCode;
    
    int step;
}

@end

@implementation StockGameController

-(void)prepareStock
{
    NSLog(@"********prepare stock********");
   NSArray* codeList =  [[BaseDAO sharedInstance] getList:@"Stock" andCondition:@{@"1":@(1)}];
    
    if ([codeList count] > 0)
    {
        [self getCurrentStockGame];
    }
    
    if ([codeList count] < CODENUM)
    {
        NSLog(@"GET CODE");
        
        //iad
//        int youmi = [[[Env sharedInstance] getDyncValue:@"youmi_stock"] intValue];
//        if (rand()%100 < youmi && [codeList count]>0)
//        {
//            
//            [CocoBVideo cBIsHaveVideo:^(int isHaveVideoStatue) {
//                NSLog(@"video is %d",isHaveVideoStatue);
//                
//                [CocoBVideo cBVideoPlay:self cBVideoPlayFinishCallBackBlock:^(BOOL isFinishPlay) {
//                    
//                    NSLog(@"isfinshplay %d",isFinishPlay);
//                } cBVideoPlayConfigCallBackBlock:^(BOOL isLegal) {
//                    NSLog(@"is legal %d",isLegal);
//                }];
//            }];
//        } 

        
        HttpUtil* http = [HttpUtil new];
        NSString* url = @"http://115.29.237.213/Future/task/stockGame/num/10";
        //[ProgressHUD show:@"等待"];
        [http getRemoteDataWithUrl:url andUrlType:URLGET andData:nil andFiles:nil andJson:NO andFinishCallbackBlock:^(NSData *data) {
            NSString* response = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
            
            if (response)
            {
                NSArray* codeArray = [response objectFromJSONString];
                
                for (NSDictionary* codeItem in codeArray)
                {
                    
                    NSString* code = [codeItem valueForKey:@"code"];
                    NSString* name = [codeItem valueForKey:@"name"];
                    
                    
                   NSArray* existCodes = [[BaseDAO sharedInstance] getList:@"Stock" andCondition:@{@"code":code}];
                    
                    if ([existCodes count] > 0)
                    {
                        continue;
                    }
                    
                    NSArray* quoteArray = [codeItem valueForKey:@"quotes"];
                   // NSLog(@"code - %@ name -%@",code,name);
                    
                    [[BaseDAO sharedInstance] insert:@"Stock" andValue:@{@"code":code,@"name":name}];
                    
                    
                    for (NSDictionary* quote in quoteArray)
                    {
                        int  date = [[quote valueForKey:@"date"] intValue];
                        int  open = [[quote valueForKey:@"open"] floatValue]*100;
                        int  close = [[quote valueForKey:@"close"] floatValue]*100;
                        int  high = [[quote valueForKey:@"high"] floatValue]*100;
                        int  low = [[quote valueForKey:@"low"] floatValue]*100;
                        int  vol = [[quote valueForKey:@"money"] floatValue]*100;
                        
                       
                        
                        [[BaseDAO sharedInstance] insert:@"Quote" andValue:
                         @{
                           @"code":code,
                           @"date":@(date),
                           @"open":@(open),
                           @"close":@(close),
                           @"high":@(high),
                           @"low":@(low),
                           @"vol":@(vol)
                           }];
                        
                    }
                    
                    
                }
                //[ProgressHUD dismiss];
                
                if (stockGame == nil && [codeArray count]>0)
                {
                    [self getCurrentStockGame];
                    stockGameView.stockGame = stockGame;
                    [stockGameView setNeedsDisplay];
                }
                
                
            }
        } andDelegate:nil];
    }
    
    
}

-(void)getCurrentStockGame
{
    NSArray* codeList =  [[BaseDAO sharedInstance] getList:@"Stock" andCondition:@{@"1":@(1)}];
    
    NSDictionary* codeItem = [codeList objectAtIndex:0];
    
    stockGame = [StockGame new];
    stockGame.code = [codeItem valueForKey:@"code"];
    stockGame.name = [codeItem valueForKey:@"name"];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    NSArray* quoteList = [[BaseDAO sharedInstance] getList:@"Quote" andCondition:@{@"code":stockGame.code} andSort:sortDescriptors];
    
    NSMutableArray* quotes = [NSMutableArray new];
    for (NSDictionary* quote in quoteList)
    {
        KLine* kline = [KLine new];
        kline.date = [[quote valueForKey:@"date"] intValue];
        kline.open = [[quote valueForKey:@"open"] intValue];
        kline.close = [[quote valueForKey:@"close"] intValue];
        kline.low = [[quote valueForKey:@"low"] intValue];
        kline.high = [[quote valueForKey:@"high"] intValue];
        kline.vol = [[quote valueForKey:@"vol"] intValue];
        
        [quotes addObject: kline];
    }
    
    stockGame.quoteList = quotes;
    
    NSLog(@"%@  -- %@",stockGame.code,stockGame.name);
    
    //取完马上删除
    [self clearStock];
    
    if (money+stock>0)
    {
        [self reportScore:(money+stock) forCategory:@"money"];
    }
    
    
    lbStockCode.text = @"(000000)";
    lbStockName.text = @"等待揭晓";
    step = 0;
    
}


-(void)clearStock
{
    if (stockGame)
    {
        [[BaseDAO sharedInstance] remove:@"Quote" andCondition:@{@"code":stockGame.code}];
        
        [[BaseDAO sharedInstance] remove:@"Stock" andCondition:@{@"code":stockGame.code}];
    }
}

-(void)toRight
{
    if (step <2)
    {
        [ProgressHUD showError:@"看两天行情呗"];
        return;
    }
    money = money+stock;
    stock = 0;
    
    [self updateMyFund];
    
    [self prepareStock];
    isOn = YES;
    stockGameView.stockGame = stockGame;
    rate = [stockGameView getRate];
}

-(void)showStockName
{
    lbStockName.text = stockGame.name;
    
    lbStockCode.text = [NSString stringWithFormat:@"(%@)",stockGame.code];
    
//    stockGameView.showStockName = YES;
//    [stockGameView setNeedsDisplay];
    
}

-(void)updateMyFund
{
    [self storeValue:[NSString stringWithFormat:@"%d",transDay] andKey:KEY_TRANS];
    [self storeValue:[NSString stringWithFormat:@"%.0f",money] andKey:KEY_MONEY];
    [self storeValue:[NSString stringWithFormat:@"%.0f",stock] andKey:KEY_STOCK];
    
    lbTrans.text = [NSString stringWithFormat:@"%d",transDay];
    
    lbStock.text = [NSString stringWithFormat:@"%.0f",stock];
    
    
    float assets = money+stock;
    
   
    
    lbAssets.text = [NSString stringWithFormat:@"%.0f",assets];
    
    if (stock>1000000) {
        lbStock.text = [NSString stringWithFormat:@"%.0f万",stock/10000];
    }
    if (stock>100000000&&stock<10000000000)
    {
        lbStock.text = [NSString stringWithFormat:@"%.2f亿",stock/100000000];
    }
    else if (stock>10000000000)
    {
        lbStock.text = [NSString stringWithFormat:@"%.0f亿",stock/100000000];
    }
    
    if (assets>1000000){
        lbAssets.text = [NSString stringWithFormat:@"%.0f万",assets/10000];
    }
    if (assets>100000000&&assets<10000000000)
    {
        lbAssets.text = [NSString stringWithFormat:@"%.2f亿",assets/100000000];
    }
    else if (assets>10000000000)
    {
         lbAssets.text = [NSString stringWithFormat:@"%.0f亿",assets/100000000];
    }
    
    CGRect rect =  imgStock.frame;
    rect.size.width = 210*stock/(stock+money);
    imgStock.frame = rect;
}

-(void)jugeAgain
{
    if (stock+money< 50000)
    {
        [ProgressHUD showError:@"亏光了，重来吧!"];
        
        stock = 0;
        money = 100000;
        transDay = 0;
    }
}

-(void)calAsset
{
    transDay++;
    stock *= (1+rate);
    
    [self jugeAgain];
    
    [self updateMyFund];
    
    
}
-(void)toLeft
{
    
    if (isOn)
    {
        isOn =  [stockGameView move];
        rate = [stockGameView getRate];
        
        if (rate>0.11 || rate <-0.11)
        {
            [ProgressHUD showError:@"行情有误，无效!"];
        }
        else
        {
        [self calAsset];
        }
        
        if (!isOn) {
            
            [ProgressHUD showSuccess:@"行情已结束"];
            [self showStockName];
            //[self performSelector:@selector(showStockName) withObject:nil afterDelay:1];
            NSLog(@"last");
        }
        
        step++;
    }
    else
    {
        [self toRight];
    }
   

    
}

-(void)toUp
{
    
    if (rate < -0.09)
    {
        [ProgressHUD showError:@"不能减仓"];
        return;
    }
    double asset = stock + money;
    if (stock>asset*0.76)
    {
        stock = asset*0.75;
        
    }
    else if (stock > asset*0.51)
    {
        stock = asset*0.5;
    }
    else if (stock > asset*0.26)
    {
        stock = asset*0.25;
    }
    else
    {
        stock = 0;
    }
    
    money = asset - stock;
    
    [self updateMyFund];
    
}

-(void)toDown
{
    
    if (rate > 0.09)
    {
        [ProgressHUD showError:@"不能加仓"];
        return;
    }
    
    float asset = stock + money;
    if (stock<asset*0.24)
    {
        stock = asset*0.25;
        
    }
    else if (stock < asset*0.49)
    {
        stock = asset*0.5;
    }
    else if (stock < asset*0.74)
    {
        stock = asset*0.75;
    }
    else
    {
        stock = asset;
    }
    
    money = asset - stock;
    
    [self updateMyFund];
}

-(void)storeValue:(NSString*)value andKey:(NSString*)key
{
    [[NSUserDefaults standardUserDefaults] setValue:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)getValueByKey:(NSString*)key
{
   return   [[NSUserDefaults standardUserDefaults] valueForKey:key];
}

-(void)startGame
{
    money = 100000;
    stock = 0;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    stockGameView.parCtr = self;
    
    [self prepareStock];

    stockGameView.stockGame = stockGame;
    

    UISwipeGestureRecognizer* gestRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(toRight)];
    
    gestRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    UISwipeGestureRecognizer* gestLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(toLeft)];
    
    gestLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer* gestUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(toUp)];
    
    gestUp.direction = UISwipeGestureRecognizerDirectionUp;
    
    UISwipeGestureRecognizer* gestDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(toDown)];
    
    gestDown.direction = UISwipeGestureRecognizerDirectionDown;
    
    [self.view addGestureRecognizer:gestRight];
    [self.view addGestureRecognizer:gestLeft];
    [self.view addGestureRecognizer:gestUp];
    [self.view addGestureRecognizer:gestDown];
    
    isOn = YES;
    
    transDay = [[self getValueByKey:KEY_TRANS] intValue];
    
    money = [[self getValueByKey:KEY_MONEY] floatValue];
    
    stock = [[self getValueByKey:KEY_STOCK] floatValue];
    
    money = money+stock;
    stock = 0;
    
    if (transDay == 0) {
        [self startGame];
    }
    
    [self updateMyFund];
    
    if ([self isGameCenterAvailable] ) {
        [self authenticateLocalUser];
        
        [self registerFoeAuthenticationNotification];
        
        
    }
    
    
   BOOL usedStockGame =  [[[NSUserDefaults standardUserDefaults] valueForKey:@"stockgame"] boolValue];
    
    if (!usedStockGame) {
        [self performSegueWithIdentifier:@"segue_cover" sender:self];
        [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:@"stockgame"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    
}
                                           
                                           

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender
{
    [self clearStock];
    [self dismissViewControllerAnimated:YES completion:^{
        ;
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(IBAction)toShare:(id)sender
{
    BDSocialEventHandler result = ^(BD_SOCIAL_RESULT requestResult, NSString *shareType, id response, NSError *error)
    {
        if (requestResult == BD_SOCIAL_SUCCESS) {
            
            [AGProgressHUD showSuccessWithStatus:@"分享成功"];
            
            NSLog(@"%@分享成功",shareType);
        } else if (requestResult == BD_SOCIAL_CANCEL)
        {
            NSLog(@"分享取消");
        } else if (requestResult == BD_SOCIAL_FAIL){
            
            [AGProgressHUD showErrorWithStatus:@"分享失败"];
            
        }
    };
    
    NSString* msg = [NSString stringWithFormat:@"通过%d个交易日，我的财产达到了惊人的%.0f,你也来做一次股神吧！",transDay,(stock+money)];
    
    BDSocialShareContent *content = [BDSocialShareContent shareContentWithDescription:msg url:@"http://www.iautostock.com/appstore/brush_jump.html" title:@"《我爱写字》"];
    
    
    UIImage* img = [UIImage imageNamed:@"AppIcon"];
    
    
    
    [content addImageWithThumbImage:img imageSource:img];
    
    
    BD_SOCIAL_SHARE_MENU_STYLE  style = BD_SOCIAL_SHARE_MENU_STYLE_LIGHT_COLOR;
    
    
    [BDSocialShareTheme setShareMenuStyle:style];
    //[content setShareToAPPContentType:BD_SOCIAL_SHARE_TO_APP_CONTENT_TYPE_IMAGE];
    //[content setShareToAPPContentType:BD_SOCIAL_SHARE_TO_APP_CONTENT_TYPE_WEBPAGE];
    
    [BDSocialShareSDK_Internal showShareMenuWithShareContent:content displayPlatforms:@[kBD_SOCIAL_SHARE_PLATFORM_SINAWEIBO,kBD_SOCIAL_SHARE_PLATFORM_QQWEIBO,kBD_SOCIAL_SHARE_PLATFORM_RENREN,kBD_SOCIAL_SHARE_PLATFORM_KAIXIN,kBD_SOCIAL_SHARE_PLATFORM_WEIXIN_SESSION,kBD_SOCIAL_SHARE_PLATFORM_WEIXIN_TIMELINE,kBD_SOCIAL_SHARE_PLATFORM_SMS,kBD_SOCIAL_SHARE_PLATFORM_EMAIL,kBD_SOCIAL_SHARE_PLATFORM_COPY] hideMultiShare:NO supportedInterfaceOrientations:UIInterfaceOrientationMaskAllButUpsideDown isStatusBarHidden:NO targetViewForPad:self.view uiDelegate:self result:result];
}

//###############
- (BOOL) isGameCenterAvailable
{
    Class gcClass = (NSClassFromString(@"GKLocalPlayer"));
    NSString *reqSysVer = @"4.1";
    NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
    BOOL osVersionSupported = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
    
    return (gcClass && osVersionSupported);
}

- (void)authenticateLocalUser{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            [self presentViewController:viewController animated:YES completion:nil];
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                // Get the default leaderboard identifier.
                
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    
                    if (error != nil) {
                        NSLog(@"%@", [error localizedDescription]);
                    }
                    else{
                        
                    }
                }];
            }
            
            else{
                
            }
        }
    };
    
}

- (void)registerFoeAuthenticationNotification{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(authenticationChanged) name:GKPlayerAuthenticationDidChangeNotificationName object:nil];
}

- (void)authenticationChanged{
    if([GKLocalPlayer localPlayer].isAuthenticated){
        
    }else{
        
    }
}


- (void) reportScore: (int64_t) score forCategory: (NSString*) category{
    GKScore *scoreReporter = [[GKScore alloc] initWithCategory:category];
    
    scoreReporter.value = score;
    [scoreReporter reportScoreWithCompletionHandler:^(NSError *error) {
        if(error != nil){
            NSLog(@"递交失败");
            //未能提交得分，需要保存下来后继续提交
            ;
        }else{
            NSLog(@"提交成功");
        }
    }];
}


- (IBAction)showGameCenter{
    GKGameCenterViewController *gameView = [[GKGameCenterViewController alloc] init];
    if(gameView != nil){
        gameView.gameCenterDelegate = self;
        
        [gameView setLeaderboardCategory:@"com.xxxx.test"];
        [gameView setLeaderboardTimeScope:GKLeaderboardTimeScopeAllTime];
        
        [self presentViewController:gameView animated:YES completion:^{
            
        }];
    }
}

- (void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)updateMyViewWithKLine:(KLine*)kline andLastKLine:(KLine*)lastKLine
{
    NSString* high = [NSString stringWithFormat:@"%.2f",kline.high/100.0];
    NSString* low = [NSString stringWithFormat:@"%.2f",kline.low/100.0];
    NSString* open = [NSString stringWithFormat:@"%.2f",kline.open/100.0];
    NSString* close = [NSString stringWithFormat:@"%.2f",kline.close/100.0];

    if (!kline || !lastKLine) {
        rate = 0;
    }
    else
    {
       rate = (kline.close-lastKLine.close)/(float)lastKLine.close;
    }
    
    NSString* prefix = kline.close>lastKLine.close?@"+":@"";
    NSString* strRate = [NSString stringWithFormat:@"%@%.2f%%",prefix,rate*100];
    
    lbRate.text = strRate;
    
    lbHigh.text = high;
    
    lbLow.text = low;
    
    lbOpen.text = open;
    
    lbClose.text = close;
    
    UIColor* positiveColor =  [UIColor colorWithRed:227/255.0 green:0/255.0 blue:0/255.0 alpha:1];
    UIColor* negativeColor = [UIColor colorWithRed:0/255.0 green:111/255.0 blue:5/255.0 alpha:1];
    UIColor* whieColor = [UIColor colorWithRed:251/255.0 green:251/255.0 blue:251/255.0 alpha:1];
    
    if (kline.close > lastKLine.close)
    {
        imgArrow.hidden = NO;
        imgArrow.image = [UIImage imageNamed:@"sg_arrow1"];
        lbClose.textColor =  positiveColor;
        lbRate.textColor =  positiveColor;
    }
    else if (kline.close < lastKLine.close)
    {
        imgArrow.hidden = NO;
        imgArrow.image = [UIImage imageNamed:@"sg_arrow2"];
        lbClose.textColor =  negativeColor;
        lbRate.textColor =  negativeColor;
    }
    else
    {
        imgArrow.hidden = YES;
        lbClose.textColor = whieColor;
        lbRate.textColor = whieColor;
    }
    
    
}
@end

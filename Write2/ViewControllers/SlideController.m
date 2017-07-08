//
//  SlideController.m
//  Write2
//
//  Created by zhjb on 14-6-7.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "SlideController.h"
#import "DeviceUtil.h"
#import "AGMainController.h"
#import "ImgSelectCell.h"
#import "BaseDAO.h"
#import "AGMainController.h"
#import "PoemCell.h"
#import "IOUtil.h"
#import "HttpUtil.h"
#import "JSONKit.h"
#import "UIAlertView+Blocks.h"
#import "AGProgressHUD.h"
#import "EGORefreshTableHeaderView.h"
#import <BaiduSocialShare_Internal/BDSocialShareSDK_Internal.h>
#import "UIActionSheet+Blocks.h"
#import "AGFormateController.h"
#import "AGWebController.h"
typedef enum
{
    tableTypeBrush = 0,
    tableTypeBg,
    tableTypeWrite,
    tableTypePoem
    
}TableType;


typedef enum
{
    poemSearch,
    poemView,
    poemAdmin
    
}PoemListType;

@interface SlideController ()
{
    IBOutlet UIScrollView* myScrollView;
    
    NSMutableArray* brushArray;
    
    NSMutableArray* bgArray;
    
    NSMutableArray* writeArray;
    
    NSMutableArray* poemArray;
    
    NSMutableArray* poemSearchArray;
    
    NSMutableArray* poemAdminArray;
    
    NSMutableArray* myPoemArray;
    
    TableType tableType;
    
    IBOutlet UITableView* tableSetting;
    
    IBOutlet UITableView* tablePoem;
    
    NSMutableArray* myArray;
    
    IBOutlet UITextField* tfdSearch;
    
    EGORefreshTableHeaderView *_refreshHeaderView;
	
	//  Reloading var should really be your tableviews datasource
	//  Putting it here for demo purposes
	BOOL _reloading;
    
    IBOutlet UIButton* btnRight;
    
    PoemListType poemListType;
    
    BOOL isLastPage;
    
    BOOL isViewLastPage;
    
    IBOutlet UIView* docPage;
    
    
    IBOutlet UIImageView *num_1;
    IBOutlet UIImageView *num_2;
    IBOutlet UIImageView *num_3;
    
    BOOL downLoading;
    
    int selectRow;
    
    
    IBOutlet UILabel* lbVersion;
    
    IBOutlet UIButton* btnGame;
    
    IBOutlet UIButton* btnMap;
    
}

@end

@implementation SlideController
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
    
    myScrollView.contentSize = CGSizeMake([DeviceUtil getWinSize].size.width*3, myScrollView.frame.size.height);
    myScrollView.frame = Rect(0, 0, [DeviceUtil getWinSize].size.width, myScrollView.frame.size.height);
    
    
    UISwipeGestureRecognizer *oneFingerSwipeDown =
    
    [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(toMainView:)];
    
    [oneFingerSwipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    
    [[self view] addGestureRecognizer:oneFingerSwipeDown];
    
    tableType = tableTypeBrush;
    
    /*********************************/
    brushArray = [NSMutableArray new];
    int selectBrush = StoreInt(BRUSHMODE);
    for (int i = 0; i<5; i++)
    {
        NSString* imgName = [NSString stringWithFormat:@"brush_%d",i];
        
        NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:imgName,@"bg", nil];
        
        if (i == selectBrush)
        {
            [dic setValue:@(YES) forKey:@"chk"];
        }
        [brushArray addObject:dic];
    }
    
    /*********************************/
    bgArray = [NSMutableArray new];
    int selectPanel = StoreInt(PANNELBG);
    for (int i = 0; i<7; i++)
    {
        NSString* imgName = [NSString stringWithFormat:@"pannel_bg%d",i];
        
        NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:imgName,@"bg", nil];
        
        if (i == selectPanel)
        {
            [dic setValue:@(YES) forKey:@"chk"];
        }
        [bgArray addObject:dic];
    }
    
    /*********************************/
    writeArray = [NSMutableArray new];
    int selectWrite = StoreInt(WRITEBG);
    for (int i = 0; i<4; i++)
    {
        NSString* imgName = [NSString stringWithFormat:@"write_bg%d",i];
        
        NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:imgName,@"bg", nil];
        
        if (i == selectWrite)
        {
            [dic setValue:@(YES) forKey:@"chk"];
        }
        [writeArray addObject:dic];
    }
    
    /******************************/
    poemArray = [NSMutableArray new];
    
    poemSearchArray = [NSMutableArray new];
    
    poemAdminArray = [NSMutableArray new];
    
    poemListType = poemView;
    [self sendRequestWith:@"*" andoffset:0 andlimit:PAGENUM];
    
    
    myScrollView.contentOffset = CGPointMake(320, 0);
    
    myArray = brushArray;
    
    
    if (_refreshHeaderView == nil)
    {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - tablePoem.bounds.size.height, self.view.frame.size.width, tablePoem.bounds.size.height)];
		view.delegate = self;
		[tablePoem addSubview:view];
		_refreshHeaderView = view;
		
		
	}
	
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
    
    
    tableSetting.layer.borderWidth = 0.5;
    tableSetting.layer.borderColor = [UIColor grayColor].CGColor;
    
    tablePoem.layer.borderWidth = 0.5;
    tablePoem.layer.borderColor = [UIColor grayColor].CGColor;
    
    
    tableSetting.scrollsToTop = NO;
    tablePoem.scrollsToTop = YES;
    
    
    lbVersion.text = [NSString stringWithFormat:@"%@ V%@",
                      [[Env sharedInstance] getDyncValue:@"appname"],
                      [[Env sharedInstance] getDyncValue:@"version"]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadConf) name:@"CONF" object:nil];
    
}

-(void)loadConf
{
    if ([[[Env sharedInstance] getDyncValue:@"stock"] boolValue])
    {
        btnGame.hidden = NO;
        
        
    }
    else
    {
        btnGame.hidden = YES;
        
        
    }
    
    if ([[[Env sharedInstance] getDyncValue:@"map"] boolValue])
    {
        btnMap.hidden = NO;
        
        
    }
    else
    {
        btnMap.hidden = YES;
        
        
    }
}


-(IBAction)toStockGame:(id)sender
{
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"StockGame" bundle:nil];
    
    UIViewController* ctr = [sb instantiateInitialViewController];
    
    [self presentViewController:ctr animated:YES completion:^{
        ;
    }];
    
}

-(IBAction)toMap:(id)sender
{
    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Map" bundle:nil];
    
    UIViewController* ctr = [sb instantiateInitialViewController];
    
    [self presentViewController:ctr animated:YES completion:^{
        ;
    }];
    
}


- (void)sendRequestWith:(NSString*)keyword andoffset:(int)offset andlimit:(int)limit
{
    if (!_reloading && !downLoading)
    {
         [AGProgressHUD showWithStatus:@"稍等"];
    }
    downLoading = NO;
    
    HttpUtil* http = [AGHttpUtil new];
    
    NSString* url = [[Env sharedInstance] getUrlWithApi:@"poem_search"];
    if (poemListType == poemAdmin) {
        url = [[Env sharedInstance] getUrlWithApi:@"poem_draft"];
    }
    
    if ([[btnRight titleForState:UIControlStateNormal] isEqualToString:@"新闻"])
    {
        url = @"http://115.29.237.213/news/index.php?r=news/search";
    }
    
    
    
    if (poemListType == poemAdmin)
    {
        myPoemArray = poemAdminArray;
    }
    else if (poemListType == poemView)
    {
        myPoemArray = poemArray;
        
        keyword = @"*";
    }
    else
    {
        myPoemArray = poemSearchArray;
    }
    
    
    
    
    NSDictionary* data = @{@"keyword":keyword,
                           @"offset":I2S(offset),
                           @"limit":I2S(limit)};
    
    
    [http getRemoteDataWithUrl:url andUrlType:URLGET andData:data andFiles:nil andJson:NO andFinishCallbackBlock:^(NSData * response) {
        
        [AGProgressHUD dismiss];
        NSString* res = [[NSString alloc]initWithData:response encoding:NSUTF8StringEncoding];
        
        NSDictionary* dataDic = [res objectFromJSONString];
        
        NSArray* dicArray = [dataDic valueForKey:@"data"];
        
        
        if (offset == 0)
        {
            [myPoemArray removeAllObjects];
        }
        
        for (NSDictionary* dic in dicArray)
        {
            if ([[btnRight titleForState:UIControlStateNormal] isEqualToString:@"新闻"])
            {
                NSDictionary* newDic = @{@"title":[dic valueForKey:@"time"],@"content":[dic valueForKey:@"title"],@"author":[dic valueForKey:@"url"]};
                [myPoemArray addObject:newDic];
            }
            else
            {
            
            [myPoemArray addObject:dic];
            }
        }
        
        if ([dicArray count] < PAGENUM)
        {
            isLastPage = YES;
        }
        else
        {
            isLastPage = NO;
        }
        
        if (poemListType == poemView)
        {
            isViewLastPage = isLastPage;
        }

        
        [tablePoem performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        
        if(_reloading)
        {
             [self doneLoadingTableViewData];
        }
        
        
    } andDelegate:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    if ([segue.identifier isEqualToString:@"modalweb"]) {
        AGWebController* dest = segue.destinationViewController;
        
        
        int row = [tablePoem indexPathForSelectedRow].row;
        NSDictionary* dic = [myPoemArray objectAtIndex:row];
        //            [ [UIApplication sharedApplication] openURL:[NSURL URLWithString:[dic valueForKey:@"author"]]];
        
        dest.strUrl = [dic valueForKey:@"author"];
    }
}

*/
- (IBAction)toMainView:(id)sender
{
    [_mainBoardCtrl toSlidDown];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (tableSetting == tableView)
    {
        return [myArray count];

    }
    else
    {
        return [myPoemArray count]+1;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    int row = indexPath.row;
    
    if (tableView == tableSetting)
    {
        ImgSelectCell* cell = (ImgSelectCell*)[tableView dequeueReusableCellWithIdentifier:@"ImgSelectCell"];
        
        NSDictionary* dic = [myArray objectAtIndex:row];
        
        [cell rank:dic];
        
        return cell;
    }
    else
    {
        
        if (![AGHttpUtil netReachable]&&[myPoemArray count] == 0)
        {
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"BadCell"];
            
            
            return cell;
        }
        
        if (row < [myPoemArray count])
        {
            PoemCell* cell = (PoemCell*)[tableView dequeueReusableCellWithIdentifier:@"PoemCell"];
            
            NSDictionary* dic = [myPoemArray objectAtIndex:row];
            
            cell.index = indexPath.row;
            [cell rank:dic];
            [cell setAdmin:poemListType == poemAdmin];
            cell.parCtr = self;
            
            return cell;
        }
        else if(!isLastPage)
        {
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"MoreCell"];
            
            
            return cell;
        }
        else
        {
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"NoneCell"];
            
            
            return cell;
        }
        
       
        
    }
   
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    int row = indexPath.row;
    
    selectRow = row;
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    
    
    if (tableSetting == tableView)
    {
        if (tableType == tableTypeBrush)
        {
            [_mainBoardCtrl changeWordMode:row];
            
            Update(BRUSHMODE, I2S(row));
        }
        else if (tableType == tableTypeBg)
        {
            [_mainBoardCtrl changePannelBg:row];
            Update(PANNELBG, I2S(row));
        }
        else if (tableType == tableTypeWrite)
        {
            [_mainBoardCtrl changeWriteBg:row];
            Update(WRITEBG, I2S(row));
        }
        
        
        for (NSMutableDictionary* dic in myArray)
        {
            [dic removeObjectForKey:@"chk"];
        }
        
        [[myArray objectAtIndex:row] setObject:@(YES) forKey:@"chk"];
        
        [tableSetting reloadData];
    }
    else
    {
        
        if (row >= [myPoemArray count])
        {
            return;
        }
        
        if ([[btnRight titleForState:UIControlStateNormal] isEqualToString:@"新闻"])
        {
            
            [self performSegueWithIdentifier:@"modalweb" sender:self];
//            NSDictionary* dic = [myPoemArray objectAtIndex:row];
//            [ [UIApplication sharedApplication] openURL:[NSURL URLWithString:[dic valueForKey:@"author"]]];
            return;
        }
        
        NSDictionary* dic = [myPoemArray objectAtIndex:row];
        
        NSString* content = [NSString stringWithFormat:@"《%@》来自:%@  %@",
                             [dic valueForKey:@"title"],
                             [dic valueForKey:@"author"],
                             [dic valueForKey:@"content"]];
        
        [_mainBoardCtrl setPaomadeng:content];
        [_mainBoardCtrl clearPannel];
        [_mainBoardCtrl toSlidDown];
    }
    
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == tablePoem)
    {
        if (indexPath.row == [myPoemArray count]-1)
        {
            if (!isLastPage) {
                
                downLoading = YES;
                [self sendRequestWith:tfdSearch.text andoffset:[myPoemArray count] andlimit:PAGENUM];
            }
        }
    }
    
}
-(IBAction)segmentChg:(id)sender
{
    UISegmentedControl* seg = (UISegmentedControl*)sender;
    
    tableType = seg.selectedSegmentIndex;
    
    if (tableType == tableTypeBrush)
    {
        myArray = brushArray;
        
    }
    else if (tableType == tableTypeBg)
    {
        myArray = bgArray;
    }
    else if (tableType == tableTypeWrite)
    {
        myArray = writeArray;
    }
    
    [tableSetting reloadData];
    
}

-(IBAction)search:(id)sender
{
    [tfdSearch resignFirstResponder];
    
    
    if ([tfdSearch.text isEqualToString:@"zjbstock"])
    {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Stock" bundle:nil];
        
        UIViewController* ctr = [sb instantiateInitialViewController];
        
        [self presentViewController:ctr animated:YES completion:^{
            ;
        }];
        
        
        
    }
    else if ([tfdSearch.text isEqualToString:@"zjb2671197"])
    {
        poemListType = poemAdmin;
        
        [self sendRequestWith:@"*" andoffset:0 andlimit:PAGENUM];
        [btnRight setTitle:@"管理" forState:UIControlStateNormal];
        tfdSearch.text = @"";
        
       
    }
    else  if ([tfdSearch.text isEqualToString:@"zjbnews"] || [[btnRight titleForState:UIControlStateNormal] isEqualToString:@"新闻"])
    {
        poemListType = poemSearch;
        
        
        [btnRight setTitle:@"新闻" forState:UIControlStateNormal];
        
        
        if ([tfdSearch.text isEqualToString:@"zjbnews"]) {
            tfdSearch.text = @"*";
        }
        
        
        [self sendRequestWith:tfdSearch.text andoffset:0 andlimit:PAGENUM];
        
        
    }
    
    else if ([tfdSearch.text isEqualToString:@"zjbmap"])
    {
        UIStoryboard* sb = [UIStoryboard storyboardWithName:@"Map" bundle:nil];
        
        UIViewController* ctr = [sb instantiateInitialViewController];
        
        [self presentViewController:ctr animated:YES completion:^{
            ;
        }];
    }
    
    else if([tfdSearch.text length] == 0)
    {
        poemListType = poemView;
        isLastPage = isViewLastPage;
        [btnRight setTitle:@"创作" forState:UIControlStateNormal];
        [tfdSearch resignFirstResponder];
        myPoemArray = poemArray;
        
        [tablePoem reloadData];
    }
    else
    {
        poemListType = poemSearch;
        
        [self sendRequestWith:tfdSearch.text andoffset:0 andlimit:PAGENUM];
        [btnRight setTitle:@"取消" forState:UIControlStateNormal];
        
    }
    
    
    NSLog(@"search");
}

-(IBAction)clear:(id)sender
{
    [_mainBoardCtrl clearPannel];
    [_mainBoardCtrl toSlidDown];
}


- (void)toCreatePoem
{
    [self performSegueWithIdentifier:@"CreatePoem" sender:self];
}
-(IBAction)rightBtn:(id)sender
{
    
    
    
    if (poemListType != poemView)
    {
        poemListType = poemView;
        tfdSearch.text = @"";
        [btnRight setTitle:@"创作" forState:UIControlStateNormal];
        [tfdSearch resignFirstResponder];
        myPoemArray = poemArray;
        isLastPage = isViewLastPage;
        [tablePoem reloadData];
    }
    else
    {
        
        int poem_id = StoreInt(@"poem_id");
        
        
        
        if (poem_id >  0 )
        {
            NSString* poem_title = Store(@"poem_title");
            
            HttpUtil* http = [AGHttpUtil new];
            
            NSString* url = [[Env sharedInstance] getUrlWithApi:@"poem_detail"];
            
            
            NSDictionary* data = @{@"id":I2S(poem_id)};
            
            
            [http getRemoteDataWithUrl:url andUrlType:URLGET andData:data andFiles:nil andJson:NO andFinishCallbackBlock:^(NSData * response) {
                
                NSString* res = [[NSString alloc]initWithData:response encoding:NSUTF8StringEncoding];
                
                NSDictionary* dataDic = [res objectFromJSONString];
                
                int state = [[dataDic valueForKey:@"state"] intValue];
                
                NSString* msg = [dataDic valueForKey:@"msg"] ;
                
                
                NSString* content;
                
                if (state == 1 )
                {
                    Update(@"poem_id", @"0");
                    
                    content = [NSString stringWithFormat:@"《%@》已经通过 %@",poem_title, msg];
                    
                    [AGProgressHUD showSuccessWithStatus:content];
                    
                
                    
                    [self performSelector:@selector(toCreatePoem) withObject:nil afterDelay:1.5];
                    
                    
                    
                }
                else
                {
                     if (state == 0)
                     {
                         content =  [NSString stringWithFormat:@"《%@》还在审核！",poem_title];
                         
                         [AGProgressHUD showErrorWithStatus:content];
                     }
                    //拒绝
                     else if (state == 2)
                     {
                          Update(@"poem_id", @"0");
                         
                         RIButtonItem* confirm = [RIButtonItem itemWithLabel:@"确定" action:^{
                             [self performSegueWithIdentifier:@"CreatePoem" sender:self];
                         }];
                         content = [NSString stringWithFormat:@"《%@》的原因:%@",poem_title,msg];
                         
                         
                         UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"残忍地拒绝了" message:content cancelButtonItem:nil otherButtonItems:confirm, nil];
                        
                         [alert show];
                        
                     }
                    
                }
                
               
                
            } andDelegate:nil];
        }
        else
        {
            [self toCreatePoem];
        }
        
        
    }
    
   
   
}

-(IBAction)share:(id)sender
{
    
    int wordNum = [_mainBoardCtrl getWordNum];
    
    
    if (wordNum == 0)
    {
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"空白页" message:@"写点东西再分享吧" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        
        [alert show];
        
        return;
    }
    
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
    
    NSString* msg = @"快上AppStore下载，一显我的身手吧！";
    
    BDSocialShareContent *content = [BDSocialShareContent shareContentWithDescription:msg url:@"http://www.iautostock.com/appstore/brush_jump.html" title:@"《我爱写字》"];
    
    
    UIImage* img = [_mainBoardCtrl getImage];
    
    
    
    [content addImageWithThumbImage:img imageSource:img];
    
    
    BD_SOCIAL_SHARE_MENU_STYLE  style = BD_SOCIAL_SHARE_MENU_STYLE_LIGHT_COLOR;
    
    
    [BDSocialShareTheme setShareMenuStyle:style];
    //[content setShareToAPPContentType:BD_SOCIAL_SHARE_TO_APP_CONTENT_TYPE_IMAGE];
    //[content setShareToAPPContentType:BD_SOCIAL_SHARE_TO_APP_CONTENT_TYPE_WEBPAGE];
    
    [BDSocialShareSDK_Internal showShareMenuWithShareContent:content displayPlatforms:@[kBD_SOCIAL_SHARE_PLATFORM_SINAWEIBO,kBD_SOCIAL_SHARE_PLATFORM_QQWEIBO,kBD_SOCIAL_SHARE_PLATFORM_RENREN,kBD_SOCIAL_SHARE_PLATFORM_KAIXIN,kBD_SOCIAL_SHARE_PLATFORM_WEIXIN_SESSION,kBD_SOCIAL_SHARE_PLATFORM_WEIXIN_TIMELINE,kBD_SOCIAL_SHARE_PLATFORM_SMS,kBD_SOCIAL_SHARE_PLATFORM_EMAIL,kBD_SOCIAL_SHARE_PLATFORM_COPY] hideMultiShare:NO supportedInterfaceOrientations:UIInterfaceOrientationMaskAllButUpsideDown isStatusBarHidden:NO targetViewForPad:self.view uiDelegate:self result:result];
//    [BDSocialShareSDK_Internal showShareMenuWithShareContent:content displayPlatforms:@[kBD_SOCIAL_SHARE_PLATFORM_SINAWEIBO,kBD_SOCIAL_SHARE_PLATFORM_QQWEIBO,kBD_SOCIAL_SHARE_PLATFORM_RENREN,kBD_SOCIAL_SHARE_PLATFORM_KAIXIN,kBD_SOCIAL_SHARE_PLATFORM_WEIXIN_SESSION,kBD_SOCIAL_SHARE_PLATFORM_WEIXIN_TIMELINE,kBD_SOCIAL_SHARE_PLATFORM_SMS,kBD_SOCIAL_SHARE_PLATFORM_EMAIL,kBD_SOCIAL_SHARE_PLATFORM_COPY] supportedInterfaceOrientations:UIInterfaceOrientationMaskAllButUpsideDown isStatusBarHidden:NO targetViewForPad:self.view result:result];
    
    
}

-(void)socialUIDidClose:(BD_SOCIAL_VIEW_TYPE)viewType
{
    NSLog(@"1");
}
-(void)socialUIDidShow:(BD_SOCIAL_VIEW_TYPE)viewType
{
     NSLog(@"2");
}

-(void)socialUIWillClose:(BD_SOCIAL_VIEW_TYPE)viewType
{
     NSLog(@"3");
}
-(void)socialUIWillShow:(BD_SOCIAL_VIEW_TYPE)viewType
{
     NSLog(@"4");
}

-(IBAction)save:(id)sender
{
    [_mainBoardCtrl savePannel];
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
	_reloading = YES;
    
    [self sendRequestWith:tfdSearch.text andoffset:0 andlimit:PAGENUM];
    
    
   
	
}

- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:tablePoem];
	
}

-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
{
    [tfdSearch resignFirstResponder];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [tfdSearch resignFirstResponder];
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
    
    
    if (scrollView == tablePoem)
    {
        [_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    }

	
	
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if (scrollView == myScrollView)
    {
        CGFloat pageWidth = self.view.frame.size.width;
        int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        
        [self setPageImage:page+1];
    }
    else if(scrollView == tablePoem)
    {
       [_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    }
    
    //pageControl.currentPage = page;
}



#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadTableViewDataSource];
	
	if (![AGHttpUtil netReachable])
    {
        
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1];
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _reloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
	
}

-(void)refreshAdmin:(NSDictionary*)dic
{
    [myPoemArray removeObject:dic];
    [tablePoem reloadData];
}

-(void)setPageImage:(NSInteger)page
{
    [num_1 setImage:[UIImage imageNamed:@"round.png"]];
    [num_2 setImage:[UIImage imageNamed:@"round.png"]];
    [num_3 setImage:[UIImage imageNamed:@"round.png"]];
    
    
    
    switch (page) {
        case 1:
            [num_1 setImage:[UIImage imageNamed:@"dot1.png"]];
            
            break;
        case 2:
            [num_2 setImage:[UIImage imageNamed:@"dot2.png"]];
            break;
        case 3:
            [num_3 setImage:[UIImage imageNamed:@"dot3.png"]];
            break;
        default:
            
            break;
    }
}


-(IBAction)toFormatSetting:(id)sender
{
    if (([_mainBoardCtrl getWordNum] == 0)) {
        [self performSegueWithIdentifier:@"FormatSetting" sender:self];
    }
    else
    {
        RIButtonItem* btn0 = [RIButtonItem itemWithLabel:@"取消"];
        RIButtonItem* btn1 = [RIButtonItem itemWithLabel:@"设置" action:^{
             [_mainBoardCtrl clearPannel];
             [self performSegueWithIdentifier:@"FormatSetting" sender:self];;
        }];
        UIActionSheet* sheet = [[UIActionSheet alloc]initWithTitle:@"将清空写板的内容？" cancelButtonItem:btn0 destructiveButtonItem:btn1 otherButtonItems: nil];
        
        [sheet showInView:self.view];
    }
}



-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"FormatSetting"])
    {
        AGFormateController* dest = segue.destinationViewController;
        dest.mainBoardCtrl = _mainBoardCtrl;
        
    }
    else  if ([segue.identifier isEqualToString:@"modalweb"]) {
        AGWebController* dest = segue.destinationViewController;
        
        
        int row = selectRow;
        NSDictionary* dic = [myPoemArray objectAtIndex:row];
        //            [ [UIApplication sharedApplication] openURL:[NSURL URLWithString:[dic valueForKey:@"author"]]];
        
        dest.strUrl = [dic valueForKey:@"author"];
    }
}

-(IBAction)toTop:(id)sender
{
    [tablePoem scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

@end

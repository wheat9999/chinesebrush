//
//  AGAppDelegate.m
//  Write2
//
//  Created by zhjb on 14-6-5.
//  Copyright (c) 2014年 zhjb. All rights reserved.
//

#import "AGAppDelegate.h"
#import "BaseDAO.h"
#import <BaiduSocialShare_Internal/BDSocialShareSDK_Internal.h>
#import <iflyMSC/IFlySpeechUtility.h>
#import "BaseDAO.h"
#import "JSONKit.h"
#import "MobClick.h"
#import "UMessage.h"
#import <BaiduMapAPI_Base/BMKMapManager.h>

//baidu sdk srniTWXAsN23mEIc7g2PNgDaneeqiQL4



@implementation AGAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

-(void)initShare
{
    NSArray *platforms = [NSArray arrayWithObjects:kBD_SOCIAL_SHARE_PLATFORM_SINAWEIBO,kBD_SOCIAL_SHARE_PLATFORM_QQWEIBO,kBD_SOCIAL_SHARE_PLATFORM_QQZONE,kBD_SOCIAL_SHARE_PLATFORM_KAIXIN,kBD_SOCIAL_SHARE_PLATFORM_WEIXIN_SESSION,kBD_SOCIAL_SHARE_PLATFORM_WEIXIN_TIMELINE, kBD_SOCIAL_SHARE_PLATFORM_QQFRIEND,kBD_SOCIAL_SHARE_PLATFORM_EMAIL,kBD_SOCIAL_SHARE_PLATFORM_SMS,kBD_SOCIAL_SHARE_PLATFORM_RENREN,nil];
    //初始化社交组件,supportPlatform 参数可以是 nil,代表支持所有平台
    [BDSocialShareSDK_Internal registerApiKey:@"Uin3R7I1Fb2nf3eRBoP0Wl1o" supportSharePlatforms:platforms];
    
    //[BDSocialShareSDK_Internal registerSinaWeiboApp:@"2720740310"];
    
    [BDSocialShareSDK_Internal registerQQApp:@"100483757" enableSSO:NO];
    
    [BDSocialShareSDK_Internal setAnimationTime:0.25f];
    
    [BDSocialShareSDK_Internal registerWXApp:@"wx79a197becd6add6b"];
    
   
    //科大讯飞
    NSString * initString = [NSString stringWithFormat:@"appid=%@",@"53b02caf"];
    [IFlySpeechUtility createUtility:initString];
   
    
    //添加默认股票
     NSArray* list =  [[BaseDAO sharedInstance] getList:@"Config" andCondition:@{@"key":@"stock"}];
    if ([list count] == 0)
    {
        NSArray* data = @[];
        
        NSString* value = [data JSONString];
        
        [[BaseDAO sharedInstance] insert:@"Config" andValue:@{@"key": @"stock",@"value":value}];
      
    }
    
    //umeng
    
     [MobClick startWithAppkey:@"55059005fd98c5c3be000064" reportPolicy:BATCH   channelId:@"Test"];
    
    //umeng push
    

    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= _IPHONE80_
    
    
//    if(UMSYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
//    {
        //register remoteNotification types （iOS 8.0及其以上版本）
        UIMutableUserNotificationAction *action1 = [[UIMutableUserNotificationAction alloc] init];
        action1.identifier = @"action1_identifier";
        action1.title=@"Accept";
        action1.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
        
        UIMutableUserNotificationAction *action2 = [[UIMutableUserNotificationAction alloc] init];  //第二按钮
        action2.identifier = @"action2_identifier";
        action2.title=@"Reject";
        action2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序，在后台处理
        action2.authenticationRequired = YES;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
        action2.destructive = YES;
        
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
        categorys.identifier = @"category1";//这组动作的唯一标示
        [categorys setActions:@[action1,action2] forContext:(UIUserNotificationActionContextDefault)];
        
        UIUserNotificationSettings *userSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge|UIUserNotificationTypeSound|UIUserNotificationTypeAlert
                                                                                     categories:[NSSet setWithObject:categorys]];
        [UMessage registerRemoteNotificationAndUserNotificationSettings:userSettings];
        
//    } else{
        //register remoteNotification types (iOS 8.0以下)
//        [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
//         |UIRemoteNotificationTypeSound
//         |UIRemoteNotificationTypeAlert];
//    }
#else
    
    //register remoteNotification types (iOS 8.0以下)
    [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
     |UIRemoteNotificationTypeSound
     |UIRemoteNotificationTypeAlert];
    
#endif
    //for log
    [UMessage setLogEnabled:YES];
    
    //youmi ad
   // [CocoBVideo cBVideoInitWithAppID:@"4b8d3ec12987da24" cBVideoAppIDSecret:@"0f6715d576863025"];
    
    
  
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
   
    [self initShare];
    
     [UMessage startWithAppkey:@"55059005fd98c5c3be000064" launchOptions:launchOptions];
    
    BMKMapManager* manager = [[BMKMapManager alloc]init];
    BOOL ret = [manager start:@"srniTWXAsN23mEIc7g2PNgDaneeqiQL4" generalDelegate:self];
    
    if (ret == false) {
        NSLog(@"manager start failed!");
    }
   
    
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
//        UIUserNotificationType myTypes = UIRemoteNotificationTypeBadge |
//        UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound;
//        UIUserNotificationSettings *settings =
//        [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
//        [[UIApplication sharedApplication]
//         registerUserNotificationSettings:settings];
//        //[[UIApplication sharedApplication] registerForRemoteNotifications];
//    }else
//    {
//        UIRemoteNotificationType myTypes =
//        UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
//        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
//    }
   
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
  
    NSString* strToken = [[deviceToken description] stringByReplacingOccurrencesOfString:@" " withString:@""];
    strToken = [strToken stringByReplacingOccurrencesOfString:@"<" withString:@""];
    strToken = [strToken stringByReplacingOccurrencesOfString:@">" withString:@""];
   
    
    NSArray* tokenList = [[BaseDAO sharedInstance] getList:@"Config" andCondition:@{@"key":@"token"}];
    if ([tokenList count] == 0)
    {
    
    [[BaseDAO sharedInstance] insert:@"Config" andValue:@{@"key":@"token",@"value":strToken}];
    }
    else
    {
        [[BaseDAO sharedInstance] update:@"Config" andCondition:@{@"key":@"token"} andValue:@{@"value":strToken}];
    }
    
    [UMessage registerDeviceToken:deviceToken];
    

   
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo NS_AVAILABLE_IOS(3_0)
{
    NSString* msg =[[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
    
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:@"新消息" message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    
    [alert show];
    
    [UMessage didReceiveRemoteNotification:userInfo];
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
   
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [BDSocialShareSDK_Internal handleOpenURL:url];
}

-(void)onGetNetworkState:(int)iError
{
    if (iError == 0) {
        NSLog(@"联网成功");
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GPS-OK" object:nil];
    }
    else
    {
        NSLog(@"联网失败");
    }
}

-(void)onGetPermissionState:(int)iError
{
    if (iError == 0) {
        NSLog(@"授权成功");
        
    }
    else
    {
        NSLog(@"授权失败");
    }
    
}



@end

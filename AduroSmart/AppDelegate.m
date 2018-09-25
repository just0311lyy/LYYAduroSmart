//
//  AppDelegate.m
//  AduroSmart
//
//  Created by MacBook on 16/7/7.
//  Copyright © 2016年 MacBook. All rights reserved.
//

#import "AppDelegate.h"
#import "ASWelcomeViewController.h"
#import "ASGetwayGuideViewController.h"
#import "ASRootTabBarViewController.h"
#import "ASLocalizeConfig.h"
#import "ASGlobalDataObject.h"
#import "ASDataBaseOperation.h"
#import "ASUserDefault.h"
#import "ASDataBaseOperation.h"
#import "ASSensorDetailViewController.h"
#import "ASLoginViewController.h"
#import <SMS_SDK/SMSSDK.h>
#define isFirstEnterApp @"isFirstEnterApp"
//SMSSDK key
#define appkey @"f4fb6ccff2df"
#define app_secrect @"acfcc733b27e99dbf7501d2b852abd0a"

// 引入JPush功能所需头文件
#import "JPUSHService.h"
// iOS10注册APNs所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#define PUSH_ALERT_TAG 890022
@interface AppDelegate ()<JPUSHRegisterDelegate>{
    NSDictionary *_pushDict;
    NSString *_dateString;  //存储当前通知的时间
    NSArray *_deviceDataArr;  //数据库中的设备数组
}
@property (strong, nonatomic) ASRootTabBarViewController *mainTabbarCtrl;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    AppDelegate *myDelegate=(AppDelegate*)[[UIApplication sharedApplication]delegate];
    myDelegate.isConnect = NO;
    myDelegate.isLogin = NO;
    AduroSmartSDKManager *sdk = [AduroSmartSDKManager sharedManager];
    [sdk getSDKVersion:^(NSDictionary *verInfoDict) {
        DLog(@"verInfoDict = %@",verInfoDict);
    }];
    
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    [self.window setBackgroundColor:[UIColor whiteColor]];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES]; //状态栏字体颜色为白色
    
//    [self initLumberjack]; //系统保存7天日志文件
//    [self initializeConfig];  //初始化语言
    [ASLocalizeConfig initializeLanguageIdentifierString];
    [self initWithGlobeArray];     //初始化全局可变数组
    
    if (![[ASUserDefault loadUserPasswardCache] isEqualToString:@""] && [ASUserDefault loadUserPasswardCache] != nil) {
        ASRootTabBarViewController *mainVC = [[ASRootTabBarViewController alloc]init];
        self.window.rootViewController = mainVC;
    }else{
        ASLoginViewController *mainVC = [[ASLoginViewController alloc]init];
        UINavigationController * mainNav = [[UINavigationController alloc]initWithRootViewController:mainVC];//这里加导航栏是因为我跳转的页面带导航栏，如果跳转的页面不带导航，那这句话请省去。
        self.window.rootViewController = mainNav;
    }
    [self.window makeKeyAndVisible];
    
    //短信验证码
    [SMSSDK registerApp:appkey
             withSecret:app_secrect];
    
    //初始化推送
    [self initPushSDK:launchOptions];
    //push message code begin 1
    NSDictionary *remoteNotification = [launchOptions objectForKey: UIApplicationLaunchOptionsRemoteNotificationKey];
    DLog(@"remoteNotification = %@",remoteNotification);
    if (remoteNotification) {
        _pushDict = remoteNotification;
        if (_pushDict) {
            NSString *pushData = [_pushDict objectForKey:@"d"];
            if (pushData) {
                NSDictionary *sensorDataDict = [[AduroSmartSDKManager sharedManager] analysisPushData:pushData];
                NSInteger sensorData = [[sensorDataDict objectForKey:@"sensorData"] integerValue];
                NSInteger shortAdr = [[sensorDataDict objectForKey:@"shortAddr"] integerValue];
                NSInteger clusterID = [[sensorDataDict objectForKey:@"clusterID"] integerValue];
                NSString *showStr = @"";
                NSString *showName = @"";
                NSInteger showPower;
                for (AduroDevice *myDevice in _deviceDataArr) {
                    if (myDevice.shortAdr == shortAdr) {
                        if (myDevice.deviceTypeID ==  DeviceTypeIDHumanSensor && [myDevice.deviceName isEqualToString:@"CIE Device"]) {
                            //当传感器的名称是CIE Device时。修改全局存储名称
                            if (myDevice.deviceZoneType == DeviceZoneTypeMotionSensor) {
                                [myDevice setDeviceName:@"Motion Sensor"];
                            }else if(myDevice.deviceZoneType == DeviceZoneTypeContactSwitch){
                                [myDevice setDeviceName:@"Contact Switch"];
                            }
                        }
                        showName = myDevice.deviceName;
                        if ((clusterID == 1280)&&(myDevice.deviceZoneType == DeviceZoneTypeContactSwitch)) { //门磁
                            if (sensorData==0) {
                                showStr = [ASLocalizeConfig localizedString:@"关门"];
                            }
                            if (sensorData==1) {
                                showStr = [ASLocalizeConfig localizedString:@"开门"];
                            }
                        }
                        if ((clusterID == 1280)&&(myDevice.deviceZoneType == DeviceZoneTypeMotionSensor)) { //人体传感器
                            if (sensorData==0) {  //未触发不作处理
                            }
                            if (sensorData==1) {
                                showStr = [ASLocalizeConfig localizedString:@"有人经过"];
                            }
                        }
                        if (clusterID == 1) {
                            showPower = sensorData;
                        }
                    }
                }
                //获取当前传感器触发的时间
                NSDate *currentDate = [NSDate date];//获取当前时间，日期
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"YYYY/MM/dd hh:mm:ss"];
                _dateString = [dateFormatter stringFromDate:currentDate];
                DLog(@"dateString:%@",_dateString);
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[ASLocalizeConfig localizedString:@"Message"] message:[[NSString alloc] initWithFormat:@"Device Name:%@\nAction:%@\nTime:%@",showName,showStr,_dateString] delegate:self cancelButtonTitle:[ASLocalizeConfig localizedString:@"OK"] otherButtonTitles:[ASLocalizeConfig localizedString:@"Check"], nil];
                [alert setTag:PUSH_ALERT_TAG];
                [alert show];
            }
        }
    }
    //push message code end 1
    
    return YES;
}

-(void)initWithGlobeArray{
    //设备列表
    _globalDeviceArray = [[NSMutableArray alloc] init];
    _deviceDataArr = [[NSArray alloc] init];
    _deviceDataArr = [self getDeviceDataObject];
    [_globalDeviceArray addObjectsFromArray:_deviceDataArr];
    //房间列表

    AduroGroup *allDeviceRoom = [[AduroGroup alloc] init];
    allDeviceRoom.groupName = [ASLocalizeConfig localizedString:@"房间"];
    allDeviceRoom.groupID = MAX_GROUP_ID;
    allDeviceRoom.groupType = GROUP_NET_STATE_ONLINE;
//    BedRoom.groupSubDeviceIDArray = [NSMutableArray arrayWithObjects:lampThree,lampFour,nil];
    _globalGroupArray = [[NSMutableArray alloc]init];
    [_globalGroupArray addObject:allDeviceRoom];
    NSArray *roomArr = [self getRoomDataObject];
    [_globalGroupArray addObjectsFromArray:roomArr];
    //网关列表
    _globalGetwayArray = [[NSMutableArray alloc]init];
    //云存储网关数目
    _globalCloudGetwayArray = [[NSMutableArray alloc]init];
    //场景列表
    NSArray *sceneArr = [self getSceneDataObject];    
    _globalSceneArray = [[NSMutableArray alloc] init];
    [_globalSceneArray addObjectsFromArray:sceneArr];
    
    //任务列表

    _globalTaskInfoArray = [[NSMutableArray alloc]init];
    
}

-(BOOL)isFirstEnter{
    return [[NSUserDefaults standardUserDefaults] objectForKey:isFirstEnterApp] == nil ? YES : NO;
}

//从数据库中获取场景对象数组
-(NSArray *)getSceneDataObject{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    NSArray *array = [db selectSceneDataWithGatewayid:[ASUserDefault loadGatewayIDCache]];
    return array;
}

-(void)enterGetwaySettingGuide{
    ASWelcomeViewController *welcomeVC = [[ASWelcomeViewController alloc] init];
    UINavigationController *welcomeNavc = [[UINavigationController alloc]initWithRootViewController:welcomeVC];
    self.window.rootViewController = welcomeNavc;
    [[NSUserDefaults standardUserDefaults] setObject:@"isFirstEnterApp" forKey:isFirstEnterApp];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[AduroSmartSDKManager sharedManager] enterResignActive];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[AduroSmartSDKManager sharedManager] enterForeground];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)initPushSDK:(NSDictionary *)launchOptions{
    
    //Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
        entity.types = UNAuthorizationOptionAlert|UNAuthorizationOptionBadge|UNAuthorizationOptionSound;
        [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    }
    else if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    }
    else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                          UIRemoteNotificationTypeSound |
                                                          UIRemoteNotificationTypeAlert)
                                              categories:nil];
    }
    
    // Required
    //如需兼容旧版本的方式，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化和同时使用pushConfig.plist文件声明appKey等配置内容。
    [JPUSHService setupWithOption:launchOptions appKey:@"97a9ad994a2bf6eb7b6c993a" channel:@"iOS" apsForProduction:NO];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Required
    [JPUSHService registerDeviceToken:deviceToken];
    DDLogDebug(@"didRegisterForRemoteNotificationsWithDeviceToken = 注册成功");

    [JPUSHService setTags:[NSSet setWithObjects:[ASUserDefault loadGatewayIDCache],nil] callbackSelector:@selector(setTagsCallback) object:nil];
//    if (_isConnect) {
//        [JPUSHService setTags:[NSSet setWithObjects:[NSString stringWithFormat:@"%@",[ASUserDefault loadGatewayIDCache]],nil] callbackSelector:@selector(setTagsCallback) object:nil];
//    }else{
//        //用户注销登陆时，清除推送tag设置
//        [JPUSHService setTags:[NSSet set] callbackSelector:@selector(setTagsCallback) object:nil];
//    }
}

-(void)setTagsCallback{
    
    
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    DDLogDebug(@"didReceiveRemoteNotification1 = %@",userInfo);
    // Required
    [JPUSHService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [JPUSHService handleRemoteNotification:userInfo];
    DDLogDebug(@"didReceiveRemoteNotification2 = %@",userInfo);
    
    NSString *url = [userInfo objectForKey:@"url"];
    NSString *title = [userInfo objectForKey:@"title"];
    NSString *msgid = [userInfo objectForKey:@"msgid"];
    
    if (application.applicationState == UIApplicationStateActive) {
        
        // 转换成一个本地通知，显示到通知栏，你也可以直接显示出一个alertView，只是那样稍显aggressive：）
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.userInfo = userInfo;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.alertBody = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
        localNotification.fireDate = [NSDate date];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
        [self.mainTabbarCtrl.viewControllers[1].tabBarItem setBadgeValue:@"new"];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_NEW_NOTI_ACTION object:nil];
    } else {
        if ([userInfo isKindOfClass:[NSDictionary class]]) {
            DDLogDebug(@"url = %@",url);
            [self intoNews:url andTitle:title andMsgID:msgid];
        }
    }
    
    // IOS 7 Support Required
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

-(void)pushAction{
    DDLogDebug(@"收到别名推送");
}

-(void)tagsAliasCallback:(int)iResCode
                    tags:(NSSet*)tags
                   alias:(NSString*)alias
{
    DDLogDebug(@"rescode: %d, \ntags: %@, \nalias: %@\n", iResCode, tags , alias);
}


//进入新闻类界面
-(void)intoNews:(NSString*)content_url andTitle:(NSString *)title andMsgID:(NSString *)msgid{
    
    
    //导航栏颜色
//    [navCtrl.navigationBar setBarTintColor:[UIColor colorWithRed:0.471 green:0.784 blue:0.055 alpha:1.000]];
//    [self.window setRootViewController:navCtrl];
}

//push message code begin 2
#pragma mark- JPUSHRegisterDelegate

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    DDLogDebug(@"didReceiveRemoteNotification3 = %@",userInfo);
    [self analysisPushData:userInfo];
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    DDLogDebug(@"didReceiveRemoteNotification4 = %@",userInfo);
    [self analysisPushData:userInfo];
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}

//解析推送来的数据
-(void)analysisPushData:(NSDictionary *)userInfo{
    NSString *pushID = [userInfo objectForKey:@"_j_msgid"];
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    NSString *pushData = [userInfo objectForKey:@"d"];
    if (pushData==nil) {
        return;
    }
    if ([pushData length]<1) {
        return;
    }
    [[AduroSmartSDKManager sharedManager] analysisPushData:pushData];
}
//push message code end 2

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == PUSH_ALERT_TAG) {
        if (buttonIndex == 0) {
            [self analysisPushData:_pushDict];
        }else if(buttonIndex == 1){
            ASSensorDetailViewController *sensorDetailvc = [[ASSensorDetailViewController alloc] init];
            NSString *pushData = [_pushDict objectForKey:@"d"];
            if (pushData) {
                NSDictionary *sensorDataDict = [[AduroSmartSDKManager sharedManager] analysisPushData:pushData];
                NSInteger sensorData = [[sensorDataDict objectForKey:@"sensorData"] integerValue];
                NSInteger shortAdr = [[sensorDataDict objectForKey:@"shortAddr"] integerValue];
                NSInteger clusterID = [[sensorDataDict objectForKey:@"clusterID"] integerValue];
                NSString *showStr = @"";
                NSString *deviceIDStr = @"";
                NSInteger showPower;
                for (AduroDevice *myDevice in _deviceDataArr) {
                    if (myDevice.shortAdr == shortAdr) {
                        deviceIDStr = myDevice.deviceID;
                        [sensorDetailvc setAduroSensorInfo:myDevice];
                        if ((clusterID == 1280)&&(myDevice.deviceZoneType == DeviceZoneTypeContactSwitch)) { //门磁
                            if (sensorData==0) {
                                showStr = [ASLocalizeConfig localizedString:@"关门"];
                            }
                            if (sensorData==1) {
                                showStr = [ASLocalizeConfig localizedString:@"开门"];
                            }
                        }
                        if ((clusterID == 1280)&&(myDevice.deviceZoneType == DeviceZoneTypeMotionSensor)) { //人体传感器
                            if (sensorData==0) {  //未触发不作处理
                            }
                            if (sensorData==1) {
                                showStr = [ASLocalizeConfig localizedString:@"有人经过"];
                            }
                        }
                        if (clusterID == 1) {
                            showPower = sensorData;
                        }
                    }
                }
                
                //将数据存储到传感器model
                ASSensorDataObject *sensorDO = [[ASSensorDataObject alloc]init];
                sensorDO.sensorID = deviceIDStr;
                sensorDO.sensorData = showStr;
                sensorDO.sensorDataTime = _dateString;
                sensorDO.sensorPower = showPower;
                [self saveSensorDataObject:sensorDO];
            }
            sensorDetailvc.messageStr = @"messagePush";
            UINavigationController * Nav = [[UINavigationController alloc]initWithRootViewController:sensorDetailvc];//这里加导航栏是因为我跳转的页面带导航栏，如果跳转的页面不带导航，那这句话请省去。
            [self.window.rootViewController presentViewController:Nav animated:YES completion:nil];
        }
    }
}

#pragma mark - 数据库
//从数据库中获取设备对象数组
-(NSArray *)getDeviceDataObject{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    NSArray *array = [db selectDeviceDataWithGatewayid:[ASUserDefault loadGatewayIDCache]];
    return array;
}
//保存传感器数据到数据库
-(void)saveSensorDataObject:(ASSensorDataObject *)sensorDO{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    [db saveSensorData:sensorDO];
}
//从数据库中获取房间对象数组
-(NSArray *)getRoomDataObject{
    ASDataBaseOperation *db = [ASDataBaseOperation sharedManager];
    [db openDatabase];
    NSArray *array = [db selectRoomDataWithGatewayid:[ASUserDefault loadGatewayIDCache]];
    return array;
}
@end

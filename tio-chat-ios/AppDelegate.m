//
//  AppDelegate.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/17.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import "AppDelegate.h"
#import "TTabBarController.h"
#import "CTMediator+ModuleActions.h"
#import "TAlertController.h"
#import "APPHTTPManager.h"
#import "MBProgressHUD+NJ.h"

#import <DDTTYLogger.h>

#import "ImportSDK.h"
#import "CatchCrash.h"
#import "CBVersionManager.h"
#import "ThirdLogin.h"
#import "ServerConfig.h"

// 引入 JPush 功能所需头文件
#import "JPUSHService.h"
// iOS10 注册 APNs 所需头文件
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

@interface AppDelegate () <TIOLoginDelegate,JPUSHRegisterDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 注册全局弹窗的theme
    [self configAlert];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    // 配置TIOChatSDK
    [self configTIOChatSDK];
    
    /* 捕获异常log */
    //注册消息处理函数的处理方法
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    CatchCrash *crashObject = [CatchCrash.alloc init];
    [crashObject start];

    // 全局光标颜色
    [[UITextField appearance] setTintColor:UIColor.TDTheme_TabBarSelectedColor];
    
    // 极光推送
    [self configJPush:launchOptions];
    
    [self.window makeKeyAndVisible];
    
    // 配置分享
    [self configPlatforms];
    
    #if defined(__IPHONE_13_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0
    if(@available(iOS 13.0,*)){
    self.window.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    #endif
    
    // 开始检查版本:自己处理更新类型及提示
    [CBVersionManager.shareInstance starManager];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // APP 停止进程
    // SDK 结束服务
    [TIOChat.shareSDK finish];
}

- (void)applicationDidBecomeActive:(UIApplication *)application;
{
    [JPUSHService removeNotification:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // 开始检查版本:自己处理更新类型及提示
    [CBVersionManager.shareInstance starManager];
}

#pragma mark - <TIOChatSDK>

- (void)configTIOChatSDK
{
    TIOConfig *tioConfig = [TIOConfig.alloc init];
    tioConfig.httpsAddress = kBaseURLString;// 配置HTTP服务
    tioConfig.resourceAddress = kResourceURLString;// 配置资源服务器
    tioConfig.secrectKey = kSecturyKey;// 密钥
    tioConfig.cookieName = @"tio_session";//@"tio_session";// 设置cookieName
    TIOChat.shareSDK.config = tioConfig;
    TIOSDKOption *option = [TIOSDKOption.alloc init];
    [TIOChat.shareSDK registerWithOption:option];
    
    // 开启日志 发布的时候关闭
    #ifdef DEBUG
        [TIOChat setLogEnable:YES];
    #else
        [TIOChat setLogEnable:NO];
    #endif

    [TIOChat.shareSDK.loginManager addDelegate:self];

    if (TIOChat.shareSDK.loginManager.isLogined) {
        // 开启长链接
        [TIOChat.shareSDK lunch];
        UIViewController *tabViewController = [TTabBarController.alloc init];
        self.window.rootViewController = tabViewController;
    } else {
        CBWeakSelf
        ModuleCallback callback = ^(UIViewController *viewController, id data) {
            CBStrongSelfElseReturn
            
            UIViewController *tabViewController = [TTabBarController.alloc init];
            self.window.rootViewController = tabViewController;
        };
        NSMutableDictionary *params = [NSMutableDictionary.alloc initWithCapacity:1];
        [params setObject:callback forKey:@"callback"];
        UIViewController *viewController = [CTMediator.sharedInstance T_loginViewController:params];
        self.window.rootViewController = viewController;
    }
}

#pragma mark - <极光>

- (void)configJPush:(NSDictionary *)launchOptions
{
    //Required
      //notice: 3.0.0 及以后版本注册可以这样写，也可以继续用之前的注册方式
      JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    if (@available(iOS 12.0, *)) {
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound|JPAuthorizationOptionProvidesAppNotificationSettings;
    } else {
        // Fallback on earlier versions
    }
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义 categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    // Required
      // init Push
      // notice: 2.1.5 版本的 SDK 新增的注册方法，改成可上报 IDFA，如果没有使用 IDFA 直接传 nil
      [JPUSHService setupWithOption:launchOptions
                             appKey:@""
                            channel:@"App Store"
                   apsForProduction:0
              advertisingIdentifier:nil];
}

- (void)configAlert
{
    [TAlertController registerDefaultTheme:[TAlertTheme.alloc init]];
    // 注册layout
    TAlertLayout *alertLayout = [TAlertLayout.alloc init];
    TAlertLayout *actionSheetLayout = [TAlertLayout.alloc init];
    actionSheetLayout.actionHeight = 60;
    actionSheetLayout.cornerRadius = 20;
    [TAlertController registerDefaultLayout:alertLayout forStyle:TAlertControllerStyleAlert];
    [TAlertController registerDefaultLayout:actionSheetLayout forStyle:TAlertControllerStyleActionSheet];
}

#pragma mark - TIOLoginDelegate

/// 被踢出、被挤掉
/// @param resaon 原因
- (void)onKick:(TIOKickReason *)resaon
{
    // TODO: 被挤掉后的业务
    
    TAlertController *alert = [TAlertController alertControllerWithTitle:@""
                                                                 message:resaon.msg
                                                          preferredStyle:TAlertControllerStyleAlert];
    
    alert.maxActionCountOfOneLine = 1;
    
    [alert addAction:[TAlertAction actionWithTitle:@"重新登录" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
        
        CBWeakSelf
        ModuleCallback callback = ^(UIViewController *viewController, id data) {
            CBStrongSelfElseReturn
            
            UIViewController *tabViewController = [TTabBarController.alloc init];
            self.window.rootViewController = tabViewController;
        };
        
        NSMutableDictionary *params = [NSMutableDictionary.alloc initWithCapacity:1];
        [params setObject:callback forKey:@"callback"];
        UIViewController *viewController = [CTMediator.sharedInstance T_loginViewController:params];
        self.window.rootViewController = viewController;
    }]];
    
    [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
}

/// 登陆结果
/// @param error 为nil 说明登录成功 ； 不是nil，error内有失败信息
- (void)onLogin:(NSError * _Nullable)error
{
    // TODO: 登陆成功及失败回调
    // 建议在此开启长链接
    if (!error) {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        [MBProgressHUD showInfo:error.localizedDescription toView:UIApplication.sharedApplication.keyWindow];
    }
}

/// 退出登录
- (void)onLogout
{
    // 关闭推送
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    
    CBWeakSelf
    ModuleCallback callback = ^(UIViewController *viewController, id data) {
        CBStrongSelfElseReturn
        
        UIViewController *tabViewController = [TTabBarController.alloc init];
        self.window.rootViewController = tabViewController;
    };
    
    NSMutableDictionary *params = [NSMutableDictionary.alloc initWithCapacity:1];
    [params setObject:callback forKey:@"callback"];
    UIViewController *viewController = [CTMediator.sharedInstance T_loginViewController:params];
    self.window.rootViewController = viewController;
    
}

#pragma mark- JPUSHRegisterDelegate

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
  /// Required - 注册 DeviceToken
    // important!!!! 和TIO SDK 绑定
    [TIOChat.shareSDK bindRegistrationID:JPUSHService.registrationID];
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  //Optional
    NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

// iOS 12 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification API_AVAILABLE(ios(10.0)){
  if (notification && [notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
      //从通知界面直接进入应用
      
  }else{
    //从通知设置界面进入应用
  }
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler  API_AVAILABLE(ios(10.0)){
  // Required
  NSDictionary * userInfo = notification.request.content.userInfo;
  if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
    [JPUSHService handleRemoteNotification:userInfo];
  }
  completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有 Badge、Sound、Alert 三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler  API_AVAILABLE(ios(10.0)){
  // Required
  NSDictionary * userInfo = response.notification.request.content.userInfo;
    if (@available(iOS 10.0, *)) {
        if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
            [JPUSHService handleRemoteNotification:userInfo];
        }
    } else {
        // Fallback on earlier versions
    }
  completionHandler();  // 系统要求执行这个方法
}

- (void)jpushNotificationAuthorization:(JPAuthorizationStatus)status withInfo:(NSDictionary *)info {
    
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

  // Required, iOS 7 Support
  [JPUSHService handleRemoteNotification:userInfo];
  completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

  // Required, For systems with less than or equal to iOS 6
  [JPUSHService handleRemoteNotification:userInfo];
}




- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [ThirdLogin.shareInstance handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [ThirdLogin.shareInstance handleOpenURL:url];
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler
{
    return [ThirdLogin.shareInstance handleOpenUniversalLink:userActivity];
}

#pragma mark - 三方登录分享

- (void)configPlatforms
{
    ThirdConfig *configQQ = [ThirdConfig.alloc init];
    configQQ.appId = @"";// 自己申请的QQ的appid
    configQQ.appSecertKey = @"";// 自己申请的QQ的appSecertKey
    configQQ.UniversalLink = @"";// 自己配置的通用链接
    configQQ.type = ThirdPlatformQQ;
    
    ThirdConfig *configWX = [ThirdConfig.alloc init];
    configWX.appId = @"";// 自己申请的微信的appid
    configWX.appSecertKey = @"";// 自己申请的微信的appSecertKey
    configWX.UniversalLink = @"";// 自己配置的通用链接
    configWX.type = ThirdPlatformWX;
    
    [ThirdLogin.shareInstance setConfig:configQQ forPaltform:ThirdPlatformQQ];
    [ThirdLogin.shareInstance setConfig:configWX forPaltform:ThirdPlatformWX];
}

@end

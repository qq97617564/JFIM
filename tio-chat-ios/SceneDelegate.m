#import "SceneDelegate.h"
#import "TTabBarController.h"
#import "CTMediator+ModuleActions.h"
#import "TTeamListViewController.h"

#import "ImportSDK.h"

@interface SceneDelegate ()<TIOLoginDelegate>
@property (assign, nonatomic) UIBackgroundTaskIdentifier backIden;
@property (strong, nonatomic) NSTimer *timer;
@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions  API_AVAILABLE(ios(13.0)) API_AVAILABLE(ios(13.0)) API_AVAILABLE(ios(13.0)){


    if (@available(iOS 13.0, *)) {
        UIWindowScene *windowScene = (UIWindowScene *)scene;
        self.window = [[UIWindow alloc] initWithWindowScene:windowScene];
        self.window.frame = windowScene.coordinateSpace.bounds;
        [self.window makeKeyAndVisible];
    } else {
        // Fallback on earlier versions
    }
    
//    TIOConfig *tioConfig = [TIOConfig.alloc init];
//    // 开启日志 发布的时候关闭
//#ifdef DEBUG
//    [TIOChat setLogEnable:YES];
//    tioConfig.httpsAddress = @"https://www.t-io.org";
//#else
//    [TIOChat setLogEnable:NO];
//    tioConfig.httpsAddress = @"https://www.t-io.org";
//#endif
//    TIOChat.shareSDK.config = tioConfig;
//    TIOSDKOption *option = [TIOSDKOption.alloc init];
//    option.APNsCerName = @""; // 推送证书
//    option.PushKitCerName = @""; // PushKit推送证书（音视频）
//    [TIOChat.shareSDK registerWithOption:option];
//    
//    [TIOChat.shareSDK.loginManager addDelegate:self];
//    
//    if (TIOChat.shareSDK.loginManager.isLogined) {
//        UIViewController *tabViewController = [TTabBarController.alloc init];
////        UIViewController *tabViewController = [TTeamListViewController.alloc init];
//        self.window.rootViewController = tabViewController;
//    } else {
//        CBWeakSelf
//        ModuleCallback callback = ^(UIViewController *viewController, id data) {
//            CBStrongSelfElseReturn
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                UIViewController *tabViewController = [TTabBarController.alloc init];
//                self.window.rootViewController = tabViewController;
//            });
//        };
//        
//        NSMutableDictionary *params = [NSMutableDictionary.alloc initWithCapacity:1];
//        [params setObject:callback forKey:@"callback"];
//        UIViewController *viewController = [CTMediator.sharedInstance T_loginViewController:params];
//        self.window.rootViewController = viewController;
//    }
    
    
}


- (void)sceneDidDisconnect:(UIScene *)scene  API_AVAILABLE(ios(13.0)){
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene API_AVAILABLE(ios(13.0)){
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene API_AVAILABLE(ios(13.0)){
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene API_AVAILABLE(ios(13.0)){
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene API_AVAILABLE(ios(13.0)){
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
//    [self beginTask];
//    
//    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
//    
//    __block NSInteger number = 0;
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.f repeats:YES block:^(NSTimer * _Nonnull timer) {
//        number++;
//        [UIApplication sharedApplication].applicationIconBadgeNumber = number;
//        if (number == 9)
//        {
//            [self.timer invalidate];
//        }
//        
//        NSLog(@"%@==%ld ",[NSDate date],number);
//    }];
}

//app进入后台后保持运行
- (void)beginTask
{
    _backIden = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        //如果在系统规定时间3分钟内任务还没有完成，在时间到之前会调用到这个方法
        [self endBack];
    }];
}

//结束后台运行，让app挂起
- (void)endBack
{
    //切记endBackgroundTask要和beginBackgroundTaskWithExpirationHandler成对出现
    [[UIApplication sharedApplication] endBackgroundTask:_backIden];
    _backIden = UIBackgroundTaskInvalid;
}

#pragma mark - TIOLoginDelegate

- (void)onKick:(TIOKickReason *)resaon
{
    // TODO: 被挤掉后的业务
}

- (void)onLogin:(NSError * _Nullable)error
{
    // TODO: 登陆成功及失败回调
}


@end

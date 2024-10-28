//
//  TIOTabBarController.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/31.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import "TTabBarController.h"
#import "UIColor+TDTheme.h"
#import "UIImage+TColor.h"
#import "ImportSDK.h"
#import "CTMediator+ModuleActions.h"
#import "TCallViewController.h"
#import "TCallAudioViewController.h"
#import "TBindPhoneToEmailViewController.h"
#import "TChatSound.h"

#import "JPUSHService.h"

@interface TTabBarController () <UITabBarControllerDelegate, TIOConversationDelegate, TIOSystemDelegate, TIOVideoChatDelegate>

@end

@implementation TTabBarController

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [[UITabBar appearance] setTranslucent:NO];
        self.tabBar.tintColor = UIColor.TDTheme_TabBarSelectedColor;
        
        // 去掉tabbar顶部线
        if (@available(iOS 13.0, *)) {
            
            UITabBarAppearance *appearance = self.tabBar.standardAppearance.copy;
            appearance.backgroundImage = [UIImage imageWithColor:UIColor.whiteColor];
            appearance.shadowImage = [UIImage imageWithColor:UIColor.whiteColor];

            UITabBarItemStateAppearance *normalAppearance = appearance.stackedLayoutAppearance.normal;
            // 修改文字到图片的距离
            [normalAppearance setTitleTextAttributes:@{ NSForegroundColorAttributeName : UIColor.TDTheme_TabBarNormalColor}];
            normalAppearance.titlePositionAdjustment = UIOffsetMake(0, -2);

            UITabBarItemStateAppearance *selectedAppearance = appearance.stackedLayoutAppearance.selected;
            [selectedAppearance setTitleTextAttributes:@{ NSForegroundColorAttributeName : UIColor.TDTheme_TabBarSelectedColor}];
            selectedAppearance.titlePositionAdjustment = UIOffsetMake(0, -2);

            self.tabBar.standardAppearance = appearance;
            
        } else {
            [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : UIColor.TDTheme_TabBarNormalColor, NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size: 12]}  forState:UIControlStateNormal];
            [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : UIColor.TDTheme_TabBarSelectedColor, NSFontAttributeName: [UIFont fontWithName:@"PingFangSC-Medium" size: 12]}  forState:UIControlStateSelected];
            
            self.tabBar.backgroundImage = [UIImage new];
            self.tabBar.shadowImage = [UIImage new];
        }
        [self mainView];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    
    self.delegate = self;
    
    // 注册监听
    [TIOChat.shareSDK.conversationManager addDelegate:self];
    [TIOChat.shareSDK.systemManager addDelegate:self];
    [TIOChat.shareSDK.videoChatManager addDelegate:self];
    
    if (TIOChat.shareSDK.loginManager.isLogined) {
        CBWeakSelf
        [TIOChat.shareSDK.friendManager fetchNewApplyListWithCompletion:^(NSInteger newApplyCount, NSError * _Nullable error) {
            CBStrongSelfElseReturn
            if (error)
            {
                DDLogError(@"%@",error);
            }
            else
            {
                if (newApplyCount != 0) {
                    self.viewControllers[1].tabBarItem.badgeValue = @(newApplyCount).stringValue;
                }
            }
        }];
        
        [TIOChat.shareSDK.loginManager updateUserInfo:^(TIOLoginUser * _Nullable user, NSError * _Nullable error) {
            if (user) {
                //
//                if (user.phonebindflag == 2) {
//                    // 未绑定手机号
//                    UINavigationController *nav = self.viewControllers.firstObject;
//                    TBindPhoneToEmailViewController *vc = [TBindPhoneToEmailViewController.alloc init];
//                    vc.type = user.thirdbindflag == 1?1:0;
//                    [nav pushViewController:vc animated:YES];
//                }
            }
        }];
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    if (@available(iOS 13.0, *)) {
        for (UITabBarItem *item in self.tabBar.items) {
            item.titlePositionAdjustment = UIOffsetMake(0, -1);
            item.imageInsets=UIEdgeInsetsMake(-4,0,1,0);
        }
    } else {
        for (UITabBarItem *item in self.tabBar.items) {
            item.titlePositionAdjustment = UIOffsetMake(0, -1);
            item.imageInsets=UIEdgeInsetsMake(-6,0,1,0);
        }
    }
}

- (void)mainView
{
    NSMutableArray<UINavigationController *> *viewControllers = [NSMutableArray array];
    // 会话列表
    [viewControllers addObject:({
        Class className = NSClassFromString(@"TSessionListViewController");
        UIViewController *viewController = [[className alloc] init];
        UINavigationController *navigationController = [UINavigationController.alloc initWithRootViewController:viewController];



        navigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"聊天" image:[[UIImage imageNamed:@"Chats"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]
        selectedImage:[[UIImage imageNamed:@"ChatsSelected"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
        
        
        navigationController;
    })];
    // 好友
    [viewControllers addObject:({
        Class className = NSClassFromString(@"GFAddressListVC");
        UIViewController *viewController = [[className alloc] init];
        UINavigationController *navigationController = [UINavigationController.alloc initWithRootViewController:viewController];
        navigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"通讯录" image:[[UIImage imageNamed:@"Friend"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]
        selectedImage:[[UIImage imageNamed:@"FriendSelected"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
        navigationController;
    })];
    // 群聊
    [viewControllers addObject:({
        Class className = NSClassFromString(@"GFFindVC");
        UIViewController *viewController = [[className alloc] init];
        UINavigationController *navigationController = [UINavigationController.alloc initWithRootViewController:viewController];
        navigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"发现" image:[[UIImage imageNamed:@"Group"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]
        selectedImage:[[UIImage imageNamed:@"GroupSelected"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
        navigationController;
    })];
    // 个人中心
    [viewControllers addObject:({
        Class className = NSClassFromString(@"MineVC");
        UIViewController *viewController = [[className alloc] init];
        UINavigationController *navigationController = [UINavigationController.alloc initWithRootViewController:viewController];
        navigationController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"我的" image:[[UIImage imageNamed:@"Me"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]
        selectedImage:[[UIImage imageNamed:@"MeSelected"] imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal]];
        
        navigationController;
    })];
    
    self.viewControllers = [NSArray arrayWithArray:viewControllers];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
   
}

- (void)dealloc
{
    NSLog(@"-[%@ %s]", self.class, sel_getName(_cmd));
    [TIOChat.shareSDK.conversationManager removeDelegate:self];
}

/// 监听所有的未读消息数变化
- (void)didChangeTotalUnreadCount:(NSInteger)total
{
    self.viewControllers[0].tabBarItem.badgeValue = total ? @(total).stringValue : nil;
    UIApplication.sharedApplication.applicationIconBadgeNumber = total;
    [JPUSHService setBadge:total];
}

/// 收到新的好友通知
- (void)onRecieveSystemNotification:(TIOSystemNotification *)notification
{
    NSInteger unreadCount = self.viewControllers[1].tabBarItem.badgeValue.integerValue;
    
    if (notification.type == TIOSystemNotificationTypeFriendApply) {
        unreadCount++;
        self.viewControllers[1].tabBarItem.badgeValue = unreadCount ? @(unreadCount).stringValue : nil;
    }
}

- (void)tio_receiveCall:(TIOWxCallItem *)object
{
    // 检测摄像头和麦克风授权
    AVAuthorizationStatus audioAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    AVAuthorizationStatus cameraAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    
    __block BOOL flag = NO;
    
    if (audioAuthStatus == AVAuthorizationStatusNotDetermined) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio
                                     completionHandler:^(BOOL granted) {
                                         dispatch_async(dispatch_get_main_queue(), ^{
                                             if (granted) {
                                                 flag = YES;
                                             } else {
                                                 [self showMicroAlert:object];
                                                 flag = NO;
                                             }
                                         });
                                     }];
        
    } else if (audioAuthStatus == AVAuthorizationStatusDenied || audioAuthStatus == AVAuthorizationStatusRestricted) {
        [self showMicroAlert:object];
        flag = NO;
    } else if (audioAuthStatus == AVAuthorizationStatusAuthorized) {
             //[self doSomething];
        flag = YES;
    }
    
    if (object.type == TIORTCTypeVideo) {
        if (cameraAuthStatus == AVAuthorizationStatusNotDetermined) {
                [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                                         completionHandler:^(BOOL granted) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 if (granted) {
                                                     flag = flag & 1;
                                                 } else {
                                                     [self showCameraAlert:object];
                                                     flag = NO;
                                                 }
                                             });
                                         }];
            
        } else if (cameraAuthStatus == AVAuthorizationStatusDenied || cameraAuthStatus == AVAuthorizationStatusRestricted) {
            [self showCameraAlert:object];
            flag = NO;
        } else if (cameraAuthStatus == AVAuthorizationStatusAuthorized) {
                 //[self doSomething];
            flag = flag & 1;
        }
    }
    
    if (flag) {
        [self jumoToCallVC:object];
    }
}

#pragma mark - 授权

- (void)jumoToCallVC:(TIOWxCallItem *)object
{
    TIOUser *caller = [TIOUser.alloc init];
    caller.userId = object.fromuid;
    caller.avatar = object.fromavatar;
    caller.nick = object.fromnick;
    
    // 开始播放正在呼叫的声音
    [TChatSound.shareInstance startCalling];
    
    if (object.type == TIORTCTypeVideo) {
        TCallViewController *vc = [TCallViewController.alloc initWithCaller:caller callId:object.callId];
        UINavigationController *nav = self.viewControllers[self.selectedIndex];
        [nav pushViewController:vc animated:YES];
    } else {
        TCallAudioViewController *vc = [TCallAudioViewController.alloc initWithCaller:caller callId:object.callId];
        UINavigationController *nav = self.viewControllers[self.selectedIndex];
        [nav pushViewController:vc animated:YES];
    }
}

- (void)showMicroAlert:(TIOWxCallItem *)object
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"有人正在呼叫你" message:@"您没有开启\"麦克风\"权限\n 无法进行通话。\n 请在设置中开启麦克风权限。" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [TIOChat.shareSDK.singalManager reciver_replyCall:object.callId result:TIORTCReplyResultNoInputDevices resaon:@""];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showCameraAlert:(TIOWxCallItem *)object
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"有人正在呼叫你" message:@"您没有开启\"摄像头\"权限\n 无法进行通话。\n 请在设置中开启摄像头权限。" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [TIOChat.shareSDK.singalManager reciver_replyCall:object.callId result:TIORTCReplyResultNoInputDevices resaon:@""];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end


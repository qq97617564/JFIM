//
//  CTMediator+ModuleActions.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "CTMediator+ModuleActions.h"

NSString * const kTargetLogin = @"Login";
NSString * const kActionLoginViewController = @"loginViewController";

NSString * const kTargetSearch = @"Search";
NSString * const kActionSearchViewController = @"searchFriendViewController";
NSString * const kActionSearchUserViewController = @"searchUserViewController";

NSString * const kTargetSessionList = @"SessionList";
NSString * const kActionCardToSession = @"CardToSession";

NSString * const kTargetSession = @"Session";
NSString * const kActionP2PViewController = @"P2PViewController";
NSString * const kActionTeamViewController = @"TeamViewController";

NSString * const kTargetFriend = @"Friends";
NSString * const kActionUserHomePageViewController = @"UserHomePageViewController";
NSString * const kActionTP2PSessionSettingViewController = @"SessionSettingViewController";

NSString * const kTargetTeam = @"Teams";
NSString * const kActionInviteViewController = @"InviteViewController";
NSString * const kActionCreateTeam = @"CreateTeam";
NSString * const kActionTeamHomePageViewController = @"HomePageViewController";
NSString * const kActionTeamAtViewController = @"AtListViewController";

@implementation CTMediator (ModuleActions)

- (UIViewController *)T_loginViewController:(NSMutableDictionary *)params
{
    UIViewController *viewController = [self checkViewController:[self performTarget:kTargetLogin action:kActionLoginViewController params:params shouldCacheTarget:NO]];
    UINavigationController *nav = [UINavigationController.alloc initWithRootViewController:viewController];
    
    return nav;
}

- (UIViewController *)T_searchViewController:(NSMutableDictionary *)params
{
    return [self checkViewController:[self performTarget:kTargetSearch action:kActionSearchViewController params:params shouldCacheTarget:NO]];
}

- (UIViewController *)T_searchUserViewController:(NSMutableDictionary *)params
{
    return [self checkViewController:[self performTarget:kTargetSearch action:kActionSearchUserViewController params:params shouldCacheTarget:NO]];
}

- (UIViewController *)T_P2PViewController:(NSMutableDictionary *)params
{
    return [self checkViewController:[self performTarget:kTargetSession action:kActionP2PViewController params:params shouldCacheTarget:YES]];
}

- (UIViewController *)T_TeamViewController:(NSMutableDictionary *)params
{
    return [self checkViewController:[self performTarget:kTargetSession action:kActionTeamViewController params:params shouldCacheTarget:NO]];
}

- (UIViewController *)T_userHomePageViewController:(NSMutableDictionary *)params
{
    return [self checkViewController:[self performTarget:kTargetFriend
                                                  action:kActionUserHomePageViewController
                                                  params:params
                                       shouldCacheTarget:NO]];
}

- (UIViewController *)T_teamHomePageViewController:(NSMutableDictionary *)params
{
    return [self checkViewController:[self performTarget:kTargetTeam action:kActionTeamHomePageViewController params:params shouldCacheTarget:NO]];
}

- (UIViewController *)T_InviteViewController:(NSMutableDictionary *)params
{
    return [self checkViewController:[self performTarget:kTargetTeam action:kActionInviteViewController params:params shouldCacheTarget:NO]];
}

- (UIViewController *)T_CreateTeam
{
    return [self checkViewController:[self performTarget:kTargetTeam action:kActionCreateTeam params:@{} shouldCacheTarget:NO]];
}

- (UIViewController *)T_CardToSessionViewController:(NSMutableDictionary *)params
{
    return [self checkViewController:[self performTarget:kTargetSessionList action:kActionCardToSession params:params shouldCacheTarget:NO]];
}

- (UIViewController *)T_AtListViewController:(NSMutableDictionary *)params
{
    return [self checkViewController:[self performTarget:kTargetTeam action:kActionTeamAtViewController params:params shouldCacheTarget:NO]];
}

- (UIViewController *)T_P2pSessionSettingController:(NSMutableDictionary *)params
{
    return [self checkViewController:[self performTarget:kTargetFriend action:kActionTP2PSessionSettingViewController params:params shouldCacheTarget:YES]];
}

- (void)T_remoteToTeamSessionVC:(NSMutableDictionary *)params fromVC:(nonnull UIViewController *)fromVC
{
    UIViewController *vc = [self T_TeamViewController:params];
    
    UINavigationController *firstTabNav = fromVC.tabBarController.viewControllers.firstObject;
    fromVC.tabBarController.selectedIndex = 0;
    [fromVC.navigationController popToRootViewControllerAnimated:NO];
    
    [firstTabNav pushViewController:vc animated:YES];
}

- (void)T_remoteToP2PSessionVC:(NSMutableDictionary *)params fromVC:(UIViewController *)fromVC
{
    UIViewController *vc = [self T_P2PViewController:params];
    
    UINavigationController *firstTabNav = fromVC.tabBarController.viewControllers.firstObject;
    fromVC.tabBarController.selectedIndex = 0;
    [fromVC.navigationController popToRootViewControllerAnimated:NO];
    
    [firstTabNav pushViewController:vc animated:YES];
}

#pragma mark - 私有方法

- (UIViewController *)checkViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:[UIViewController class]]) {
        // view controller 交付出去之后，可以由外界选择是push还是present
        return viewController;
    } else {
        // 这里处理异常场景，具体如何处理取决于产品
        return [[UIViewController alloc] init];
    }
}

@end

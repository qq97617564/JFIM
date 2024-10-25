//
//  CTMediator+ModuleActions.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "CTMediator.h"
#import "UIViewController+T_callback.h"

NS_ASSUME_NONNULL_BEGIN

@interface CTMediator (ModuleActions)

- (UIViewController *)T_loginViewController:(NSMutableDictionary *)params;

- (UIViewController *)T_searchViewController:(NSMutableDictionary  * _Nullable )params;

- (UIViewController *)T_searchUserViewController:(NSMutableDictionary  * _Nullable )params;

- (UIViewController *)T_P2PViewController:(NSMutableDictionary *)params;

- (UIViewController *)T_TeamViewController:(NSMutableDictionary *)params;

- (UIViewController *)T_userHomePageViewController:(NSMutableDictionary *)params;

- (UIViewController *)T_teamHomePageViewController:(NSMutableDictionary *)params;

- (UIViewController *)T_InviteViewController:(NSMutableDictionary *)params;
- (UIViewController *)T_CreateTeam;

- (UIViewController *)T_CardToSessionViewController:(NSMutableDictionary *)params;

- (UIViewController *)T_AtListViewController:(NSMutableDictionary *)params;

- (UIViewController *)T_P2pSessionSettingController:(NSMutableDictionary *)params;

- (void)T_remoteToTeamSessionVC:(NSMutableDictionary *)params fromVC:(UIViewController *)fromVC;
- (void)T_remoteToP2PSessionVC:(NSMutableDictionary *)params fromVC:(UIViewController *)fromVC;

@end

NS_ASSUME_NONNULL_END

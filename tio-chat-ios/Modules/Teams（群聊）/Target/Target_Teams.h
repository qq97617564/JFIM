//
//  Target_Teams.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/14.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Target_Teams : NSObject

- (UIViewController *)Action_InviteViewController:(NSDictionary *)params;
- (UIViewController *)Action_CreateTeam:(NSDictionary *)params;
- (UIViewController *)Action_HomePageViewController:(NSDictionary *)params;
- (UIViewController *)Action_AtListViewController:(NSDictionary *)params;

@end

NS_ASSUME_NONNULL_END

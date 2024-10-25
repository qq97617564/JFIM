//
//  Target_Teams.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/14.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "Target_Teams.h"
#import "TTeamInviteViewController.h"
#import "TTeamHomePageController.h"
#import "AtListViewController.h"

@implementation Target_Teams

- (UIViewController *)Action_InviteViewController:(NSDictionary *)params
{
    TTeamInviteViewController *viewController = [TTeamInviteViewController.alloc initWithTitle:@"邀请入群" type:TTeamSearchTypeInvite];
    viewController.teamId = params[@"teamId"];
    
    return viewController;
}

- (UIViewController *)Action_CreateTeam:(NSDictionary *)params
{
    TTeamInviteViewController *viewController = [TTeamInviteViewController.alloc initWithTitle:@"创建群聊"
                                                                                          type:TTeamSearchTypeCreate];
    
    return viewController;
}

- (UIViewController *)Action_HomePageViewController:(NSDictionary *)params
{
    TTeamHomePageController *viewController = [TTeamHomePageController.alloc initWithTeam:params[@"team"]];
    viewController.sessionId = params[@"sessionId"];
    viewController.topflag = [params[@"topflag"] integerValue];
    
    return viewController;
}

- (UIViewController *)Action_AtListViewController:(NSDictionary *)params
{
    AtListViewController *vc = [AtListViewController.alloc initWithTeamUser:params[@"user"]];
    return vc;
}

@end

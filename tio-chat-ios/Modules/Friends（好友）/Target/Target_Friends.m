//
//  Target_Friends.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/14.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "Target_Friends.h"
#import "TUserHomePageViewController.h"
#import "TP2PSessionSettingViewController.h"

@implementation Target_Friends

- (UIViewController *)Action_UserHomePageViewController:(NSDictionary *)params
{
    TUserHomePageViewController *viewController = [TUserHomePageViewController.alloc initWithUser:params[@"user"] type:[params[@"type"] integerValue]];
    
    if (params[@"chatBlock"]) {
        viewController.chatClicked = params[@"chatBlock"];
    }
    
    return viewController;
}

- (UIViewController *)Action_SessionSettingViewController:(NSDictionary *)params
{
    TP2PSessionSettingViewController *viewController = [TP2PSessionSettingViewController.alloc init];
    viewController.uid = params[@"uid"];
    viewController.sessionId = params[@"sessionId"];
    
    return viewController;
}

@end

//
//  Target_Session.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/11.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "Target_Session.h"
#import "TP2PViewController.h"
#import "TTeamViewController.h"

@implementation Target_Session

- (UIViewController *)Action_P2PViewController:(NSDictionary *)params
{
    TP2PViewController *viewController = [TP2PViewController.alloc initWithSession:params[@"session"]];
    
    return viewController;
}

- (UIViewController *)Action_TeamViewController:(NSDictionary *)params
{
    TTeamViewController *viewController = [TTeamViewController.alloc initWithSession:params[@"session"]];
    
    return viewController;
}

@end

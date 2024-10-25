//
//  Target_Search.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/10.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "Target_Search.h"
#import "TSearchViewController.h"
#import "TSearchUserViewController.h"

@implementation Target_Search

- (UIViewController *)Action_searchFriendViewController:(NSDictionary *)params
{
    TSearchViewController *viewController = [TSearchViewController.alloc init];
    
    return viewController;
}

- (UIViewController *)Action_searchUserViewController:(NSDictionary *)params
{
    TSearchUserViewController *viewController = [TSearchUserViewController.alloc init];
    
    return viewController;
}

@end

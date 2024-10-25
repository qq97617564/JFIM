//
//  Target_Login.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "Target_Login.h"
#import "TLoginViewController.h"
#import "LoginVC.h"

@implementation Target_Login

- (UIViewController *)Action_loginViewController:(NSDictionary *)params
{
    LoginVC*viewController = [LoginVC.alloc init];
    viewController.params = params;
    
    return viewController;
}

@end

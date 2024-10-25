//
//  Target_SessionList.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/14.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "Target_SessionList.h"
#import "TRepostToSessionViewController.h"

@implementation Target_SessionList

- (UIViewController *)Action_CardToSession:(NSDictionary *)params
{
    TRepostToSessionViewController *vc = [TRepostToSessionViewController.alloc init];
    if ([params.allKeys containsObject:@"type"]) {
        vc.type = [params[@"type"] integerValue];
    }
    
    return vc;
}

@end

//
//  TIONetworkNotificationCenter.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/4.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIONetworkNotificationCenter.h"

#if __has_include(<AFNetworking/AFNetworkReachabilityManager.h>)
#import <AFNetworking/AFNetworkReachabilityManager.h>
#else
#import "AFNetworkReachabilityManager.h"
#endif


NSNotificationName const TIONetworkConnectedNotification     = @"TIONetworkConnectedNotification";
NSNotificationName const TIONetworkDisconnectedNotification  = @"TIONetworkDisconnectedNotification";

@interface TIONetworkNotificationCenter ()
@property (strong, nonatomic) AFNetworkReachabilityManager *reachabilityManager;
@end

@implementation TIONetworkNotificationCenter

+ (instancetype)shareManager
{
    static TIONetworkNotificationCenter *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}

- (void)start
{
    [self.reachabilityManager startMonitoring];
}

- (void)stop
{
    [self.reachabilityManager stopMonitoring];
    self.reachabilityManager = nil;
}

- (AFNetworkReachabilityManager *)reachabilityManager
{
    if (!_reachabilityManager) {
        _reachabilityManager = [AFNetworkReachabilityManager sharedManager];
        [_reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if (status == AFNetworkReachabilityStatusNotReachable) {
                // 断网
                self->_isConnected = NO;
                [NSNotificationCenter.defaultCenter postNotificationName:TIONetworkDisconnectedNotification object:nil];
            } else if (status == AFNetworkReachabilityStatusReachableViaWiFi || status == AFNetworkReachabilityStatusReachableViaWWAN) {
                // 联网
                self->_isConnected = YES;
                [NSNotificationCenter.defaultCenter postNotificationName:TIONetworkConnectedNotification object:nil];
            } else {
                // 未知状态 暂不处理
            }
        }];
    }
    return _reachabilityManager;
}

@end

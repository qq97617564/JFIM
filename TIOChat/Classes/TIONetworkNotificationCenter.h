//
//  TIONetworkNotificationCenter.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/4.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIONetworkNotificationCenter : NSObject

+ (instancetype)shareManager;
@property (assign, nonatomic) BOOL isConnected;

- (void)start;
- (void)stop;

FOUNDATION_EXPORT NSNotificationName const TIONetworkConnectedNotification;
FOUNDATION_EXPORT NSNotificationName const TIONetworkDisconnectedNotification;

@end

NS_ASSUME_NONNULL_END

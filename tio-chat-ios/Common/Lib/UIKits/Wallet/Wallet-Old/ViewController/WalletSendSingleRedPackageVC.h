//
//  WalletSendRedPackageVC.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/9.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

/// 发送单个红包
@interface WalletSendSingleRedPackageVC : TCBaseViewController

- (instancetype)initWithFriend:(TIOUser *)user sessionId:(NSString *)sessionId;

@end

NS_ASSUME_NONNULL_END

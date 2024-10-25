//
//  WalletRechargeViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/5.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

/// 充值
@interface WalletRechargeViewController : TCBaseViewController

@property (copy,    nonatomic) NSString *uid;
@property (copy,    nonatomic) NSString *walletid;

@end

NS_ASSUME_NONNULL_END

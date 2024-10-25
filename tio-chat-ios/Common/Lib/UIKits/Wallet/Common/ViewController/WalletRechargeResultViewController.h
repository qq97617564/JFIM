//
//  WalletRechargeResultViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/18.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WalletRechargeResultViewController : TCBaseViewController

/// 1:充值成功
/// 2:充值失败
/// 3:银行处理中
@property (assign,  nonatomic) NSInteger resultType;

@property (copy,    nonatomic) NSString *money;

@property (copy,    nonatomic) NSString *errorMessage;
 
@end

NS_ASSUME_NONNULL_END

//
//  WalletWithdrawResultViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/19.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WalletWithdrawResultViewController : TCBaseViewController

@property (copy,    nonatomic) NSString *amount;
/// 提现到的银行icon
@property (copy,    nonatomic) NSString *bankIconUrl;
/// 提现到的银行名称
@property (copy,    nonatomic) NSString *bankName;
/// 服务费
@property (copy,    nonatomic) NSString *serverMoney;

@end

NS_ASSUME_NONNULL_END

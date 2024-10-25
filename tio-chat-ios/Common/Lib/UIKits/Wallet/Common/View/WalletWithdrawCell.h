//
//  WalletRechargeCell.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/5.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WalletWithdrawCell : UITableViewCell

/// 提现金额
@property (strong,  nonatomic) UILabel *moneyLabel;
/// 佣金 服务费
@property (strong,  nonatomic) UILabel *commissionLabel;

@end

NS_ASSUME_NONNULL_END

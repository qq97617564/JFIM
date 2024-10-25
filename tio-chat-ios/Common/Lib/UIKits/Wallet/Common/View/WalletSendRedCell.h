//
//  WalletSendRedCell.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/5.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WalletSendRedCell : UITableViewCell

/// 金额
@property (nonatomic,   strong) UILabel *moneyLabel;

/// 已领取的进度
@property (nonatomic,   strong) UILabel *recievedLabel;

/// 状态：已过期
@property (nonatomic,   strong) UILabel *statusLabel;

@end

NS_ASSUME_NONNULL_END

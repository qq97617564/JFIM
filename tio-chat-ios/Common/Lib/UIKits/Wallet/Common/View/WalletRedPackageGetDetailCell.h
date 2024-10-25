//
//  WalletDetailsCell.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/12.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 红包详情页内的领取cell
@interface WalletRedPackageGetDetailCell : UITableViewCell

@property (strong,  nonatomic) UILabel *moneyLabel;

/// 最佳人品
@property (assign,  nonatomic) BOOL isLucky;

@end

NS_ASSUME_NONNULL_END

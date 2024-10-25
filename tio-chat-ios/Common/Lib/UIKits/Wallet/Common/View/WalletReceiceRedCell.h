//
//  WalletReceiceRedCell.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/5.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WalletReceiceRedCell : UITableViewCell

@property (nonatomic,   strong) UILabel *moneyLabel;
@property (nonatomic,   strong) UIImageView *pinImageView;
/// 1:拼人品 0：无
@property (nonatomic,   assign) NSInteger type;

@end

NS_ASSUME_NONNULL_END

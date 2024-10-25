//
//  TNoTalkingCell.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/1/6.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 禁言列表的cell
@interface TNoTalkingCell : UITableViewCell
@property (weak,    nonatomic) UIImageView *avatarView;
@property (weak,    nonatomic) UILabel *nameLabel;
@property (weak,    nonatomic) UILabel *remarkLabel;
@property (weak,    nonatomic) UILabel *timeLabel;

/// 绑定数据
/// @param avatar 头像URL
/// @param nick 昵称
/// @param remark 备注（优先显示）
/// @param seconds 禁言时长
- (void)updateAvatar:(NSString *)avatar nick:(NSString *)nick remark:(NSString *)remark time:(NSTimeInterval)seconds forever:(BOOL)forever;

@end

NS_ASSUME_NONNULL_END

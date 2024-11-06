//
//  TSessionListCell.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/14.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMKitBadgeView.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSessionListCell : UITableViewCell

/// 头像
@property (nonatomic, weak, readonly) UIImageView *avaterView;

/// 群名/昵称
@property (nonatomic, weak, readonly) UILabel *nickLabel;
///官方标识
@property (nonatomic, weak, readonly) UIImageView *flag;

/// 最新一条消息
@property (nonatomic, weak, readonly) UILabel *messageLabel;

/// 最新一条消息的时间
@property (nonatomic, weak, readonly) UILabel *timeLabel;

/// 未读消息
@property (nonatomic, weak, readonly) IMKitBadgeView *badgeView;

/// 显示红点
@property (nonatomic,   assign) BOOL showRedDot;

/// 显示消息免打扰图标
@property (nonatomic,   assign) BOOL showDoNotDisturbIcon;


/// 是否置顶
@property (nonatomic, assign) BOOL isTop;
/// 是否官方
@property (nonatomic, assign) BOOL isGF;

- (void)setAvatarUrl:(NSString *)url;
- (void)setShowDoNotDisturbIcon:(BOOL)showDoNotDisturbIcon unreadCount:(NSInteger)unreadCount;

@end

NS_ASSUME_NONNULL_END

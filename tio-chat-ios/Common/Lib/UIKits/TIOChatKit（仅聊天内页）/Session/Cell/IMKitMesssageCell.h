//
//  IMMesssageCell.h
//  CawBar
//
//  Created by admin on 2019/11/7.
//

#import <UIKit/UIKit.h>
#import "IMMessageCellProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class IMKitAvatarImageView;
@class IMKitBadgeView;
@class IMKitMessageContentView;
@class IMKitMessageModel;

@interface IMKitMesssageCell : UITableViewCell

/// 头像显示
@property (strong, nonatomic) UIImageView *avatarView;

/// 昵称显示
@property (strong, nonatomic) UILabel *nameLabel;

/// 时间显示
@property (strong, nonatomic) UILabel *timeLabel;

/// 读取状态显示：已读未读
@property (strong, nonatomic) UILabel *readStatusLabel;

/// 气泡内容view
@property (strong, nonatomic) IMKitMessageContentView *bubbleView;

@property (nonatomic, strong) UIActivityIndicatorView *traningActivityIndicator;

/// 重发按钮
@property (nonatomic, strong) UIButton *retryButton;

@property (assign, nonatomic) id<IMMessageCellProtocol> delegate;

- (void)refreshData:(IMKitMessageModel *)messageModel;

@end

NS_ASSUME_NONNULL_END

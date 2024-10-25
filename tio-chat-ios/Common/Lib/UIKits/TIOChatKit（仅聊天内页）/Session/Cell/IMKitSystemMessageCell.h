//
//  IMKitSessionTipCell.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/5.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class IMKitSystemMessageModel;

/// 系统消息显示
/// 用于显示“XXX撤回一条消息”、“XXX被禁言、“XXX成为管理员”、“XXX被踢出群”、“XXX加入群聊” 等系统消息日志
@interface IMKitSystemMessageCell : UITableViewCell

@property (weak,    nonatomic) UILabel *msgLabel;

- (void)refreshData:(IMKitSystemMessageModel *)data;

@end

NS_ASSUME_NONNULL_END

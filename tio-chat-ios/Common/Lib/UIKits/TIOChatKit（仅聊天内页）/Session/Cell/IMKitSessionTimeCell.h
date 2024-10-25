//
//  IMKitSessionTimeCell.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/14.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class IMKitTimeModel;

/// 聊天会话中显示时间分割
@interface IMKitSessionTimeCell : UITableViewCell

@property (strong, nonatomic) UIImageView *timeBGView;

@property (strong, nonatomic) UILabel *timeLabel;

- (void)refreshData:(IMKitTimeModel *)data;

@end

NS_ASSUME_NONNULL_END

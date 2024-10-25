//
//  TTeamCell.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/14.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTeamCell : UITableViewCell

/// 头像
@property (nonatomic, weak, readonly) UIImageView *avaterView;

/// 群名
@property (nonatomic, weak, readonly) UILabel *nickLabel;

/// 群成员数量
@property (nonatomic, weak, readonly) UILabel *countLabel;

/// 是否是群主 管理员
@property (nonatomic, assign) TIOTeamUserRole role;

- (void)setAvatarUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END

//
//  TInviteUserCell.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTeamInviteModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 邀请好友入群的好友列表的用户cell
@interface TInviteUserCell : UITableViewCell

@property (nonatomic, strong) TTeamInviteModel *model;
- (void)refreshData:(TTeamInviteModel *)model;
@property (copy, nonatomic) void(^selectedCallback)(BOOL selected);

@end

NS_ASSUME_NONNULL_END

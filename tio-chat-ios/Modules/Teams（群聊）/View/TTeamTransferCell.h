//
//  TTeamTransferMemberCell.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/3.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// 转让群的成员列表cell
@interface TTeamTransferCell : UITableViewCell

/// 设置头像
- (void)setAvatarUrl:(NSString *)url;
/// 设置昵称
- (void)setNick:(NSString *)nick;

@end

NS_ASSUME_NONNULL_END

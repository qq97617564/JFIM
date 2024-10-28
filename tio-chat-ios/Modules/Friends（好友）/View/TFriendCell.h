//
//  TFriendCell.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/9.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>
/// SDK
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFriendCell : UITableViewCell

/// 设置头像
- (void)setAvatarUrl:(NSString *)url;
/// 设置昵称
- (void)setNick:(NSString *)nick;
/// 新的好友请求时    备注说明详细
- (void)setDetail:(NSString * _Nullable )detail;
@property(nonatomic, strong)UIImageView *flag;
@end

NS_ASSUME_NONNULL_END

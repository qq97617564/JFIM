//
//  TNewFriendCell.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/13.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>
/// SDK
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

@class TNewFriendCell;

@protocol TNewFriendCellDelegate <NSObject>
/// 允许添加
- (void)onAddFriend:(TNewFriendCell *)cell;
/// 拒绝
- (void)onRejectFriend:(TNewFriendCell *)cell;
/// 忽略加好友请求
- (void)onIgnoreFriend:(TNewFriendCell *)cell;

@end


@interface TNewFriendCell : UITableViewCell

@property (nonatomic, weak) UILabel *nickLabel;

@property (nonatomic, weak) UILabel *msgLabel;

@property (nonatomic, assign) TIOFriendReqStatus reqStatus;

@property (nonatomic, assign) id<TNewFriendCellDelegate> delegate;

- (void)setAvatarUrl:(NSString *)url;

@end

NS_ASSUME_NONNULL_END

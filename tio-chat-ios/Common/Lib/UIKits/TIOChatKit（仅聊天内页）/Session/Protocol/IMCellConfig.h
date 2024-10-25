//
//  IMMessageCellConfig.h
//  CawBar
//
//  Created by admin on 2019/11/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class IMKitMessageModel;

@protocol IMCellLayoutConfig <NSObject>

/// 返回message的内容大小
/// @param width cell宽
- (CGSize)contentSize:(IMKitMessageModel *)model cellWidth:(CGFloat)width;

/// 需要构造的cellContent类名
- (NSString *)cellContent:(IMKitMessageModel *)model;

/// 左对齐的气泡，cell气泡距离整个cell的内间距
- (UIEdgeInsets)cellInsets:(IMKitMessageModel *)model;

/// 左对齐的气泡，cell内容距离气泡的内间距
- (UIEdgeInsets)contentViewInsets:(IMKitMessageModel *)model;

/// 左对齐的气泡，头像控件的 size
- (CGSize)avatarSize:(IMKitMessageModel *)model;

/// 左对齐的气泡，头像控件的 origin 点
- (CGPoint)avatarMargin:(IMKitMessageModel *)model;

/// 左对齐的气泡，昵称控件的 origin 点
- (CGPoint)nickNameMargin:(IMKitMessageModel *)model;

/// 消息显示在左边
- (BOOL)shouldShowLeft:(IMKitMessageModel *)model;

/// 是否显示头像
- (BOOL)shouldShowAvatar:(IMKitMessageModel *)model;

/// 是否显示昵称
- (BOOL)shouldShowNick:(IMKitMessageModel *)model;

/// 是否显示时间
- (BOOL)shouldShowTime:(IMKitMessageModel *)model;

/// 是否显示未读消息
- (BOOL)shouldShowUnread:(IMKitMessageModel *)model;

/// 是否开启重试叹号开关
- (BOOL)disableRetryButton:(IMKitMessageModel *)model;

@end

NS_ASSUME_NONNULL_END

//
//  IMMessageModel.h
//  CawBar
//
//  Created by admin on 2019/11/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMKitMessageModel : NSObject

@property (nonatomic, strong)   TIOMessage * message;

/// 时间戳
@property (nonatomic,readonly) NSTimeInterval messageTime;

@property (nonatomic, readonly) UIEdgeInsets  contentViewInsets;

@property (nonatomic, readonly) UIEdgeInsets  bubbleViewInsets;

@property (nonatomic, readonly) CGPoint avatarMargin;

@property (nonatomic, readonly) CGPoint nickNameMargin;

@property (nonatomic, readonly) CGSize avatarSize;

@property (nonatomic, readonly) BOOL shouldShowAvatar;

@property (nonatomic, readonly) BOOL shouldShowLeft;

@property (nonatomic, readonly) BOOL shouldShowUnRead;

@property (nonatomic, readonly) BOOL shouldShowTime;

@property (nonatomic, copy) NSString *messageContentName;

- (instancetype)initWithMessage:(TIOMessage *)message;

/// 计算内容大小
- (CGSize)contentSize:(CGFloat)width;

/**
 *  清楚缓存的排版数据
 */
- (void)cleanCache;

@end

NS_ASSUME_NONNULL_END

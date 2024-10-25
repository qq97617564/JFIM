//
//  IMKitEvent.h
//  CawBar
//
//  Created by admin on 2019/11/15.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class IMKitMessageModel;

@interface IMKitEvent : NSObject

@property (strong, nonatomic) IMKitMessageModel *messageModel;
@property (copy,   nonatomic) NSString *eventName;
/// 点击超链接文本时
@property (strong, nonatomic) id data;

FOUNDATION_EXTERN NSString * const IMKitEventTouchDown;
FOUNDATION_EXTERN NSString * const IMKitEventTouchUpInside;
FOUNDATION_EXTERN NSString * const IMKitEventTouchUpOutside;

@end

NS_ASSUME_NONNULL_END

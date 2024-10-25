//
//  IMKitKeyInfo.h
//  CawBar
//
//  Created by admin on 2019/11/20.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IMKitKeyInfo : NSObject

//是否可见
@property (nonatomic,assign,readonly) CGFloat isVisiable;

//键盘高度
@property (nonatomic,assign,readonly) CGFloat keyboardHeight;

+ (instancetype)instance;

UIKIT_EXTERN NSNotificationName const IMKitKeyboardWillChangeFrameNotification;
UIKIT_EXTERN NSNotificationName const IMKitKeyboardWillHideNotification;

@end

NS_ASSUME_NONNULL_END

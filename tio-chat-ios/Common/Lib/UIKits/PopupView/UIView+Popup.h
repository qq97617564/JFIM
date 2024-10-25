//
//  UIView+Popup.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/9.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Popup)

/**
 展示弹出动画
 */
- (void)gp_showPopup;

/**
 消失弹出动画，与gp_showPopup配对使用
 */
- (void)gp_dismissPopup:(void(^)(void))completion;

@end

NS_ASSUME_NONNULL_END

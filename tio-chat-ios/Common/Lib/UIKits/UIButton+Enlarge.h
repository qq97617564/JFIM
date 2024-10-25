//
//  UIButton+Enlarge.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/15.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, ButtonEdgeInsetsStyle) {
    ButtonStyleTop,     // 图上, 文字下
    ButtonStyleRight,    // 图右, 文字左
    ButtonStyleLeft    // 图左（系统默认食物样式）
};

@interface UIButton (Enlarge)

- (void)setEnlargeEdgeWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left;
/**
 图片和文字按钮布局
 
 @param style 布局风格
 @param space 间距
 */
- (void)verticalLayoutWithInsetsStyle:(ButtonEdgeInsetsStyle)style Spacing:(CGFloat)space;

@end

NS_ASSUME_NONNULL_END

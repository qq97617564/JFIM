//
//  UIImage+TColor.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/2.
//  Copyright © 2020 刘宇. All rights reserved.
//


#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, UIGradientStyle) {
    UIGradientStyleLeftToRight,
    UIGradientStyleRadial,
    UIGradientStyleTopToBottom,
};

@interface UIImage (TColor)

/**
 根据颜色创建图片

 @param color 颜色
 @return 创建的图片
 */
+ (instancetype)imageWithColor:(UIColor *)color;

/**
 给静态图片添加圆角

 @param cornerRadius 圆角
 @param newSize 图片大小
 @return 添加圆角的图片
 */
- (UIImage *)imageWithCornerRadius:(CGFloat)cornerRadius size:(CGSize)newSize;

- (UIImage *)scaleImage:(CGSize)newSize;

+ (UIImage *)CGContextClip:(UIImage *)img cornerRadius:(CGFloat)c;
+ (UIImage *)UIBezierPathClip:(UIImage *)img cornerRadius:(CGFloat)c;

/**
 渐变色

 @param gradientStyle 方向
 @param frame 尺寸
 @param colors 颜色数组
 @return 变色图片
 */
+ (UIImage *)colorWithGradientStyle:(UIGradientStyle)gradientStyle withFrame:(CGRect)frame andColors:(NSArray *)colors;

@end

NS_ASSUME_NONNULL_END

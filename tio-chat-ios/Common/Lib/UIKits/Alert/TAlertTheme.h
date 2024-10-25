//
//  TAlertControllerTheme.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/19.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TAlertActionStyle) {
    TAlertActionStyleDefault = 0,   ///<  默认
    TAlertActionStyleCancel,        ///<  取消
    TAlertActionStyleDone,          ///<  完成
    TAlertActionStyleWhite,         ///<  白色
};

FOUNDATION_EXPORT NSString* const TAlertActionBackgroundImageKey;
FOUNDATION_EXPORT NSString* const TAlertActionBackgroundColorKey;
FOUNDATION_EXPORT NSString* const TAlertActionHlightBackgroundColorKey;


@interface TAlertTheme : NSObject

/**
 默认文字样式
 */
@property (strong, nonatomic) NSDictionary<NSString *,id> *titleTextAttributes;

/**
默认文字样式
*/
@property (strong, nonatomic) NSDictionary<NSString *,id> *messageTextAttributes;

/**
 默认标题背景色
 */
@property (strong, nonatomic) UIColor *titleBackgroundColor;

/**
 默认内容背景色
 */
@property (strong, nonatomic) UIColor *contentBackgroundColor;

/**
 设置按钮默认属性

 @param titleTextAttributes 按钮文字属性
 @param state 按钮状态
 @param style 按钮样式
 */
- (void)setActionTitleAttributes:(NSDictionary<NSString *,id> *)titleTextAttributes forState:(UIControlState)state forActionStyle:(TAlertActionStyle)style;


/**
 获取按钮属性

 @param state 按钮状态
 @param style 按钮样式
 @return 按钮属性
 */
- (NSDictionary<NSString *,id> *)actionTitleAttributesForState:(UIControlState)state forActionStyle:(TAlertActionStyle)style;
- (NSDictionary<NSString *,id> *)actionAttributesForActionStyle:(TAlertActionStyle)style;

@end

NS_ASSUME_NONNULL_END

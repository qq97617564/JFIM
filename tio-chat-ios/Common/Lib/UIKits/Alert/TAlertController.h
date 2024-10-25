//
//  TAlertController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/19.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAlertTheme.h"
#import "TAlertLayout.h"

NS_ASSUME_NONNULL_BEGIN

@class TAlertAction;
typedef void(^TAlertActionHandler)(TAlertAction *action);

@interface TAlertAction : NSObject

+ (instancetype)actionWithTitle:(nullable NSString *)title style:(TAlertActionStyle)style handler:(TAlertActionHandler)handler;

@end

/// 弹窗类型
typedef NS_ENUM(NSUInteger, TAlertControllerStyle) {
    TAlertControllerStyleActionSheet = 0,
    TAlertControllerStyleAlert
};


@interface TAlertController : UIViewController

/// 一行的最大action数量 超出换行
/// 默认一行最多2个action
@property (assign, nonatomic) NSInteger maxActionCountOfOneLine;
@property (strong, nonatomic) UIView *contentView;
/// 自定义顶部 仅当TAlertControllerStyleActionSheet有效
@property (strong, nonatomic) UIView *headerView;

/// 创建弹窗
/// @param title 标题
/// @param message 内容
/// @param preferredStyle 弹窗类型 当为TAlertControllerStyleActionSheet时，标题和内容不起效
+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(TAlertControllerStyle)preferredStyle;

+ (instancetype)alertControllerWithTitle:(NSString *)title customView:(UIView *)customView preferredStyle:(TAlertControllerStyle)preferredStyle;

- (instancetype)initWithTitle:(NSString *)title contentView:(UIView *)contentView;

/// 自定义
/// @param customView 包括标题+内容
- (instancetype)initWithCustomView:(UIView *)customView;
/// 自定义头部 仅当TAlertControllerStyleActionSheet有效
- (instancetype)initWithHeaderView:(UIView *)headerView;

- (void)addAction:(TAlertAction *)action;

///  入口类先配置全局的theme和layout
+ (void)registerDefaultTheme:(TAlertTheme *)theme;
+ (void)registerDefaultLayout:(TAlertLayout *)layout forStyle:(TAlertControllerStyle)style;



@property (weak, nonatomic) UIView *containerView;
- (void)setupAlertContentView;



@end

NS_ASSUME_NONNULL_END

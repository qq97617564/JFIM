//
//  TEdittingViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/4.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@class TEdittingViewController;

typedef NS_ENUM(NSUInteger, TEdittingInputType) {
    TEdittingInputTypeField,    ///< 单行输入
    TEdittingInputTypeView,     ///< 多行文本输入
};

typedef void(^TEdittingHandler)(BOOL flag, NSString * __nullable msg);


@protocol TEdittingViewControllerDelegate <NSObject>
/// 点击提交，回馈给上层处理网络数据
/// @param edittingViewController 页面
/// @param text 文本
/// @param handler 上层的处理结果 回馈给TEdittingViewController网络处理结果
- (void)t_edittingViewController:(TEdittingViewController *)edittingViewController
                 didFinishedText:(NSString *)text
                         handler:(TEdittingHandler)handler;
@end

@interface TEdittingViewController : TCBaseViewController

- (instancetype)initWithTitle:(NSString *)title text:(NSString *)text inputType:(TEdittingInputType)inputType;

/// 修改类型
@property (assign,  nonatomic) NSInteger type;
/// TEdittingInputTypeField默认60
/// TEdittingInputTypeView默认200
@property (assign,  nonatomic) CGFloat inpuHeight;

/// 最大输入字数
@property (assign,  nonatomic) NSInteger maxNumber;

/// 代理
@property (assign,  nonatomic) id<TEdittingViewControllerDelegate> delegate;

/// 是否自动返回上一页
@property (assign,  nonatomic) BOOL isAutoBack;

@end

NS_ASSUME_NONNULL_END

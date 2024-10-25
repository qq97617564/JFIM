//
//  IMInputView.h
//  CawBar
//
//  Created by admin on 2019/11/13.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "IMKitAction.h"
#import "IMKitInputMoreItem.h"

NS_ASSUME_NONNULL_BEGIN

@class IMKitInputMoreItem;
@protocol IMKitInputView;

typedef NS_ENUM(NSInteger,IMInputStatus)
{
    IMInputStatusText,
    IMInputStatusAudio,
    IMInputStatusEmoticon,
    IMInputStatusMore
};

typedef NS_ENUM(NSUInteger, TAudioRecordStatus) {
    AudioRecordStatusBegin,
    AudioRecordStatusRecording,
    AudioRecordStatusCancelling,
    AudioRecordStatusEnd,
};

@protocol IMKitInputViewActionDelegate <NSObject>

- (void)onTextChanged:(id)sender;

- (void)onSendText:(NSString *)text
           atUsers:(NSArray *)atUsers;

- (void)onSelectChartlet:(NSString *)chartletId
                 catalog:(NSString *)catalogId;


#pragma mark - 录音UI操作回调

/// 按下录音按钮 开始计时
- (void)recordBeginTouch;
/// 在录音按钮上松开手指 —— 正常结束录音
- (void)recordFinishInButton;
/// 在录音按钮外面松开手指 —— 取消
- (void)recordFinishOutButton;
/// 手指滑动到录音按钮手势响应区域外 —— 提示取消录音 【录音及计时正常进行】
- (void)recordDragToOut;
/// 手指又返回录音按钮手势响应区域 —— 恢复正常录音 显示计时
- (void)recordDragBackToButton;


- (void)onTapMoreBtn:(id)sender;

- (void)onTapEmoticonBtn:(id)sender;

- (void)onTapVoiceBtn:(id)sender;

- (void)onTapMoreItem:(IMKitInputMoreItem *)moreItem;

@end

@protocol IMKitInputViewDelegate <NSObject>
@optional
- (void)didChangeInputHeight:(CGFloat)inputHeight;
/// 监听到用户输入@触发
/// 调用 IMKitInputView 的 insertText: 插入选中艾特后的内容到输入框
- (void)beginAt:(id<IMKitInputView>)inputView;

@end

@protocol IMKitInputViewConfig <NSObject>

@optional
/// 更多的面板
- (NSArray<IMKitInputMoreItem *> *)moreItems;

/// 更多面板中每一选项的size
- (CGSize)moreItemSize;

/// 更多面板内容四边内距
- (UIEdgeInsets)moreContainerContentInsets;

/// 最大字符输入数量
- (NSInteger)maxInputCharCount;

- (BOOL)shouldAt;

@end

@protocol IMKitInputView <NSObject>

- (UIView *)view;

- (UIView *)toolBar;

- (BOOL)keyboardIsVisiable;

@property (assign, nonatomic) IMInputStatus status;

@property (assign, nonatomic) id<IMKitInputViewDelegate> delegate;

@property (assign, nonatomic) id<IMKitInputViewActionDelegate> actionDelegate;

@property (assign, nonatomic) id<IMKitInputViewConfig> config;

@property (assign, nonatomic) BOOL recording;

@property (assign, nonatomic) TAudioRecordStatus recordStatus;
@property (assign, nonatomic) NSTimeInterval recordTime;

- (void)refreshStatus:(IMInputStatus)status;

- (void)forbidSpeaking:(BOOL)isForbidSpeaking;

- (BOOL)endEditing:(BOOL)force;

- (void)beginEditing;

- (void)insertText:(NSString *)text;

/// 外部插入艾特信息
/// @param nick @的用户昵称
/// @param uid @ 的用户ID
/// @param hasAtChar 是否插入@字符 。NO：只插入Nick，YES：“@张三”
- (void)insertAtUser:(NSString *)nick uid:(NSString *)uid hasAtChar:(BOOL)hasAtChar;

@end

NS_ASSUME_NONNULL_END

//
//  IMKitInputBar.h
//  CawBar
//
//  Created by admin on 2019/11/15.
//

#import <UIKit/UIKit.h>
#import "NIMGrowingTextView.h"
#import "IMInputViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class IMKitInputMoreItem;
@class IMKitAction;

@protocol IMKitInputBarDelegate <NSObject>

- (BOOL)textViewShouldBeginEditing;

- (void)textViewDidEndEditing;

- (BOOL)shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)replacementText;

- (void)textViewDidChange;

- (void)toolBarWillChangeHeight:(CGFloat)height;

- (void)toolBarDidChangeHeight:(CGFloat)height;

- (void)sendText:(NSString *)text;

@end


/// 输入栏
@interface IMKitInputBar : UIView

@property (nonatomic, weak) UIButton *voiceButton;  // 切换键盘录音
@property (nonatomic, weak) UIButton *moreButton;   // 更多按钮
@property (nonatomic, weak) UIButton *emojiButton;  // 表情键盘
@property (nonatomic, weak) UIButton *recordVoiceButton; // 录音按钮

@property (assign, nonatomic) id<IMKitInputBarDelegate> delegate;

@property (nonatomic,copy) NSString *contentText;
@property (nonatomic,strong) NIMGrowingTextView *inputTextView;

@property (assign, nonatomic) BOOL showKeyboard;

- (instancetype)initWithFrame:(CGRect)frame delegate:(id<IMKitInputBarDelegate>)delegate;

- (NSRange)selectedRange;

- (void)refreshStatus:(IMInputStatus)status;

- (void)insertText:(NSString *)text;

- (void)deleteText:(NSRange)range;

@end

NS_ASSUME_NONNULL_END

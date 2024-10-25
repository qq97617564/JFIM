//
//  IMKitContainer.h
//  CawBar
//
//  Created by admin on 2019/11/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NIMGrowingTextView;

@protocol IMKitEmotionDelegate <NSObject>
- (void)imkit_stickerKeyboardDidClickSendButton;
@end

@interface IMKitEmotionContainer : UIView

@property (weak, nonatomic) NIMGrowingTextView *textView;
@property (assign, nonatomic) id<IMKitEmotionDelegate> delegate;

@end

NS_ASSUME_NONNULL_END

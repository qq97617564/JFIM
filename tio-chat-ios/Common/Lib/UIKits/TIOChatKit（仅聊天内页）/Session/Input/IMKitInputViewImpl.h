//
//  IMKitInputView.h
//  CawBar
//
//  Created by admin on 2019/11/18.
//

#import <UIKit/UIKit.h>
#import "IMInputViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class IMKitInputBar;
@class IMKitEmotionContainer;
@class IMKitMoreContainer;

@interface IMKitInputViewImpl : UIView <IMKitInputView>

@property (strong, nonatomic, readonly) IMKitInputBar *bar;

@property (strong, nonatomic, readonly) IMKitEmotionContainer *emojiContainer;
@property (strong, nonatomic, readonly) IMKitMoreContainer *moreCcontainer;

- (instancetype)initWithFrame:(CGRect)frame config:(id<IMKitInputViewConfig>)config;

@end

NS_ASSUME_NONNULL_END

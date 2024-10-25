//
//  IMMessageContentView.h
//  CawBar
//
//  Created by admin on 2019/11/7.
//

#import <UIKit/UIKit.h>
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

@class IMKitMessageModel;
@class IMKitEvent;
@class TIOMessage;
    
@protocol IMKitMessageContentViewDelegate <NSObject>

- (void)onTap:(IMKitEvent *)event;

- (void)onLongTap:(TIOMessage *)message;

@end

@interface IMKitMessageContentView : UIControl

@property (strong, nonatomic) IMKitMessageModel *messageModel;

@property (strong, nonatomic) UIImageView *bubbleImageView;

@property (assign, nonatomic) id<IMKitMessageContentViewDelegate> delegate;

- (void)refreshData:(IMKitMessageModel *)messageModel;
- (void)onTouchDown:(id)sender;
- (void)onTouchUpInside:(id)sender;
- (void)onTouchUpOutside:(id)sender;

@end

NS_ASSUME_NONNULL_END

//
//  IMKitMessageTipContentView.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/5.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "IMKitMessageContentView.h"
@class M80AttributedLabel;

NS_ASSUME_NONNULL_BEGIN

@interface IMKitMessageTipContentView : IMKitMessageContentView

@property (weak,    nonatomic) M80AttributedLabel *msgLabel;
@property (weak,    nonatomic) UILabel *timeLabel;
@property (weak,    nonatomic) UIView *msgBgView;

@end

NS_ASSUME_NONNULL_END

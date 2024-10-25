//
//  IMKitMessageImageContentView.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/13.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "IMKitMessageContentView.h"
#import <YYWebImage.h>

NS_ASSUME_NONNULL_BEGIN

@interface IMKitMessageImageContentView : IMKitMessageContentView

@property (nonatomic,strong) YYAnimatedImageView * imageView;

@end

NS_ASSUME_NONNULL_END

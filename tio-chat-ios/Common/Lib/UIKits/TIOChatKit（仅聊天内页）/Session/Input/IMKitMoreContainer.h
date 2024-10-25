//
//  IMKitMoreContainer.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/22.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMInputViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface IMKitMoreContainer : UIView

@property (assign, nonatomic) id<IMKitInputViewActionDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame config:(id<IMKitInputViewConfig>)config;

@end

NS_ASSUME_NONNULL_END

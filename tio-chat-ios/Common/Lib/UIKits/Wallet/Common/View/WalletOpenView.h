//
//  WalletOpenView.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/11.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WalletDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface WalletOpenView : UIView

@property (copy,    nonatomic) void(^openBlock)(id data);
@property (copy,    nonatomic) void(^seeOthersBlock)(id data);

- (instancetype)initWithFrame:(CGRect)frame Type:(WalletStatus)walletStatus isSelf:(BOOL)isSelf avatar:(NSString *)avatar nick:(NSString *)nick remark:(NSString *)remark;

@end

NS_ASSUME_NONNULL_END

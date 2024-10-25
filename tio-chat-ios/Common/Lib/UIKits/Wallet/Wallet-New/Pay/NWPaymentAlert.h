//
//  NWPaymentAlert.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/5.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYPaymentSecurityField.h"

NS_ASSUME_NONNULL_BEGIN


@interface NWPaymentAlert : UIView

/// 标题
@property (weak,    nonatomic) UILabel *titleLabel;
/// 金额
@property (weak,    nonatomic) UILabel *moneyLabel;
@property (weak,    nonatomic) UILabel *subLabel;
@property (copy,    nonatomic) NSString *money;
/// 密码框
@property (weak,    nonatomic) LYSecurityField *securityField;
@property (strong,  nonatomic) UIView *customView;
/// 输入完成的回调
@property (copy,    nonatomic) void(^inputPasswordCompleted)(NSDictionary *result, NWPaymentAlert *alert, NSString *pwd);
@property (copy,    nonatomic) void(^otherPaymentCompleted)(NSDictionary *result, NWPaymentAlert *alert);

+ (instancetype)alert;

- (void)showOnView:(UIView *)onView;
- (void)dismiss:(id)sender;

@end

NS_ASSUME_NONNULL_END

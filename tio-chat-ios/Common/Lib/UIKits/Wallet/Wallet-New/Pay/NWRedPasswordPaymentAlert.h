//
//  NWRedPasswordPaymentAlert.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/17.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LYPaymentSecurityField.h"

NS_ASSUME_NONNULL_BEGIN

@interface NWRedPasswordPaymentAlert : UIView
/// 标题label
@property (weak,    nonatomic) UILabel *titleLabel;
/// 金额label
@property (weak,    nonatomic) UILabel *moneyLabel;
/// 密码框
@property (weak,    nonatomic) LYSecurityField *securityField;

@property (copy,    nonatomic) NSString *money;
@property (copy,    nonatomic) NSString *paymentName;


/// 输入完成的回调
@property (copy,    nonatomic) void(^inputPasswordCompleted)(NSDictionary *result, NWRedPasswordPaymentAlert *alert, NSString *pwd);
@property (copy,    nonatomic) void(^otherPaymentCompleted)(NWRedPasswordPaymentAlert *paymentAlert, void(^completion)(BOOL dismiss));

+ (instancetype)alert;

- (void)showOnView:(UIView *)onView;
- (void)dismiss:(id)sender;
@end

NS_ASSUME_NONNULL_END

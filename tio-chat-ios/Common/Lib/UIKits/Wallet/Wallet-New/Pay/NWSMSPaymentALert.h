//
//  NWSMSPaymentALert.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/12.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NWSMSPaymentALert : UIView
/// 标题
@property (weak,    nonatomic) UILabel *titleLabel;
/// 金额
@property (weak,    nonatomic) UILabel *moneyLabel;
@property (weak,    nonatomic) UILabel *subLabel;
@property (weak,    nonatomic) UILabel *subLabel2;
@property (copy,    nonatomic) NSString *money;
@property (copy,    nonatomic) NSString *phone;
@property (copy,    nonatomic) NSString *paymentName;

+ (instancetype)alert;

/// 选择其他付款方式
@property (copy,    nonatomic) void(^otherPaymentCompleted)(NWSMSPaymentALert *paymentAlert, void(^completion)(BOOL dismiss));
/// 处理完之后调用completion让弹窗消失
@property (copy,    nonatomic) void(^cancelHandler)(BOOL paying, NWSMSPaymentALert *paymentALert, void(^completion)(BOOL dismiss));
/// 处理发送验证码， 发送后调用completion开始计时
@property (copy,    nonatomic) void(^fetchSMSHandler)(NWSMSPaymentALert *paymentALert, void(^startCounting)(BOOL startCounter));

@property (copy,    nonatomic) void(^completeHandler)(NWSMSPaymentALert *paymentALert, NSString *sms ,void(^completion)(BOOL dismiss));

- (void)showOnView:(UIView *)onView;

@end

NS_ASSUME_NONNULL_END

//
//  NWPay.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/5.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NWPaymentChannel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NWBusinessCode) {
    NWBusinessCodeNormalRed,///< 普通红包
    NWBusinessCodeRandomRed,///< 随机红包
    NWBusinessCodeRecharge, ///< 充值
    NWBusinessCodeWithDraw, ///< 提现
    NWBusinessCodeSelectPayment,///< 选择支付方式，直接唤起支付方式选择
};


/// 相当于独立封装了一个易支付，但只包含唤起支付弹窗，并完成相应业务操作
@interface NWPay : NSObject

+ (instancetype)shareInstance;

/// 业务类型 必传
@property (assign,  nonatomic) NWBusinessCode code;
/// 操作的金额
/// 包括：支付金额｜充值金额｜提现金额
@property (assign,  nonatomic) NSInteger amount;
/// 钱包ID 
@property (copy,    nonatomic) NSString *walletId;

/// 商户订单号 【充值、发红包】
@property (copy,    nonatomic) NSString *merrderid;
/// 预下单id  【充值、发红包】
@property (copy,    nonatomic) NSString *preorderid;

/// 开户手机号
@property (copy,    nonatomic) NSString *mobile;
/// 充值的协议号   【提现】
@property (copy,    nonatomic) NSString *agrno;
/// 红包id 【发红包】
@property (copy,    nonatomic) NSString *redId;

/// 利率：千分
@property (assign,  nonatomic) NSInteger rate;
/// 固定提现手续费
@property (assign,  nonatomic) NSInteger withholdconst;

/// 提现手续费 单位：分
@property (assign,  nonatomic) NSInteger fee;

@property (weak,    nonatomic) UIViewController *currentViewController;

/// 在外界选择好支付方式，通过该字段传入
/// 比如业务为NWBusinessCodeRecharge（充值）时
@property (assign,  nonatomic) NSInteger paymentChannel;

- (void)evoke:(void(^)(NSDictionary * _Nullable result, NWBusinessCode businessCode, NSError * _Nullable error))callback;

@end

NS_ASSUME_NONNULL_END

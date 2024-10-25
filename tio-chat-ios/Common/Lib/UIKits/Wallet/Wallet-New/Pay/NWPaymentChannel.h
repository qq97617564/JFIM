//
//  NWPaymentChannel.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/5.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NWPaymentType) {
    NWPaymentTypeCreditCard,    ///< 信用卡
    NWPaymentTypeDepositCard,   ///< 储蓄卡
    NWPaymentTypeBalance,       ///< 余额
};

/// 数据源适配该协议，才能使用NWPayChannelPicker
@protocol NWPaymentChannel <NSObject>

/// 支付类型
@property (assign,  nonatomic) NWPaymentType    type;
/// 支付方式ID
@property (assign,  nonatomic) NSString *channelId;
/// 本地图片
@property (strong,  nonatomic) UIImage  *iconImage;
/// 网络图片
@property (copy,    nonatomic) NSString *iconUrl;
/// 支付方式的名称
@property (copy,    nonatomic) NSString *name;
/// 卡号
@property (copy,    nonatomic) NSString *cardNo;

@property (copy,    nonatomic) NSString *waterImageUrl;

@property (copy,    nonatomic) NSString *back_color;

/// 卡号后四位
@property (copy,    nonatomic) NSString *backFourCardNo;

/// 协议号
@property (copy,    nonatomic) NSString *agreementNo;

/// 银行的预留手机号
@property (copy,    nonatomic) NSString *bank_phone;

@property (assign,  nonatomic) NSInteger amount;

@end

NS_ASSUME_NONNULL_END

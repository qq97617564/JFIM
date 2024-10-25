//
//  NWAddCreditCardVC.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/8.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"
#import "NWPaymentChannel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NWBindNewCardVC : TCBaseViewController

/// 信用卡和储蓄卡
@property (assign,  nonatomic) NWPaymentType cardType;

@property (copy,    nonatomic) void(^completion)(NSDictionary *result);

@end

NS_ASSUME_NONNULL_END

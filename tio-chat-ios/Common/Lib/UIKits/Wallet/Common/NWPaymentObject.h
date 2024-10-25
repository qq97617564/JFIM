//
//  NWPaymentObject.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/5.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "ImportSDK.h"
#import "NWPaymentChannel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NWPaymentObject : TIOBankCard <NWPaymentChannel>

- (instancetype)initWithModel:(TIOBankCard *)model;

@end

NS_ASSUME_NONNULL_END

//
//  NWMyBankPicker.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/4.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NWPaymentChannel.h"

NS_ASSUME_NONNULL_BEGIN

/// 支付方式选择器  余额、银行卡
@interface NWPayChannelPicker : UIView

/// 显示余额选项
/// 默认没有
/// 需要开启
@property (assign,  nonatomic) BOOL showBalance;

/// 绑定新卡后触发, 数据源外部传入，picker不负责数据获取
@property (copy,    nonatomic) void(^bindNewCard)(NWPayChannelPicker *picker, void(^refreshData)(NSArray<id<NWPaymentChannel>> *data));

- (void)showOnView:(UIView *)onView
             items:(NSArray<id<NWPaymentChannel>> *)items
          callBack:(void(^)(NSDictionary * _Nullable result, NSError * _Nullable error))callback;

@end

NS_ASSUME_NONNULL_END

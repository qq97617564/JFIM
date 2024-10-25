//
//  WalletWaterDetailVC.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/27.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

/// 流水详情页（订单详情页、交易明细页）
/// 入口：从钱包流水明细页点击
@interface WalletWaterDetailVC : TCBaseViewController

@property (strong,  nonatomic) TIOWalletWaterDeatil *model;

@end

NS_ASSUME_NONNULL_END

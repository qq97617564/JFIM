//
//  WalletWithdrawDetailVC.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/27.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

/// 提现记录详情页
/// 入口：提现表单页WalletWithdrawViewController -> 提现记录页WalletWithdrawRecordVC -> 本页面
@interface WalletWithdrawDetailVC : TCBaseViewController
@property (strong,  nonatomic) TIOWalletWithdraw *model;
@end

NS_ASSUME_NONNULL_END

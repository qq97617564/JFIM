//
//  NWWithdrawVC.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/12.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

/// 提现
@interface NWWithdrawVC : TCBaseViewController
@property (copy,    nonatomic) NSString *uid;
@property (copy,    nonatomic) NSString *walletid;
@end

NS_ASSUME_NONNULL_END

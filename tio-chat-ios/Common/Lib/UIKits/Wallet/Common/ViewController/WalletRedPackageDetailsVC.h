//
//  WalletRedDetailsVC.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/12.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"
#import "WalletDefines.h"

NS_ASSUME_NONNULL_BEGIN

/// 红包领取的详情页
@interface WalletRedPackageDetailsVC : TCBaseViewController

@property (copy,    nonatomic) NSString *uid;

@property (copy,    nonatomic) NSString *walletid;

@property (copy,    nonatomic) NSString *serialNumber;

@end

NS_ASSUME_NONNULL_END

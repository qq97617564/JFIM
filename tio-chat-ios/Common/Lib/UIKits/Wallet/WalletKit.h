//
//  WalletKit.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/10/29.
//  Copyright © 2020 刘宇. All rights reserved.
//

/**
 * Wallet 架构：
 * WalletKit (本类) 属于引入文件，只在具体的业务代码中引入import "WalletKit.h"
 * WalletManager 内置整合易支付和NWPay两种支付，开发者只需在业务代码中操作WalletManager实现相关操作，无需关心易支付和NWPay
 *
 * Wallet-New目录     NWPay 新生支付
 * Wallet-Old目录      易支付
 *
 *                WalletManager
 *                    ｜
 *                 /               \
 *             易支付              NWPay 新生支付
 */



#ifndef WalletKit_h
#define WalletKit_h

#import "TMineWalletViewController.h"
#import "TWalletAuthorizationVC.h"
#import "WalletSendTeamRedPackageVC.h"
#import "WalletManager.h"

#import "NWAuthorizationVC.h"
#import "NWHomeViewController.h"

#endif /* WalletKit_h */

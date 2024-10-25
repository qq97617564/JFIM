//
//  NWHomeViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/2.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

/// 钱包主页
@interface NWHomeViewController : TCBaseViewController
@property (copy,    nonatomic) NSString *uid;
@property (copy,    nonatomic) NSString *walletid;
@end

NS_ASSUME_NONNULL_END

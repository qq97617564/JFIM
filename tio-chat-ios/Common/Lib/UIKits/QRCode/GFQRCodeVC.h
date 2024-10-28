//
//  GFQRCodeVC.h
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/26.
//  Copyright © 2024 wgf. All rights reserved.
//

#import "TCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GFQRCodeVC : TCBaseViewController
@property (strong,  nonatomic) id qr_data;
@property (assign,  nonatomic) NSInteger isP2P;
/// 群头像或者个人头像地址
@property (copy,    nonatomic) NSString *iconUrl;
/// 二维码上的群聊名或者个人昵称
@property (copy,    nonatomic) NSString *name;
@property (copy,    nonatomic) NSString *account;
@property (assign,    nonatomic) NSInteger xx;
@end

NS_ASSUME_NONNULL_END

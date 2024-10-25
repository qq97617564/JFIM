//
//  QRCodeViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/12/3.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface QRCodeViewController : TCBaseViewController

@property (strong,  nonatomic) id qr_data;
@property (assign,  nonatomic) NSInteger isP2P;
/// 群头像或者个人头像地址
@property (copy,    nonatomic) NSString *iconUrl;
/// 二维码上的群聊名或者个人昵称
@property (copy,    nonatomic) NSString *name;

@end

NS_ASSUME_NONNULL_END

//
//  NWSettingPayPasswordVC.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/2.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, NWPayPasswordCode) {
    NWPayPasswordCodeCreate,    ///< 创建新密码
    NWPayPasswordCodeModify,    ///< 修改密码
    NWPayPasswordCodeForget,    ///< 忘记密码
    NWPayPasswordCodeAuthorization, ///< 验证身份
};

/// 设置支付密码
@interface NWSettingPayPasswordVC : TCBaseViewController

- (instancetype)initWithTitle:(NSString *)title code:(NWPayPasswordCode)code;
/// 密码设置完成回调
@property (copy,    nonatomic) void(^handler)(UIViewController *vController, BOOL re, NSString *pwd);

/// 业务类型
@property (nonatomic,   assign, readonly) NWPayPasswordCode code;

/// 当 修改密码时 传入
@property (nonatomic,   copy) NSString *oldPassword;

/// 当 忘记密码找回时 传入
@property (nonatomic,   copy) NSString *SMSCode;

@end

NS_ASSUME_NONNULL_END

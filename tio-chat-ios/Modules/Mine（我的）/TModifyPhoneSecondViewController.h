//
//  TModifyPhoneSecondViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/1/12.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TModifyPhoneSecondViewController : TCBaseViewController
/// 原手机号的验证码
@property (copy,    nonatomic) NSString *oldSMSCode;
@end

NS_ASSUME_NONNULL_END

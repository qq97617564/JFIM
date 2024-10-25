//
//  TBindPhoneToEmailViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/12/24.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TBindPhoneToEmailViewController : TCBaseViewController
/// 0:邮箱 1:三方登录
@property (assign,  nonatomic) NSInteger type;
@end

NS_ASSUME_NONNULL_END

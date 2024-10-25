//
//  TTLogin.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/12/29.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThirdLogin.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTLogin : NSObject
/// 登录
+ (void)tLoginWithType:(ThirdPlatform)platform currentVC:(UIViewController *)vc completion:(void(^)(NSError * _Nullable error))completion;
@end

NS_ASSUME_NONNULL_END

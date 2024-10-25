//
//  TTLogin.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/12/29.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TTLogin.h"
#import "ImportSDK.h"
#import "APPHTTPManager.h"
#import "MBProgressHUD+NJ.h"

@implementation TTLogin

+ (void)tLoginWithType:(ThirdPlatform)platform currentVC:(UIViewController *)vc completion:(void (^)(NSError * _Nullable))completion
{
    CBWeakSelf
    
    NSString *appid = @"";
    NSString *appSecertKey = @"";
    if (platform == ThirdPlatformQQ) {
        appid = @"1111104478";
    } else if (platform == ThirdPlatformWX) {
        appid = @"wx37ec23215377eec0";
        appSecertKey = @"a6706cef2f852bd5ce5d3aa9d183882a";
    } else {
        appid = @"";
    }
    
    ThirdConfig *config = [ThirdConfig.alloc init];
    config.appId = appid;
    config.appSecertKey = appSecertKey;
    config.UniversalLink = @"https://www.tiocloud.com/.well-known/";
    config.type = platform;
    
    // 开始唤起三方APP
    [ThirdLogin.shareInstance loginWithPlatform:platform currentVC:vc completion:^(ThirdResponse * _Nullable result, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (error) {
            DDLogError(@"error => %@",error);
            completion(error);
        } else {
            
            /// 随便吊起一个API，刷新token
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                CBWeakSelf
//                [APPHTTPManager t_POST:@"/config/base" parameters:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                    // 极为重要的一步
//                    TIOTokenStorage.shareStorage.cookieName = responseObject[@"data"][@"session_cookie_name"];
//                    CBStrongSelfElseReturn
                    
                    
                    /// 正式开始登录流程
                    /// SDK 登录第一步
                    CBWeakSelf
                    TIOThirdLoginOption *option1 = [TIOThirdLoginOption.alloc init];
                    option1.type = platform;
                    option1.openid = result.openid;
                    [TIOChat.shareSDK.loginManager tLogin1:option1 completion:^(NSDictionary * _Nullable responObject, NSError * _Nullable error) {
                        CBStrongSelfElseReturn
                        if (error) {
                            completion(error);
                        } else {
                            DDLogVerbose(@"%@",result);
                            NSString *uuid = responObject[@"data"];
                            
                            /// SDK 登录第二步
                            CBWeakSelf
                            TIOThirdLoginOption *option2 = [TIOThirdLoginOption.alloc init];
                            option2.type = platform;
                            option2.openid = result.openid;
                            option2.unionid = result.unionId;
                            option2.uuid = uuid;
                            option2.nick = result.name;
                            option2.avatar = result.icon;
                            option2.sex = [result.gender isEqualToString:@"男"] ?1:2;
                            if (platform == ThirdPlatformQQ) {
                                option2.is_yellow_vip = [result.originalResponse[@"is_yellow_vip"] integerValue];
                                option2.yellow_vip_level = [result.originalResponse[@"level"] integerValue];
                            } else {
                                option2.country = result.originalResponse[@"country"] ?: @"";
                                option2.province = result.originalResponse[@"province"] ?: @"";
                                option2.city = result.originalResponse[@"city"] ?: @"";
                            }
                            [MBProgressHUD showLoading:@"正在登录" toView:vc.view];
                            [TIOChat.shareSDK.loginManager tLogin2:option2 completion:^(TIOLoginUser * _Nullable userData, NSError * _Nullable error) {
                                CBStrongSelfElseReturn
                                [MBProgressHUD hideHUDForView:vc.view];
                            }];
                        }
                    }];
                    
                    
//                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                    CBStrongSelfElseReturn
//                } retryCount:1];
            });
            
        }
    }];
    
}




@end

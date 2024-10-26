//
//  TIOLoginManager.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOLoginManager.h"
#import "TIOHTTPSManager.h"
#import "TIOBroadcastDelegate.h"
#import "TIOSocketPackage.h"
#import "NSString+MD5.h"
#import "TIOMacros.h"
#import "TIOUser.h"
#import "NSObject+CBJSONSerialization.h"
#import "TIOCmdConfiguator.h"
#import "TIOChat.h"
#import "NSString+tio.h"
#import "UIImage+tio.h"
#import "TIOSystemNotification.h"
#import "TIODBDefines.h"
#import "BGDB.h"
#import "TIONetworkNotificationCenter.h"
#import "TIOTokenStorage.h"
#import "TIOUploadManager.h"

#if __has_include(<YYModel/YYModel.h>)
#import <YYModel.h>
#else
#import "YYModel.h"
#endif

#if __has_include("MBProgressHUD+NJ.h")
#import "MBProgressHUD+NJ.h"
#endif

@implementation TIOKickReason
- (NSString *)description
{
    return [NSString stringWithFormat:@"\ncode:%zd\nreason:%@",self.code,self.msg];
}
@end

@implementation TIOThirdLoginOption

@end


@interface TIOLoginUser ()<YYModel>
@end

@implementation TIOLoginUser

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        [self modelInitWithCoder:coder];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [self modelEncodeWithCoder:coder];
}

+ (NSDictionary<NSString *,NSString *> *)JSONKeyPropertyMapping
{
    return @{
        @"userId" : @"id",
        @"country" : @"ipInfo.country",
        @"province" : @"ipInfo.province",
        @"city" : @"ipInfo.city",
    };
}

- (NSString *)avatar
{
    return _avatar.tio_resourceURLString;
}

- (NSDictionary *)jsonObject
{
    return [self yy_modelToJSONObject];
}

@synthesize avatar = _avatar;

@end


@interface TIOLoginManager ()
@property (nonatomic, strong) TIOBroadcastDelegate<TIOLoginDelegate> *multiDelegate;
@property (nonatomic, strong) TIOLoginUser *currentUser;
@property (nonatomic, copy)   TIOLoginHandler2 loginHandler;
@end

@implementation TIOLoginManager

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self name:@"kOnKickNotificationNotification" object:@"kOnKickNotification"];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 多播委托管理初始化
        _multiDelegate = (TIOBroadcastDelegate<TIOLoginDelegate> *)[TIOBroadcastDelegate.alloc init];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(obersverKick:) name:@"kOnKickNotification" object:@"kOnKickNotification"];
    }
    return self;
}

#pragma mark - 公开

- (void)tLogin1:(TIOThirdLoginOption *)option completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    if (option.type && option.openid) {
        NSString *token = TIOTokenStorage.shareStorage.token;
        if (token.length == 0) {
            completion(nil, [NSError errorWithDomain:TIOChatErrorDomain code:1000 userInfo:@{NSLocalizedDescriptionKey: @"三方登录token为空"}]);
            return;
        }
        
        NSString *url = [NSString stringWithFormat:@"/tlogin/%zd",option.type];
        NSString *string = [NSString stringWithFormat:@"%@%@%zd",option.openid,token,option.type];
        NSString *sign = [string MD5Digest];
        NSDictionary *params = @{
                                 @"openid" : option.openid,
                                 @"sign" : sign
                                 };
        
        [TIOHTTPSManager tio_POST:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            completion(responseObject, nil);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            completion(nil, error);
        } retryCount:1];
    }
}

- (void)tLogin2:(TIOThirdLoginOption *)option completion:(nonnull TIOLoginHandler2)completion
{
    NSString *url = [NSString stringWithFormat:@"/tlogin/cb/p/%zd",option.type];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    // 第二步：登录
    [params setObject:option.uuid forKey:@"uuid"];
    [params setObject:option.unionid forKey:@"unionid"];
    [params setObject:option.openid forKey:@"openid"];
    [params setObject:option.nick forKey:@"nick"];
    [params setObject:option.avatar forKey:@"avatar"];
    [params setObject:@(option.sex) forKey:@"sex"];

    if (option.type == 11) {
        [params setObject:@(option.is_yellow_vip) forKey:@"is_yellow_vip"];
        [params setObject:@(option.yellow_vip_level) forKey:@"yellow_vip_level"];
    }
    
    if (option.type == 22) {
        [params setObject:option.country forKey:@"country"];
        [params setObject:option.province forKey:@"province"];
        [params setObject:option.city forKey:@"city"];
    }
    
    [TIOHTTPSManager tio_POST:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self saveCookie];
        
        [self updateUserInfo:^(TIOLoginUser * _Nullable user, NSError * _Nullable error) {
            if (!error) {
                self.loginHandler = completion;
                [self changeDB:[NSString stringWithFormat:@"%@",user.userId]];
                
                [TIOChat.shareSDK lunch];
                
            } else {
                
                completion(nil, error);
                
                [self->_multiDelegate onLogin:error];
            }
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    } retryCount:1];
}

- (void)login:(NSString *)account password:(NSString *)password completion:(nonnull TIOLoginHandler2)completion
{
    // 登录前如果有长链接在连接，断开
    if ([TIOChat.shareSDK isConnected]) {
        [TIOChat.shareSDK finish];
    }
    
    [self clearCookisToken];
    
    NSError *error = nil;
    if (account.length == 0) {
        error = [NSError errorWithDomain:TIOChatErrorDomain code:1000 userInfo:@{NSLocalizedDescriptionKey: @"账户不能为空"}];
        TIOLog(@"账户不能为空");
        completion(nil,error);
        return;
    }
    if (password.length == 0) {
        error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"密码不能为空"}];
        TIOLog(@"密码不能为空");
        completion(nil,error);
        return;
    }
    
    NSString *plainStr  = [NSString stringWithFormat:@"${%@}%@",account,password];
    NSString *pd5       = plainStr.MD5Digest;
    NSDictionary *params = @{
        @"pd5" : pd5,
        @"loginname" : account
    };
    [TIOHTTPSManager tio_POST:@"/login" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        /// 登录后获取用户信息
        
        [self saveCookie];
        
        [self updateUserInfo:^(TIOLoginUser * _Nullable user, NSError * _Nullable error) {
            if (!error) {
                [self changeDB:[NSString stringWithFormat:@"%@",user.userId]];
                self.loginHandler = completion;
                
                [TIOChat.shareSDK lunch];
                
            } else {
                
                completion(nil, error);
                
                [self->_multiDelegate onLogin:error];
            }
        }];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        TIOLog(@"%@",error);
        
        completion(nil,error);
        
        [self->_multiDelegate onLogin:error];
        
    } retryCount:1];
}

/// 新登录
- (void)login:(NSString *)account password:(NSString * _Nullable)password authcode:(NSString * _Nullable)authcode completion:(nonnull TIOLoginHandler2)completion
{
    // 登录前如果有长链接在连接，断开
    if ([TIOChat.shareSDK isConnected]) {
        [TIOChat.shareSDK finish];
    }
    
    [self clearCookisToken];
    
    NSError *error = nil;
    if (account.length == 0) {
        error = [NSError errorWithDomain:TIOChatErrorDomain code:1000 userInfo:@{NSLocalizedDescriptionKey: @"账户不能为空"}];
        TIOLog(@"账户不能为空");
        completion(nil,error);
        return;
    }
    
    NSDictionary *params = nil;
    
    if (password) {
        NSString *plainStr  = [NSString stringWithFormat:@"${%@}%@",account,password];
        NSString *pd5       = plainStr.MD5Digest;
        params = @{
            @"pd5" : password,
            @"accountType" : @"3",
            @"loginname" : account
        };
    } else if (authcode) {
        params = @{
            @"loginname" : account,
            @"authcode" : authcode
        };
    } else {
        error = [NSError errorWithDomain:TIOChatErrorDomain code:1000 userInfo:@{NSLocalizedDescriptionKey: @"验证码或者密码都为空"}];
        TIOLog(@"验证码或者密码都为空");
        completion(nil,error);
        return;
    }
    
    [TIOHTTPSManager tio_POST:@"/login" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        /// 登录后获取用户信息
        
        [self saveCookie];
        
        [self updateUserInfo:^(TIOLoginUser * _Nullable user, NSError * _Nullable error) {
            if (!error) {
                [self changeDB:[NSString stringWithFormat:@"%@",user.userId]];
                self.loginHandler = completion;
                
                [TIOChat.shareSDK lunch];
            } else {
                
                completion(nil,error);
                
                [self->_multiDelegate onLogin:error];
            }
        }];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        TIOLog(@"%@",error);
        
        completion(nil,error);
        
        [self->_multiDelegate onLogin:error];
        
    } retryCount:1];
}

- (void)logout:(TIOLoginHandler)completion
{
    if (!TIONetworkNotificationCenter.shareManager.isConnected) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"当前无网络"}];
        completion(error);
        
        return;
    }
    
    [TIOHTTPSManager tio_POST:@"/logout" parameters:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        // 关闭长链接
        [TIOChat.shareSDK finish];
        [self clearLoginDB:^(BOOL isSuccess) {
            
        }];
        TIOTokenStorage.shareStorage.loginStatus = 2;
        [self clearUserInforCache];
        [self clearCookisToken];
        
        // 通知上层开发者账号退出
        [self.multiDelegate onLogout];
        
        completion(nil);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        TIOLog(@"%@",error);
        
        completion(error);
    }];
}

- (void)registerLoginname:(NSString *)loginname password:(NSString *)password nick:(NSString *)nick completion:(TIORegisterHandler)completion
{
    NSString *plainStr  = [NSString stringWithFormat:@"${%@}%@",loginname,password];
    NSString *pd5       = plainStr.MD5Digest;
    
    NSDictionary *pa = @{
        @"loginname" : loginname?:@"",
        @"pwd" : pd5?:@"",
        @"nick" : nick?:@"",
        @"agreement" : @"on"
    };
 
    [TIOHTTPSManager tio_POST:@"/register/1" parameters:pa success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *msg = responseObject[@"msg"];
        completion(nil, msg);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error, nil);
    }];
}

//- (void)registerLoginname:(NSString *)loginname password:(NSString *)password nick:(NSString *)nick code:(NSString *)code completion:(TIORegisterHandler)completion
//{
//    NSString *plainStr  = [NSString stringWithFormat:@"${%@}%@",loginname,password];
//    NSString *pd5       = plainStr.MD5Digest;
//    
//    NSDictionary *pa = @{
//        @"loginname" : loginname?:@"",
//        @"pwd" : pd5?:@"",
//        @"nick" : nick?:@"",
//        @"code" : code?:@"",
//        @"agreement" : @"on"
//    };
// 
//    [TIOHTTPSManager tio_POST:@"/register/2" parameters:pa success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSString *msg = responseObject[@"msg"];
//        completion(nil, msg);
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        TIOLog(@"error:\n%@",error);
//        completion(error, nil);
//    }];
//}
- (void)registerLoginname:(NSString *)loginname password:(NSString *)password nick:(NSString *)nick code:(NSString *)code completion:(TIORegisterHandler)completion
{
    NSString *plainStr  = [NSString stringWithFormat:@"${%@}%@",loginname,password];
    NSString *pd5       = plainStr.MD5Digest;
    
    NSDictionary *pa = @{
        @"account" : loginname?:@"",
        @"pwd" : password,
        @"nick" : nick?:@"",
        @"invitecode" : code?:@"",
        @"agreement" : @"on"
    };
 
    [TIOHTTPSManager tio_POST:@"/register/3" parameters:pa success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *msg = responseObject[@"msg"];
        completion(nil, msg);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error, nil);
    }];
}

- (void)checkMobile:(NSString *)mobile type:(NSInteger)type handler:(nonnull void (^)(NSInteger, NSError * _Nullable))handler
{
    NSDictionary *params = @{
        @"biztype" : @(type),
        @"mobile" : mobile?:@"",
    };
    [TIOHTTPSManager tio_POST:@"/sms/beforeCheck" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSInteger re = [responseObject[@"data"] integerValue];
        handler(re, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        handler(0, error);
    }];
}
-(void)updateShowAreaHandler:(nonnull void (^)(NSInteger, NSError * _Nullable))handler{
    [TIOHTTPSManager tio_POST:@"/user/updateShowArea" parameters:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSInteger re = [responseObject[@"data"] integerValue];
        // 更新用户信息
        [self updateUserInfo:^(TIOLoginUser * _Nullable user, NSError * _Nullable error) {
            
        }];
        handler(re, nil);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        handler(0, error);
    }];
}

- (void)fetchSMSWithType:(NSInteger)type mobile:(NSString *)mobile token:(NSString *)token handler:(TIOLoginHandler)handler
{
    NSDictionary *params = @{
        @"biztype" : @(type),
        @"mobile" : mobile?:@"",
        @"captchaVerification" : token?:@""
    };
    
    [TIOHTTPSManager tio_POST:@"/sms/send" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
#ifdef DEBUG
        [MBProgressHUD showInfo:responseObject[@"data"] toView:UIApplication.sharedApplication.keyWindow];
#endif
        handler(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        handler(error);
    }];
}

- (void)checkSMSCode:(NSString *)code type:(NSInteger)type mobile:(NSString *)mobile handler:(TIOLoginHandler)handler
{
    NSDictionary *params = @{
        @"biztype" : @(type),
        @"mobile" : mobile?:@"",
        @"code" : code?:@""
    };
    
    [TIOHTTPSManager tio_POST:@"/sms/check" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        handler(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        handler(error);
    }];
}

- (BOOL)isLogined
{
    TIOLoginUser *user = [self userInfo];
    return user ? YES : NO;
}

- (NSString *)currentAccount
{
    return [_currentUser loginname];
}

- (TIOLoginUser *)userInfo
{
    if (!_currentUser) {
        _currentUser = [NSKeyedUnarchiver unarchiveObjectWithFile:[self userInforPath]];
        if (!_currentUser.ip.length) {
            _currentUser.ip = [NSUserDefaults.standardUserDefaults objectForKey:@"user_ip"];
        }
    }
    
    return _currentUser;
}

- (void)updateUserInfo:(TIOMyUserBlock)completion
{
    
    [TIOHTTPSManager tio_POST:@"/user/curr" parameters:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary *data = responseObject[@"data"];
        
        if (data) {
            TIOLoginUser *user = [TIOLoginUser yy_modelWithDictionary:data];
            NSString *user_ip = [NSUserDefaults.standardUserDefaults objectForKey:@"user_ip"];
            if (user_ip) {
                user.ip = user_ip;
            }
            /// 清除本地原始缓存
            [self clearUserInforCache];
            
            BOOL flag = [NSKeyedArchiver archiveRootObject:user toFile:[self userInforPath]];
            
            if (flag) {
                self.currentUser = user;
                completion(user, nil);
                // 通知注册对象 当前账户信息更新
                [self.multiDelegate didUpdateCurrentUserInfo:user];
            } else {
                NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1000 userInfo:@{NSLocalizedDescriptionKey:@"TIO登录信息缓存失败。请重新登录"}];
                completion(nil, error);
            }
            
        } else {
            
            NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1000 userInfo:@{NSLocalizedDescriptionKey:@"TIO登录信息为空"}];
            completion(nil, error);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        TIOLog(@"%@",error);
        
        completion(nil,error);
    }];
}

- (void)updateAvatar:(UIImage *)image completion:(TIOLoginHandler)completion
{
    if (!TIONetworkNotificationCenter.shareManager.isConnected) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"当前无网络"}];
        completion(error);
        
        return;
    }
    
    [TIOUploadManager upload:@"/user/updateAvatar" parameters:@{} constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        //上传的参数(上传图片，以文件流的格式)
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        // 设置时间格式
        [formatter setDateFormat:@"yyyyMMddHHmmss"];
        NSString *dateString = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString  stringWithFormat:@"%@.jpeg", dateString];
    
        NSData *data = [image data_compressToByte:500];
        
        [formData appendPartWithFileData:data
                                    name:@"uploadFile"
                                fileName:fileName
                                mimeType:@"image/ipeg"];//multipart/form-data
        
    } progress:^(NSProgress * _Nonnull uploadProgres) {
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject[@"data"]);
        
        // 更新用户信息
        [self updateUserInfo:^(TIOLoginUser * _Nullable user, NSError * _Nullable error) {
            
        }];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(error);
    }];
}

- (void)updateNick:(NSString *)nick completion:(TIOLoginHandler)completion
{
    if (!TIONetworkNotificationCenter.shareManager.isConnected) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"当前无网络"}];
        completion(error);
        
        return;
    }
    
    NSDictionary *p = @{
        @"nick" : nick
    };
    [TIOHTTPSManager tio_POST:@"/user/updateNick" parameters:p success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
        // 更新用户信息
        [self updateUserInfo:^(TIOLoginUser * _Nullable user, NSError * _Nullable error) {
            
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(error);
    }];
}

- (void)updateSex:(TIOUserSex)sex completion:(TIOLoginHandler)completion
{
    if (!TIONetworkNotificationCenter.shareManager.isConnected) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"当前无网络"}];
        completion(error);
        
        return;
    }
    
    NSDictionary *p = @{
        @"sex" : @(sex)
    };
    [TIOHTTPSManager tio_POST:@"/user/updatSex" parameters:p success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
        // 更新用户信息
        [self updateUserInfo:^(TIOLoginUser * _Nullable user, NSError * _Nullable error) {
            
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)updateSign:(NSString *)sign completion:(TIOLoginHandler)completion
{
    if (!TIONetworkNotificationCenter.shareManager.isConnected) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"当前无网络"}];
        completion(error);
        
        return;
    }
    
    NSDictionary *p = @{
        @"sign" : sign?:@""
    };
    
    [TIOHTTPSManager tio_POST:@"/user/updatSign" parameters:p success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
        // 更新用户信息
        [self updateUserInfo:^(TIOLoginUser * _Nullable user, NSError * _Nullable error) {
            
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)updatePhone:(NSString *)phone completion:(TIOLoginHandler)completion
{
    if (!TIONetworkNotificationCenter.shareManager.isConnected) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"当前无网络"}];
        completion(error);
        
        return;
    }
    
    NSDictionary *p = @{
        @"phone" : phone?:@""
    };
    
    [TIOHTTPSManager tio_POST:@"/user/updatPhone" parameters:p success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
        // 更新用户信息
        [self updateUserInfo:^(TIOLoginUser * _Nullable user, NSError * _Nullable error) {
            
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)updatePermissionForVerifyingApply:(BOOL)needVerify completion:(TIOLoginHandler)completion
{
    if (!TIONetworkNotificationCenter.shareManager.isConnected) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"当前无网络"}];
        completion(error);
        
        return;
    }
    
    NSString *v = needVerify?@"1":@"2";
    
    [TIOHTTPSManager tio_POST:@"/user/updatValid" parameters:@{@"fdvalidtype":v} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
        // 更新用户信息
        [self updateUserInfo:^(TIOLoginUser * _Nullable user, NSError * _Nullable error) {
            
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)updatePermissionForSearchedByOther:(BOOL)allowSearched completion:(TIOLoginHandler)completion
{
    if (!TIONetworkNotificationCenter.shareManager.isConnected) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"当前无网络"}];
        completion(error);
        
        return;
    }
    
    NSString *v = allowSearched?@"1":@"2";
    
    [TIOHTTPSManager tio_POST:@"/user/updatSearchFlag" parameters:@{@"searchflag":v} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
        // 更新用户信息
        [self updateUserInfo:^(TIOLoginUser * _Nullable user, NSError * _Nullable error) {
            
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(error);
    }];
}

- (void)updatePermissionForReceivingMsgRemind:(BOOL)receiveRemind completion:(TIOLoginHandler)completion
{
    if (!TIONetworkNotificationCenter.shareManager.isConnected) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"当前无网络"}];
        completion(error);
        
        return;
    }
    
    NSString *v = receiveRemind?@"1":@"2";
    
    [TIOHTTPSManager tio_POST:@"/user/updatRemind" parameters:@{@"remindflag":v} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
        // 更新用户信息
        [self updateUserInfo:^(TIOLoginUser * _Nullable user, NSError * _Nullable error) {
            
        }];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(error);
    }];
}

- (void)updatePassword:(NSString *)newPassword oldPassword:(nonnull NSString *)oldPassword needLogout:(BOOL)needLogout completion:(nonnull TIOLoginHandler)completion
{
    // 先将新密码加密，规则同登录
    NSString *loginname = self.userInfo.phone;
    NSString *plainStr  = [NSString stringWithFormat:@"${%@}%@",loginname,newPassword];
    NSString *pd5       = plainStr.MD5Digest;
    
    
    NSDictionary *params = nil;
    
    NSString *emailname = self.userInfo.email;
    NSString *plainStr2 = [NSString stringWithFormat:@"${%@}%@",emailname,newPassword];
    NSString *pd52      = plainStr2.MD5Digest;
    
    if (emailname.length) {
        
       params = @{
           @"initPwd" : oldPassword?:@"",
           @"emailpwd" : pd52?:@"",
           @"newPwd" : pd5
       };
    } else {
        params = @{
            @"initPwd" : oldPassword?:@"",
            @"newPwd" : pd5
        };
    }
    
     
    
    [TIOHTTPSManager tio_POST:@"/user/updatePwd" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (needLogout)
        {
            [self logout:^(NSError * _Nullable error) {
                completion(error);
            }];
        }
        else
        {
            completion(nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(error);
    }];
}

- (void)findPasswordWithLoginname:(NSString *)loginname completion:(nonnull TIOFindPwdHandler)completion
{
    NSDictionary *params = @{
        @"loginname" : loginname?:@""
    };
    [TIOHTTPSManager tio_POST:@"/register/retrievePwd" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil, responseObject[@"msg"]);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error, nil);
    }];
}

- (void)beforeFindPasswordWithPhone:(NSString *)phone code:(NSString *)code completion:(nonnull void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    NSDictionary *params = @{
        @"code" : code?:@"",
        @"phone" : phone?:@"",
    };
    [TIOHTTPSManager tio_POST:@"/user/resetPwdBefore" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject[@"data"],nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(nil, error);
    }];
}

- (void)findPasswordWithNewPassword:(NSString *)password code:(NSString *)code phone:(NSString *)phone email:(NSString *)email completion:(TIOLoginHandler)completion
{
    NSString *plainStr  = [NSString stringWithFormat:@"${%@}%@",email,password];
    NSString *pd5       = plainStr.MD5Digest;
    
    NSString *plainStr2 = [NSString stringWithFormat:@"${%@}%@",phone,password];
    NSString *pd52      = plainStr2.MD5Digest;
    
    NSDictionary *params = @{
        @"code" : code?:@"",
        @"phone" : phone?:@"",
        @"phonepwd" : pd52,
        @"emailpwd" : pd5
    };
    [TIOHTTPSManager tio_POST:@"/user/resetPwd" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)bindPhone:(NSString *)phone toEmail:(nonnull NSString *)email code:(nonnull NSString *)code password:(nonnull NSString *)password option:(NSInteger)option completion:(nonnull TIOLoginHandler)completion
{
    if (option == 0) {
        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"option为空，请指定绑定的业务场景"}];
        completion(error);
        return;
    }
    
    NSString *plainStr  = [NSString stringWithFormat:@"${%@}%@",email,password];
    NSString *pd5       = plainStr.MD5Digest;
    
    NSString *plainStr2 = [NSString stringWithFormat:@"${%@}%@",phone,password];
    NSString *pd52      = plainStr2.MD5Digest;
    
    NSDictionary *params = nil;
    NSString *url = nil;
    
    if (option == 1) {
        // 注册时，手机绑定到老邮箱
        params = @{
            @"code" : code?:@"",
            @"phone" : phone?:@"",
            @"phonepwd" : pd52,
            @"emailpwd" : pd5,
            @"email" : email?:@""
        };
        url = @"/user/regbindemail";
    } else if (option == 2) {
        // 三方登录后，手机号绑定到老邮箱
        params = @{
            @"code" : code?:@"",
            @"phone" : phone?:@"",
        };
        url = @"/user/thirdbindphone";
    } else if (option == 3) {
        // 老邮箱登录后，与手机绑定
        params = @{
            @"code" : code?:@"",
            @"phone" : phone?:@"",
            @"phonepwd" : pd52,
            @"emailpwd" : pd5,
        };
        url = @"/user/bindphone";
    }
    
    [TIOHTTPSManager tio_POST:url parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([url isEqualToString:@"/user/thirdbindphone"]) {
            // 清空数据库 刷新同步数据
            [self clearLoginDB:^(BOOL isSuccess) {
                [self updateUserInfo:^(TIOLoginUser * _Nullable user, NSError * _Nullable error) {
                    if (!error) {
                        // 刷新用户信息后 数据库也发生了变化，同步数据以最新的用户数据库为准
                        bg_setSqliteName([NSString stringWithFormat:@"%@",user.userId]);
                        [TIOChat.shareSDK.conversationManager updateLocalFromRemote:^(BOOL isSuccess, NSInteger all) {
                            if (isSuccess) {
                                [self->_multiDelegate onThirdAccountDidBindToOldMobilephone:user.phone];
                                completion(nil);
                            } else {
                                completion([NSError errorWithDomain:TIOChatErrorDomain code:1001 userInfo:@{NSLocalizedDescriptionKey: @"已绑定成功，请重新登录验证绑定结果"}]);
                            }
                        } retryCount:3];
                    } else {
                        completion(error);
                    }
                }];
            }];
        } else {
            completion(nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error:\n%@",error);
        completion(error);
    }];
}

- (void)changeBoundPhone:(NSString *)phone code:(nonnull NSString *)code password:(nonnull NSString *)password email:(nonnull NSString *)email completion:(nonnull TIOOperateHandler)completion
{
    NSString *plainStr = [NSString stringWithFormat:@"${%@}%@",phone,password];
    NSString *pd5      = plainStr.MD5Digest;
    
    NSString *plainStr2  = [NSString stringWithFormat:@"${%@}%@",email,password];
    NSString *pd52       = plainStr2.MD5Digest;
    
    NSDictionary *params = nil;
    
    if (email.length) {
        params = @{
            @"code" : code?:@"",
            @"phone" : phone?:@"",
            @"phonepwd" : pd5?:@"",
            @"emailpwd" : pd52?:@""
        };
        
    } else {
        params = @{
            @"code" : code?:@"",
            @"phone" : phone?:@"",
            @"phonepwd" : pd5?:@""
        };
    }
    
    [TIOHTTPSManager tio_POST:@"/user/bindnewphone" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(-1, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(-1, error);
    } retryCount:1];
}


- (void)addDelegate:(id<TIOLoginDelegate>)delegate
{
    [_multiDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<TIOLoginDelegate>)delegate
{
    [_multiDelegate removeDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

#pragma mark - 私有方法

- (NSString *)userInforPath
{
    // 目录
    NSString *path      = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,NSUserDomainMask,YES) lastObject];
    // 绝对路径 = 目录 + 文件名
    NSString *filePath  = [path stringByAppendingString:@"/tio_user.data"];
    
    return filePath;
}

/// 清楚缓存
- (void)clearUserInforCache
{
    NSString * cachePath = [self userInforPath];
    
    NSError *error = nil;
    
    if ([[NSFileManager defaultManager ] fileExistsAtPath :cachePath]) {
        [[NSFileManager defaultManager ] removeItemAtPath :cachePath error :&error];
        if (error) {
            TIOLog(@"%@",error);
        }
    }
    
    _currentUser = nil;
}

- (void)clearLoginDB:(void(^)(BOOL isSuccess))completion
{
    // 删除该账号的数据库
    
    [BGDB.shareManager dropTable:bg_tablename complete:^(BOOL isSuccess) {
        if (isSuccess) {
            TIOLog(@"数据库删除成功");
            [BGDB.shareManager closeDB];
                
            NSFileManager *fileManager = [NSFileManager defaultManager];
            for (NSString *str in [fileManager subpathsAtPath:[NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()]]) {
                if (str.length > 3 && [[str substringWithRange:NSMakeRange(str.length - 3, 3)] isEqualToString:@".db"]) {
                    NSString *path = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(),str];
                    NSError *error = nil;
                    [fileManager removeItemAtPath:path error:&error];
                    if (error) {
                        TIOLog(@"删除数据库文件%@失败",path);
                    } else {
                        TIOLog(@"删除数据库文件%@成功",path);
                    }
                }
            }
            
            completion(YES);
        } else {
            TIOLog(@"数据库初次删除失败");
            [BGDB.shareManager closeDB];
            
            NSFileManager *fileManager = [NSFileManager defaultManager];
            for (NSString *str in [fileManager subpathsAtPath:[NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()]]) {
                if (str.length > 3 && [[str substringWithRange:NSMakeRange(str.length - 3, 3)] isEqualToString:@".db"]) {
                    NSString *path = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(),str];
                    NSError *error = nil;
                    [fileManager removeItemAtPath:path error:&error];
                    if (error) {
                        TIOLog(@"补偿删除数据库文件%@失败",path);
                    } else {
                        TIOLog(@"补偿删除数据库文件%@成功",path);
                    }
                }
            }
            
            completion(YES);
        }
    }];
}


- (void)obersverKick:(NSNotification *)notification
{
    NSNumber *code  =   notification.userInfo[@"code"];
    id msg   =   notification.userInfo[@"msg"];
    
    TIOKickReason *reason = [TIOKickReason.alloc init];
    reason.code = code.integerValue;
    reason.msg  = msg;
    
    TIOTokenStorage.shareStorage.loginStatus = 2;
    [self clearUserInforCache];
    [self clearLoginDB:^(BOOL isSuccess) {
        
    }];
    [self->_multiDelegate onKick:reason];
    [TIOChat.shareSDK finish];
}

- (void)handler:(TIOSocketPackage *)data
{
    if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:TioCmdErrorNtf]) {
        // 异常通知
        TIOSystemNotification *message = [TIOSystemNotification objectWithJSONObject:data.body];
        message.type = TIOSystemNotificationTypeError;
        
        if (message.code == TIOSystemNotificationCodeOnkicked) {
            TIOKickReason *reason = [TIOKickReason.alloc init];
            reason.code = message.code;
            reason.msg  = message.msg;
            
            TIOTokenStorage.shareStorage.loginStatus = 2;
            [self clearUserInforCache];
            [self clearLoginDB:^(BOOL isSuccess) {
                
            }];
            [self->_multiDelegate onKick:reason];
            [TIOChat.shareSDK finish];
        }
    } else if (data.cmd == [TIOChat.shareSDK.cmdManager IntCmdForKey:TioCmdShakehandResp]) {
        // 获取握手响应
        
        if (data.body[@"ip"])
        {
            self.userInfo.ip = data.body[@"ip"];
            [NSUserDefaults.standardUserDefaults setObject:data.body[@"ip"] forKey:@"user_ip"];
            [NSUserDefaults.standardUserDefaults synchronize];
        }
        
        // 收到长链接建立成功的响应，才代表真正登录成功
        // 同步会话列表
        [TIOChat.shareSDK.conversationManager updateLocalFromRemote:^(BOOL isSuccess, NSInteger all) {
            if (isSuccess) {
                if (all == 1) {
                    !self.loginHandler?:self.loginHandler(self.userInfo, nil);
                    [self->_multiDelegate onLogin:nil];
                    self.loginHandler = nil;
                }
            } else {
                if (all == 1) {
                    // 走到这一步，是最后的异常处理
                    // 为什么是最后的异常处理？
                    // 登录成功->握手成功->同步数据失败->重新同步N次还失败->才会走到这里，至此整个登录行为失败
                    // 执行退出 为什么不调用logout方法？ 因为我们不需要退出成功后出发onLogout：
                    [TIOHTTPSManager tio_POST:@"/logout" parameters:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                        
                        // 关闭长链接
                        [TIOChat.shareSDK finish];
                        [self clearLoginDB:^(BOOL isSuccess) {
                            
                        }];
                        TIOTokenStorage.shareStorage.loginStatus = 2;
                        [self clearUserInforCache];
                        [self clearCookisToken];
                        
                        // 通知登录失败
                        NSError *error = [NSError errorWithDomain:TIOChatErrorDomain code:1000 userInfo:@{NSLocalizedDescriptionKey: @"登录失败，请重新登录"}];
                        self.loginHandler(nil, error);
                        [self->_multiDelegate onLogin:error];
                        self.loginHandler = nil;
                    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    }];
                }
            }
        } retryCount:3];
    }
}

- (void)changeDB:(NSString *)db
{
    bg_setSqliteName(db);
}

- (void)clearCookisToken
{
//    NSArray<NSHTTPCookie *> *cookies = [NSHTTPCookieStorage.sharedHTTPCookieStorage cookiesForURL:[NSURL URLWithString:TIOChat.shareSDK.config.httpsAddress]];
//    for (NSHTTPCookie *cookie in cookies) {
//        [NSHTTPCookieStorage.sharedHTTPCookieStorage deleteCookie:cookie];
//    }
    
    TIOLog(@"当前的cookie = %@", TIOTokenStorage.shareStorage.cookie);
}

- (void)saveCookie
{
    TIOTokenStorage.shareStorage.loginStatus = 1; // 标记登录
    
//    NSArray<NSHTTPCookie *> *cookies = [NSHTTPCookieStorage.sharedHTTPCookieStorage cookiesForURL:[NSURL URLWithString:TIOChat.shareSDK.config.httpsAddress]];
//
//    for (NSHTTPCookie *cookie in cookies) {
//        TIOTokenStorage.shareStorage.cookie = [NSString stringWithFormat:@"%@=%@",cookie.name,cookie.value];
//        TIOTokenStorage.shareStorage.token = cookie.value;
//    }
}


@end






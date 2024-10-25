//
//  ThirdLogin.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/12/28.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "ThirdLogin.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/QQApiInterfaceObject.h>
#import "WXApi.h"
#import "WXApiObject.h"

@interface ThirdLogin () <TencentSessionDelegate, WXApiDelegate, QQApiInterfaceDelegate>
@property (strong,  nonatomic) TencentOAuth *qqOAuth;
@property (copy,    nonatomic) void (^loginCompletionBlock)(ThirdResponse * _Nullable result, NSError * _Nullable error);
@property (weak,    nonatomic) UIViewController *currentVC;

@property (strong,  nonatomic) NSMutableDictionary<NSNumber *, ThirdConfig *> *configCache;
@property (strong,  nonatomic) ThirdConfig *config;
@property (assign,  nonatomic) ThirdPlatform platform;

@end

@implementation ThirdLogin

+ (instancetype)shareInstance
{
    static ThirdLogin *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });

    return _sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.configCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (ThirdConfig *)config
{
    return self.configCache[@(self.platform)];
}

- (BOOL)handleOpenURL:(NSURL *)url
{
    if (self.platform == ThirdPlatformQQ) {
        [QQApiInterface handleOpenURL:url delegate:self];
        return [TencentOAuth HandleOpenURL:url];
    }
    
    if (self.platform == ThirdPlatformWX) {
        return [WXApi handleOpenURL:url delegate:self];
    }
    return YES;
}

- (BOOL)handleOpenUniversalLink:(NSUserActivity *)userActivity
{
    if (self.platform == ThirdPlatformQQ) {
        if([userActivity.activityType isEqualToString:NSUserActivityTypeBrowsingWeb]) {
            NSURL *url = userActivity.webpageURL;
            if(url && [TencentOAuth CanHandleUniversalLink:url]) {
                [QQApiInterface handleOpenUniversallink:url delegate:self];
                return [TencentOAuth HandleUniversalLink:url];
            }
        }
        return YES;
    }
    return [WXApi handleOpenUniversalLink:userActivity delegate:self];
}

- (void)setConfig:(ThirdConfig *)config forPaltform:(ThirdPlatform)platform
{
    self.configCache[@(platform)] = config;
}

- (void)loginWithPlatform:(ThirdPlatform)platform currentVC:(UIViewController *)currentVC completion:(void (^)(ThirdResponse * _Nullable, NSError * _Nullable))completion
{
    self.loginCompletionBlock = completion;
    self.platform = platform;
    
    if (platform == ThirdPlatformQQ) {
        if (![self canOpenQQ]) {
            completion(nil, [NSError errorWithDomain:@"" code:ThirdLoginNoInstallQQ userInfo:@{NSLocalizedDescriptionKey:@"手机没有安装QQ客户端"}]);
            return;
        }
        
        self.qqOAuth = [TencentOAuth.alloc initWithAppId:self.config.appId andUniversalLink:self.config.UniversalLink andDelegate:self];
        [self.qqOAuth authorize:@[kOPEN_PERMISSION_GET_INFO, kOPEN_PERMISSION_GET_SIMPLE_USER_INFO]];
    } else if (platform == ThirdPlatformWX) {
        if (![WXApi isWXAppInstalled]) {
            completion(nil, [NSError errorWithDomain:@"" code:ThirdLoginNoInstallWX userInfo:@{NSLocalizedDescriptionKey:@"手机没有安装微信客户端"}]);
            return;
        }
        
        // 先注册
        [WXApi registerApp:self.config.appId universalLink:self.config.UniversalLink];
        // 调用登录
        SendAuthReq *req = [SendAuthReq.alloc init];
        req.scope = @"snsapi_userinfo";
        req.state = @"123";
        [WXApi sendAuthReq:req viewController:currentVC delegate:self completion:nil];
    }
}

#pragma mark - QQ

/// 已经登录
- (void)tencentDidLogin {
    [self.qqOAuth RequestUnionId];
}

/// 登录失败
- (void)tencentDidNotLogin:(BOOL)cancelled {
    if (self.loginCompletionBlock) {
        if (cancelled) {
            NSError *error = [NSError errorWithDomain:@"" code:ThirdLoginCancel userInfo:@{NSLocalizedDescriptionKey:@"QQ登录失败：用户取消授权登录"}];
            self.loginCompletionBlock(nil, error);
        } else {
            NSError *error = [NSError errorWithDomain:@"" code:ThirdLoginFail userInfo:@{NSLocalizedDescriptionKey:@"QQ登录失败"}];
            self.loginCompletionBlock(nil, error);
        }
    }
}

/// 没有网络
- (void)tencentDidNotNetWork {
    if (self.loginCompletionBlock) {
        NSError *error = [NSError errorWithDomain:@"" code:ThirdLoginNoNet userInfo:@{NSLocalizedDescriptionKey:@"QQ登录没有网络"}];
        self.loginCompletionBlock(nil, error);
    }
}


/**
 * 退出登录的回调
 */
- (void)tencentDidLogout
{
    
}

/// 获取的用户信息响应
- (void)getUserInfoResponse:(APIResponse *)response
{
    /*
     {
         city = "";
         constellation = "";
         figureurl = "http://qzapp.qlogo.cn/qzapp/1111104478/8DAED6A615C88E6B9F0D921F49895362/30";
         "figureurl_1" = "http://qzapp.qlogo.cn/qzapp/1111104478/8DAED6A615C88E6B9F0D921F49895362/50";
         "figureurl_2" = "http://qzapp.qlogo.cn/qzapp/1111104478/8DAED6A615C88E6B9F0D921F49895362/100";
         "figureurl_qq" = "http://thirdqq.qlogo.cn/g?b=oidb&k=mXrDZ1mT1hhPKeUvm5ib2GQ&s=100";
         "figureurl_qq_1" = "http://thirdqq.qlogo.cn/g?b=oidb&k=mXrDZ1mT1hhPKeUvm5ib2GQ&s=40";
         "figureurl_qq_2" = "http://thirdqq.qlogo.cn/g?b=oidb&k=mXrDZ1mT1hhPKeUvm5ib2GQ&s=100";
         "figureurl_type" = 0;
         gender = "\U7537";
         "gender_type" = 2;
         "is_lost" = 0;
         "is_yellow_vip" = 0;
         "is_yellow_year_vip" = 0;
         level = 0;
         msg = "";
         nickname = "\U4e00\U591c\U5b64\U57ce";
         province = "";
         ret = 0;
         vip = 0;
         year = 0;
         "yellow_vip_level" = 0;
     }
     */
    NSLog(@"%s",__FUNCTION__);
    if (self.loginCompletionBlock) {
        ThirdResponse *resp = [ThirdResponse.alloc init];
        resp.openid  = self.qqOAuth.openId;
        resp.unionId = self.qqOAuth.unionid;
        resp.accessToken = self.qqOAuth.accessToken;
        resp.platformType = self.platform;
        resp.name = response.jsonResponse[@"nickname"];
        resp.icon = response.jsonResponse[@"figureurl_qq"];
        resp.gender = response.jsonResponse[@"gender"];
        resp.originalResponse = response.jsonResponse;
        resp.extDic = response.userData;
        self.loginCompletionBlock(resp, nil);
    }
}

- (void)didGetUnionID
{
    NSLog(@"%s",__FUNCTION__);
    [self.qqOAuth getUserInfo];
}

- (void)responseDidReceived:(APIResponse*)response forMessage:(NSString *)message;
{
//    NSLog(@"%s",__FUNCTION__);
//    NSLog(@"response => %@",response);
//    NSLog(@"message => %@",message);
}

/// 关闭页面
- (void)tencentOAuth:(TencentOAuth *)tencentOAuth doCloseViewController:(UIViewController *)viewController
{
    NSLog(@"%s",__FUNCTION__);
}

#pragma mark - WX

- (void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *authResp = (SendAuthResp *)resp;
        if (authResp.errCode == 0) {
            // 登录成功, 用code 获取token、openid
            [self getAccessTokenWithCode:authResp.code];
        } else if (authResp.errCode == WXErrCodeUserCancel) {
            // 用户取消
            NSError *error = [NSError errorWithDomain:@"" code:ThirdLoginCancel userInfo:@{NSLocalizedDescriptionKey:@"微信登录失败：用户取消授权登录"}];
            self.loginCompletionBlock(nil, error);
        } else if (authResp.errCode == WXErrCodeAuthDeny) {
            // 授权失败
            NSError *error = [NSError errorWithDomain:@"" code:ThirdLoginFail userInfo:@{NSLocalizedDescriptionKey:@"微信登录失败：授权失败"}];
            self.loginCompletionBlock(nil, error);
        } else {
            // 其他错误
            NSError *error = [NSError errorWithDomain:@"" code:ThirdLoginOther userInfo:@{NSLocalizedDescriptionKey:@"微信登录失败：其他原因"}];
            self.loginCompletionBlock(nil, error);
        }
    }
}

/// 根据授权code获取token、
/// @param code 授权响应给的code
- (void)getAccessTokenWithCode:(NSString *)code {
    NSString *urlString =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/oauth2/access_token?appid=%@&secret=%@&code=%@&grant_type=authorization_code",self.config.appId,self.config.appSecertKey,code];
    NSURL *url = [NSURL URLWithString:urlString];
    
    /*
     {
       "access_token": "ACCESS_TOKEN",
       "expires_in": 7200,
       "refresh_token": "REFRESH_TOKEN",
       "openid": "OPENID",
       "scope": "SCOPE",
       "unionid": "o6_bmasdasdsad6_2sgVt7hMZOPfL"
     }
     */
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *dataStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data) {
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                if ([dict objectForKey:@"errcode"]) {
                    self.loginCompletionBlock(nil, [NSError errorWithDomain:@"" code:ThirdLoginOther userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"code = %@, msg = %@",[dict objectForKey:@"errcode"],[dict objectForKey:@"errmsg"]]}]);
                }else {
//                    NSLog(@"==微信openid======%@=====",[dict objectForKey:@"openid"]);
                    [self getUserInfoWithAccessToken:[dict objectForKey:@"access_token"] andOpenId:[dict objectForKey:@"openid"]];
                }
            }
        });
    });
}

/// 根据token openid 获取微信的用户信息
- (void)getUserInfoWithAccessToken:(NSString *)accessToken andOpenId:(NSString *)openId
{
    NSString *urlString =[NSString stringWithFormat:@"https://api.weixin.qq.com/sns/userinfo?access_token=%@&openid=%@",accessToken,openId];
//    NSLog(@"%@=======",urlString);
    
    /*
          city = ****;
          country = CN;
          headimgurl = "http://wx.qlogo.cn/mmopen/q9UTH59ty0K1PRvIQkyydYMia4xN3gib2m2FGh0tiaMZrPS9t4yPJFKedOt5gDFUvM6GusdNGWOJVEqGcSsZjdQGKYm9gr60hibd/0";
          language = "zh_CN";
          nickname = “****";
          openid = oo*********;
          privilege =     (
          );
          province = *****;
          sex = 1;
          unionid = “o7VbZjg***JrExs";
          */
    /*
            错误代码
            errcode = 42001;
            errmsg = "access_token expired";
            */
    
    NSURL *url = [NSURL URLWithString:urlString];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *dataStr = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
        NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (data)
                {
                 NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                 if ([dict objectForKey:@"errcode"])               {
 //AccessToken失效
                     self.loginCompletionBlock(nil, [NSError errorWithDomain:@"" code:ThirdLoginOther userInfo:@{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"code = %@, msg = %@",[dict objectForKey:@"errcode"],[dict objectForKey:@"errmsg"]]}]);
                 }else
                 {
                     ThirdResponse *resp = [ThirdResponse.alloc init];
                     resp.openid  = openId;
                     resp.unionId = dict[@"unionid"];
                     resp.accessToken = accessToken;
                     resp.platformType = self.platform;
                     resp.name = dict[@"nickname"];
                     resp.icon = dict[@"headimgurl"];
                     resp.gender = [dict[@"sex"] integerValue] == 1?@"男":@"女";
                     resp.originalResponse = dict;
                     self.loginCompletionBlock(resp, nil);
                 }
             }
         });
     });
}

#pragma mark - share

- (void)shareText:(NSString *)text toPlatform:(ThirdPlatform)platform shareType:(ThirdShareType)shareType completion:(void (^)(id _Nonnull, NSError * _Nullable))completion
{
    
}

- (void)shareImage:(UIImage *)image toPlatform:(ThirdPlatform)platform shareType:(ThirdShareType)shareType completion:(void (^)(id _Nonnull, NSError * _Nullable))completion
{
    self.platform = platform;
    
    if (platform == ThirdPlatformQQ) {
        if (shareType == ThirdShareTypeQQSession) {
//            NSData *imgData = [NSData dataWithContentsOfFile:path];
//            QQApiImageObject *imgObj = [QQApiImageObject objectWithData:imgData
//                                                       previewImageData:imgData
//                                                       title:@"title"
//                                                       description :@"description"];
//            SendMessageToQQReq *req = [SendMessageToQQReq reqWithContent:imgObj];
//            //将内容分享到
//            qqQQApiSendResultCode sent = [QQApiInterface sendReq:req];
        }
    } else if (platform == ThirdPlatformWX) {
        
    } else {
        
    }
}

- (void)shareWebPageURL:(NSString *)pageUrl title:(NSString *)title description:(NSString *)description thumbImage:(id)thumbImage toPlatform:(ThirdPlatform)platform shareType:(ThirdShareType)shareType completion:(void (^)(id _Nonnull, NSError * _Nullable))completion
{
    
}

- (BOOL)canOpenQQ
{
    return [TencentOAuth iphoneQQInstalled];
}

- (BOOL)canOpenWX
{
    return [WXApi isWXAppInstalled];
}

@end

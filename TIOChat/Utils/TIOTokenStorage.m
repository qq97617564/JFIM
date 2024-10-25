//
//  TIOTokenStorage.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/6/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOTokenStorage.h"
#import "TIOChatHeader.h"
#import "TIOConfig.h"
#import "TIOMacros.h"

    
@interface TIOTokenStorage ()
/// 登录后的token
@property (copy,    nonatomic) NSString *loginToken;
/// 临时的token，主要在check时，记录上一次的token
@property (copy,    nonatomic) NSString *tempToken;
@end

@implementation TIOTokenStorage

@synthesize cookie = _cookie;
@synthesize loginStatus = _loginStatus;

+ (instancetype)shareStorage
{
    static dispatch_once_t onceToken;
    static TIOTokenStorage *instance;
    dispatch_once(&onceToken, ^{
        instance = [[self.class alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.oldToken = self.token;
        
        if ([NSUserDefaults.standardUserDefaults objectForKey:@"tio_cookiename"]) {
            self.cookieName = [NSUserDefaults.standardUserDefaults objectForKey:@"tio_cookiename"];
        } else {
            self.cookieName = @"tio_session";
        }
    }
    return self;
}

/// 主要负责处理非登录时的token更新, 登录退出时的token更新，已经分散到其他方法中
- (void)checkToken:(NSString *)urlString
{
    NSArray<NSHTTPCookie *> *cookies = [NSHTTPCookieStorage.sharedHTTPCookieStorage cookiesForURL:[NSURL URLWithString:TIOChat.shareSDK.config.httpsAddress]]; // 得在当前域名环境下查找cookies
    
    NSDictionary *dict = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    
    TIOLog(@"=====> [cookie] [checkToken][NSHTTPCookieStorage] cookies = %@",dict);
    
    for (NSHTTPCookie *cookie in cookies) {
        
//        if ([cookie.name isEqualToString:self.cookieName]) {
            // 是要处理的cookie

            if (!self.loginToken) {
                // 非登录时 有新的token，就替换
                if (![self.oldToken isEqualToString:cookie.value]) {
                    TIOLog(@"=====> [cookie][Important] => token发生变更");
                }
                TIOLog(@"=====> [cookie] 老 cookie：%@",self.oldToken);
                TIOLog(@"=====> [cookie] 新 cookie：%@",cookie.value);
                [NSUserDefaults.standardUserDefaults setObject:cookie.value forKey:@"tio_cookie"];
                [NSUserDefaults.standardUserDefaults synchronize];
                self.oldToken = cookie.value;
            } else {
                // 防止如果有新token已经生成，下一步未登录token通过非登录接口返回，将新token复原回去
                if (![cookie.value isEqualToString:self.loginToken]) {
                    
                    if (urlString) {
                        if ([urlString containsString:@"/user/thirdbindphone"]) {
                            // 特定API下，
                            if (![self.oldToken isEqualToString:cookie.value]) {
                                TIOLog(@"=====> [cookie][Important] => token发生变更");
                                TIOLog(@"=====> [cookie] 老 cookie：%@",self.oldToken);
                                TIOLog(@"=====> [cookie] 新 cookie：%@",cookie.value);
                                [NSUserDefaults.standardUserDefaults setObject:cookie.value forKey:@"tio_cookie"];
                                [NSUserDefaults.standardUserDefaults setObject:cookie.value forKey:@"tio_login_cookie"];
                                [NSUserDefaults.standardUserDefaults synchronize];
                                
                                /**
                                 * 进行：updateToken 在 updateToken内干两件事
                                 * 1、重新获取同步数据
                                 * 2、更新长链接的token
                                 */
                                
                                // 1、重新获取同步数据
                                [NSNotificationCenter.defaultCenter postNotificationName:@"TIOTokenUpdated" object:@"11"];
                                
                                // 需要老token更新长连接的token，所以最后再更新oldToken
                                self.oldToken = cookie.value;
                                
                                return;
                            }
                        }
                    }
                    
                    // cookie是老token
                    NSHTTPCookie *tpijoCookie = [NSHTTPCookie cookieWithProperties:@{
                                                                                     NSHTTPCookieDomain:cookie.domain,
                                                                                     NSHTTPCookiePath: cookie.path?:@"/",
                                                                                     NSHTTPCookieName: cookie.name,
                                                                                     NSHTTPCookieValue: self.loginToken,
                                                                                     NSHTTPCookieVersion: @(cookie.version),
                                                                                     NSHTTPCookieExpires: cookie.expiresDate,
                                                                                     NSHTTPCookieSecure:@(cookie.isSecure),
                                                                                     }];
                    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:tpijoCookie];
                    [NSHTTPCookieStorage.sharedHTTPCookieStorage deleteCookie:cookie];
                    [NSHTTPCookieStorage.sharedHTTPCookieStorage setCookie:tpijoCookie];
                    
                    TIOLog(@"=====> [cookie] 老cookie想覆盖新cookie图谋未果\n 老cookie：%@\n登录状态的cookie：%@",cookie.value, self.loginToken);
                }
            }

//        }
        
//        if ([cookie.name isEqualToString:self.cookieName]) {
//
//            if (![cookie.value isEqualToString:self.token]) {
//                // token 更新通知，原先存在一个token
//
//                BOOL flag = self.token?YES:NO;
//
//                self.oldToken = self.token;
//                self.token = cookie.value;
//                // 需要手动更新，短链接请求时发送的cookie，因为是懒加载，所以需要手动跟新
//                self.cookie = [NSString stringWithFormat:@"%@=%@",self.cookieName,cookie.value];
//
//                [NSUserDefaults.standardUserDefaults setObject:cookie.value forKey:@"tio_cookie"];
//
//                if (flag) {
//                    // 发出通知
//                    [NSNotificationCenter.defaultCenter postNotificationName:@"TIOTokenUpdated" object:@"11"];
//                }
//                NSLog(@"[cookie][Important] => token发生变更");
//            }
//        }
    }
}

- (NSString *)cookie
{
    if (self.loginToken) {
        TIOLog(@"=====> [cookie] 获取loginToken = %@\ncookie = %@",self.loginToken,[NSString stringWithFormat:@"%@=%@",self.cookieName,self.loginToken]);
        return [NSString stringWithFormat:@"%@=%@",self.cookieName,self.loginToken];
    }
    TIOLog(@"=====> [cookie] 获取普通 Token = %@\ncookie = %@",[NSUserDefaults.standardUserDefaults stringForKey:@"tio_cookie"],[NSUserDefaults.standardUserDefaults stringForKey:@"tio_cookie"]);
    return [NSString stringWithFormat:@"%@=%@",self.cookieName,[NSUserDefaults.standardUserDefaults stringForKey:@"tio_cookie"]];
}

- (void)clear
{
    _token = nil;
    _cookie = nil;
}

- (void)setCookieName:(NSString *)cookieName
{
    _cookieName = cookieName;
    [NSUserDefaults.standardUserDefaults setObject:cookieName?:@"tio_session" forKey:@"tio_cookiename"];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (void)setLoginStatus:(NSInteger)loginStatus
{
    _loginStatus = loginStatus;
    
    if (loginStatus == 1) {
        // 登录 记录登录后的token
        NSArray<NSHTTPCookie *> *cookies = [NSHTTPCookieStorage.sharedHTTPCookieStorage cookiesForURL:[NSURL URLWithString:TIOChat.shareSDK.config.httpsAddress]]; // 得在当前域名环境下查找cookies
        
        for (NSHTTPCookie *cookie in cookies) {
            [NSUserDefaults.standardUserDefaults setObject:cookie.value forKey:@"tio_login_cookie"];
            [NSUserDefaults.standardUserDefaults setObject:cookie.value forKey:@"tio_cookie"];
            [NSUserDefaults.standardUserDefaults synchronize];
            self.token = cookie.value;
            TIOLog(@"=====> [cookie] 登录token");
            break;
        }
        
    } else if (loginStatus == 2) {
        // 退出登录 清空登录的token
        [NSUserDefaults.standardUserDefaults removeObjectForKey:@"tio_login_cookie"];
        [NSUserDefaults.standardUserDefaults synchronize];
        TIOLog(@"=====> [cookie] 退出登录 清空登录的token");
    } else {
        TIOLog(@"=====> [cookie] 非法更改cookie的登录状态");
    }
    
    self.oldToken = self.token;
}

- (NSInteger)loginStatus
{
    NSString *value = [NSUserDefaults.standardUserDefaults objectForKey:@"tio_login_cookie"];
    return value.length?1:2;
}

- (NSString *)loginToken
{
    return [NSUserDefaults.standardUserDefaults objectForKey:@"tio_login_cookie"];
}

- (NSString *)token
{
    NSString *logintoken = self.loginToken;
    if (logintoken.length) {
        TIOLog(@"=====> [cookie] getToken loginToken");
        return logintoken;
    }
    TIOLog(@"=====> [cookie] getToken tio_cookie");
    return [NSUserDefaults.standardUserDefaults stringForKey:@"tio_cookie"];
}

@end

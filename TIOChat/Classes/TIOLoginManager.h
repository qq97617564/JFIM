//
//  TIOLoginManager.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TIODefines.h"
#import "TIOUser.h"

NS_ASSUME_NONNULL_BEGIN

@class TIOUser;
@class TIOLoginUser;
@class TIOSocketPackage;

typedef void(^TIOLoginHandler)(NSError * __nullable error);
typedef void(^TIOLoginHandler2)(TIOLoginUser * __nullable userData, NSError * __nullable error);
typedef void(^TIORegisterHandler)(NSError * __nullable error, NSString * __nullable msg);

typedef void(^TIOFindPwdHandler)(NSError * __nullable error, NSString * __nullable msg);

typedef void(^TIOMyUserBlock)(TIOLoginUser * __nullable user,NSError * __nullable error);

typedef void(^TIOOperateHandler)(NSInteger result, NSError * __nullable error);


/**
--------------------------------------------------------------
`TIOKickReason` 被挤掉的原因
--------------------------------------------------------------
*/
@interface TIOKickReason : NSObject
/// 错误码
@property (assign,  nonatomic) NSInteger    code;
/// 错误描述信息 默认使用服务端文案
@property (assign,    nonatomic) id     msg;
@end


@interface TIOThirdLoginOption : NSObject
// 三方登录第一步:必传参数
@property (assign,  nonatomic) NSInteger type;
@property (copy,    nonatomic) NSString *openid;
// 三方登录第二步:除上述参数外，还需设置以下参数
@property (copy,    nonatomic) NSString *unionid;
@property (copy,    nonatomic) NSString *uuid;
@property (copy,    nonatomic) NSString *nick;
@property (copy,    nonatomic) NSString *avatar;
@property (assign,  nonatomic) NSInteger sex;

// 如果是微信登录，需设置以下参数
@property (copy,    nonatomic) NSString *country;
@property (copy,    nonatomic) NSString *province;
@property (copy,    nonatomic) NSString *city;

// 如果是QQ登录，需设置以下参数
@property (assign,  nonatomic) NSInteger is_yellow_vip; // 0: 不是；1: 是
@property (assign,  nonatomic) NSInteger yellow_vip_level;
@end

/**
--------------------------------------------------------------
`TIOLoginUser`登录用户信息
--------------------------------------------------------------
*/
@interface TIOLoginUser : TIOUser <NSCoding>

/// 消息提醒开关 1：开启  2:不开启
@property (assign,  nonatomic) NSInteger msgremindflag;

@property (copy,    nonatomic) NSString *phone;
@property (copy,    nonatomic) NSString *email;

/// 性别
@property (assign,  nonatomic) TIOUserSex sex;

/// 1：需要验证 2:不需要验证
@property (assign,  nonatomic) NSInteger fdvalidtype;

/// 允许被搜索的开关 1：可以 2:不可以
@property (assign,  nonatomic) NSInteger searchflag;

/// 开户状态：1：已开户；2：未开户
@property (assign,  nonatomic) NSInteger openflag;
/// 钱包id
@property (copy,  nonatomic) NSString *walletid;
/// 开户信息id
@property (assign,  nonatomic) NSInteger openid;

/// 手机绑定标志 1:已经绑定手机号 2:未绑定手机号
@property (assign,  nonatomic) NSInteger phonebindflag;
/// 邮箱绑定标志 1:已经绑定邮箱 2:未绑定邮箱
@property (assign,  nonatomic) NSInteger emailbindflag;
/// 是否是三方登录 1:来自三方登录
@property (assign,  nonatomic) NSInteger thirdbindflag;
/// 三方登录的用户信息：昵称、头像、openid、unionid、性别
@property (strong,  nonatomic) NSDictionary *userThird;
@property (copy,    nonatomic) NSString *ip;
//邀请码
@property (copy,  nonatomic) NSString *invitecode;

- (NSDictionary *)jsonObject;

@end

/**
--------------------------------------------------------------
`TIOLoginDelegate`登录模块的回调
--------------------------------------------------------------
*/

@protocol TIOLoginDelegate <NSObject>

@optional

/// 登录状态
- (void)onLogin:(NSError* __nullable)error;

- (void)onLogout;

/// 被踢\挤掉通知
/// @param resaon 原因
- (void)onKick:(TIOKickReason *)resaon;

/// 当前账户信息已经更新
/// @param user 最新的账户信息
- (void)didUpdateCurrentUserInfo:(TIOLoginUser *)user;

/// 三方账号已经绑定到原有手机号
/// 如果业务中有绑定手机号的需求，建议实现在此回调中实现业务需求
/// @param mobilePhone 原手机号
- (void)onThirdAccountDidBindToOldMobilephone:(NSString *)mobilePhone;

@end

/**
 --------------------------------------------------------------
 `TIOLoginManager`登录模块
 --------------------------------------------------------------
 */
@interface TIOLoginManager : NSObject

#pragma mark - 新增API：三方登录

/// 邀请码配置
/// - Parameter completion: 回调
- (void)tLoginInvitecodeCompletion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion;
/// 第一步：获取uuid
- (void)tLogin1:(TIOThirdLoginOption *)option completion:(void(^)(NSDictionary * _Nullable responObject, NSError * _Nullable error))completion;

/// 第二步: 登录
- (void)tLogin2:(TIOThirdLoginOption *)option completion:(TIOLoginHandler2)completion;



/// 登录
/// @param account 账号
/// @param password 密码
/// @param completion 登录结果的回调
- (void)login:(NSString *)account password:(NSString *)password completion:(TIOLoginHandler2)completion __attribute__((deprecated("已废弃，也能使用，但更建议使用下面的- (void)login:(NSString *)account password:(NSString* _Nullable)password authcode:(NSString * _Nullable)authcode completion:(TIOLoginHandler)completion")));

/// 登录 带验证码的登录
/// @param account 邮箱登录时填写邮箱，手机登录时填写手机号
/// @param password 邮箱、手机密码登录时填写，验证码登录不用传
/// @param authcode 验证码登录时填写短信验证码
/// @param completion 登录结果的回调
- (void)login:(NSString *)account password:(NSString* _Nullable)password authcode:(NSString * _Nullable)authcode completion:(TIOLoginHandler2)completion;


/// 退出 - 退出操作务必要执行该操作，方法内会进行缓存的清理
/// @param completion 方法的执行回调，非网络的回调
- (void)logout:(nullable TIOLoginHandler)completion;

/// 注册
/// @param loginname 邮箱
/// @param password 密码
/// @param nick 昵称
- (void)registerLoginname:(NSString *)loginname password:(NSString *)password nick:(NSString *)nick completion:(TIORegisterHandler)completion __attribute__((deprecated("已废弃，也能使用，但更建议使用下面的- (void)registerLoginname:(NSString *)loginname password:(NSString *)password nick:(NSString *)nick code:(NSString *)code completion:(TIORegisterHandler)completion")));

/// 注册
/// @param loginname 手机号
/// @param password 密码
/// @param nick 昵称
/// @param code 验证码
- (void)registerLoginname:(NSString *)loginname password:(NSString *)password nick:(NSString *)nick code:(NSString *)code completion:(TIORegisterHandler)completion;

/// 获取短信验证码前的校验 - fetchSMSWithType前一步调用
/// @param mobile 接收短信的手机号
/// @param type type 1：绑定手机号；2：注册；3：登录；4:修改密码;5:修改手机-老手机号验证;6:找回密码；7：绑定新手机;8:三方绑定手机
- (void)checkMobile:(NSString *)mobile type:(NSInteger)type handler:(void(^)(NSInteger result, NSError * _Nullable error))handler;
/// 更改地区显示
/// @param handler 回调
-(void)updateShowAreaHandler:(nonnull void (^)(NSInteger, NSError * _Nullable))handler;
/// 获取短信验证码
/// @param type 1：绑定手机号；2：注册；3：登录；4:修改密码;5:修改手机-老手机号验证;6:找回密码；7：绑定新手机;8:三方绑定手机
/// @param mobile 手机号
/// @param token token
- (void)fetchSMSWithType:(NSInteger)type mobile:(NSString *)mobile token:(NSString *)token handler:(TIOLoginHandler)handler;

/// 校验验证码
/// @param code 验证码
/// @param type 1：绑定手机号；2：注册；3：登录；4:修改密码;5:修改手机-老手机号验证;6:找回密码；7：绑定新手机;8:三方绑定手机
/// @param mobile 手机号
- (void)checkSMSCode:(NSString *)code type:(NSInteger)type mobile:(NSString *)mobile handler:(TIOLoginHandler)handler;


/// 当前登录用户的账户名
@property (copy,    readonly,   nonatomic) NSString *currentAccount;


/// 当前是否在登录
@property (assign,   readonly,  nonatomic) BOOL isLogined;


/// 从本地读取自己的用户信息
- (TIOLoginUser *)userInfo;
/// 从服务端获取并更新本地登录的用户信息
- (void)updateUserInfo:(TIOMyUserBlock)completion;

/// 上传头像
/// @param image 新的头像
- (void)updateAvatar:(UIImage *)image completion:(TIOLoginHandler)completion;

- (void)updateNick:(NSString *)nick completion:(TIOLoginHandler)completion;

- (void)updateSex:(TIOUserSex)sex completion:(TIOLoginHandler)completion;

- (void)updateSign:(NSString *)sign  completion:(TIOLoginHandler)completion;

/// 废弃
/// @param phone 新手机号
- (void)updatePhone:(NSString *)phone completion:(TIOLoginHandler)completion;

/// 更改好友申请的验证权限
/// @param needVerify YES：需要验证审核  NO：直接添加自己
- (void)updatePermissionForVerifyingApply:(BOOL)needVerify
                               completion:(TIOLoginHandler)completion;

/// 更改被别人搜索的权限
/// @param allowSearched YES：允许被搜索  NO：不允许被搜索
- (void)updatePermissionForSearchedByOther:(BOOL)allowSearched
                                completion:(TIOLoginHandler)completion;

/// 更改消息提醒的权限
/// @param receiveRemind YES：接收消息提醒 NO：不接收消息提醒
- (void)updatePermissionForReceivingMsgRemind:(BOOL)receiveRemind
                                   completion:(TIOLoginHandler)completion;

/// 修改密码
/// @param newPassword 新的密码
/// @param oldPassword 老密码
/// @param needLogout 修改密码后是否自动退出登录
- (void)updatePassword:(NSString *)newPassword
           oldPassword:(NSString *)oldPassword
            needLogout:(BOOL)needLogout
            completion:(TIOLoginHandler)completion;


/// 找回密码
/// @param loginname t邮箱（调用API，邮箱会收到重置邮件，在邮件内点击更改）
- (void)findPasswordWithLoginname:(NSString *)loginname
                       completion:(TIOFindPwdHandler)completion __attribute__((deprecated("已废弃，请使用下面的- (void)findPasswordWithNewPassword:(NSString *)password code:(NSString *)code phone:(NSString *)phone email:(NSString * _Nullable)email")));

/// 找回密码前的操作
/// @param phone 手机号
/// @param code 验证码
- (void)beforeFindPasswordWithPhone:(NSString *)phone code:(NSString *)code completion:(void(^)(NSDictionary * __nullable result, NSError * __nullable error))completion;

/// 找回密码
/// @param password 密码
/// @param code 验证码
/// @param phone 手机
/// @param email 邮箱 （账号没有绑定邮箱，传空nil）
- (void)findPasswordWithNewPassword:(NSString *)password code:(NSString *)code phone:(NSString *)phone email:(NSString * _Nullable)email completion:(TIOLoginHandler)completion;;

/// 绑定手机号
/// @param phone 手机
/// @param code 验证码
/// @param email 要绑定到的邮箱
/// @param password 密码
/// @param option  1:注册时的邮箱绑定 2:三方登录后的绑定  3:邮箱登录后的绑定 
- (void)bindPhone:(NSString *)phone toEmail:(NSString *)email code:(NSString *)code password:(NSString *)password option:(NSInteger)option completion:(TIOLoginHandler)completion;

/// 更换已经绑定的手机号
/// @param phone 新手机号
/// @param code 新手机号的验证码
/// @param password 原密码
/// @param email 有就传，没有传@""
- (void)changeBoundPhone:(NSString *)phone code:(NSString *)code password:(NSString *)password email:(NSString *)email completion:(TIOOperateHandler)completion;

/// 添加聊天委托
/// @param delegate 聊天委托
- (void)addDelegate:(id<TIOLoginDelegate>)delegate;

/// 移除聊天委托
/// @param delegate 聊天委托
- (void)removeDelegate:(id<TIOLoginDelegate>)delegate;

- (void)handler:(TIOSocketPackage *)data;

@end

NS_ASSUME_NONNULL_END

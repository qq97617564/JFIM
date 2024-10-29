//
//  GFWalletManager.h
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/28.
//  Copyright © 2024 wgf. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// 钱包信息，针对红包
@interface GFWalletModel : NSObject
/*
 walletId = 6288884780000001168;
 setUpPasswrod = false;
 idCardRzStatus = SUCCESS;
 personRzStatus = INIT;
 nameDesc = 刘*;
 mobileDesc = 181***8553;
 operatorRzStatus = SUCCESS;
 balance = 0;
 idCardNoDesc = 3422***03X;
 */

@property (copy,    nonatomic) NSString *walletId;
@property (assign,  nonatomic) BOOL setUpPasswrod;
/// 实名认证状态
@property (copy,    nonatomic) NSString *idCardRzStatus;
/// 人像认证状态
@property (copy,    nonatomic) NSString *personRzStatus;
/// 姓名
@property (copy,    nonatomic) NSString *nameDesc;
/// 注册手机
@property (copy,    nonatomic) NSString *mobileDesc;
/// 运营商认证状态
@property (copy,    nonatomic) NSString *operatorRzStatus;
/// 身份证号码
@property (copy,    nonatomic) NSString *idCardNoDesc;
/// 钱包余额，精确到分
@property (copy,    nonatomic) NSString *balance;
@end

@interface orderModel : NSObject
@property (copy,    nonatomic) NSString *ID;
@property (assign,    nonatomic) NSInteger orderstatus;
@property (copy,    nonatomic) NSString *serialnumber;
@property (copy,    nonatomic) NSString *createtime;
@property (copy,    nonatomic) NSString *uid;
@property (copy,    nonatomic) NSString *amount;
@property (copy,    nonatomic) NSString *bizstr;
@property (assign,    nonatomic) NSInteger mode;
@property (assign,    nonatomic) NSInteger othercny;
@property (copy,    nonatomic) NSString *bizcreattime;
@property (copy,    nonatomic) NSString *remark;
@property (copy,    nonatomic) NSString *updatetime;
@property (assign,    nonatomic) NSInteger auditStatus;
@property (assign,    nonatomic) NSInteger coinflag;
@property (copy,    nonatomic) NSString *bizcompletetime;
@property (assign,    nonatomic) NSInteger status;
@end

/// <#Description#>
@interface GFWalletManager : NSObject

/// 钱包开户
/// @param uid 平台用户uid
/// @param name 用户真实姓名
/// @param phone 用户手机号
/// @param idcard 用户的身份证号
/// @param completion 响应
- (void)openAccount:(NSString *)uid
               name:(NSString *)name
              phone:(NSString *)phone
             idcard:(NSString *)idcard
               nick:(NSString * __nullable)nick
                mac:(NSString *__nullable)mac
         completion:(void(^)(NSDictionary * __nullable responseObject, NSError * __nullable error))completion;

/// 余额查询
/// @param completion 回调
-(void)accountGetBalanceWithCompletion:(void(^)(NSDictionary * __nullable responseObject, NSError * __nullable error))completion;
/// 订单查询
/// @param completion 回调
-(void)accountGetBalanceOrderWithCompletion:(void(^)(NSDictionary * __nullable responseObject, NSError * __nullable error))completion;
/// 卡详情
/// @param type 渠道
/// @param completion 回调
-(void)accountGetBnakDetailWithType:(NSString *)type completion:(void(^)(NSDictionary * __nullable responseObject, NSError * __nullable error))completion;
/// 充值
/// @param money 充值金额
/// @param completion 回调
-(void)accountRechargeMoney:(NSString *)money completion:(void(^)(NSDictionary * __nullable responseObject, NSError * __nullable error))completion;
/// 提现
/// @param money 提现金额
/// @param completion 回调
-(void)accountCashMoney:(NSString *)money completion:(void(^)(NSDictionary * __nullable responseObject, NSError * __nullable error))completion;
/// 绑定充值卡
/// @param typetype 渠道
/// @param cardno 号码
/// @param username 姓名
/// @param image 收款码
/// @param completion 回调
-(void)accountBindingWithType:(NSString *)type cardno:(NSString *)cardno username:(NSString *)username image:(NSString *)image completion:(void(^)(NSDictionary * __nullable responseObject, NSError * __nullable error))completion;
@end

NS_ASSUME_NONNULL_END

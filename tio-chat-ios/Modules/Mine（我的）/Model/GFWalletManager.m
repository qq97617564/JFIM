//
//  GFWalletManager.m
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/28.
//  Copyright © 2024 wgf. All rights reserved.
//

#import "GFWalletManager.h"
#import "TIOHTTPSManager.h"
#import "TIOMacros.h"
#import "NSObject+CBJSONSerialization.h"
#import "NSString+tio.h"
#import "TIOChat.h"
#import "NSString+MD5.h"

@implementation orderModel
+ (NSDictionary<NSString *,NSString *> *)JSONKeyPropertyMapping
{
    return @{
        @"ID" : @"id"
    };
}
@end

@implementation GFWalletManager

- (void)openAccount:(NSString *)uid name:(NSString *)name phone:(NSString *)phone idcard:(NSString *)idcard nick:(NSString * _Nullable)nick mac:(NSString * _Nullable)mac completion:(nonnull void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    NSError *error = nil;
    if (uid.length == 0) {
        error = [NSError errorWithDomain:TIOChatErrorDomain code:1000 userInfo:@{NSLocalizedDescriptionKey:@"开户的UID为空"}];
    } else if (name.length == 0) {
        error = [NSError errorWithDomain:TIOChatErrorDomain code:1000 userInfo:@{NSLocalizedDescriptionKey:@"开户姓名为空"}];
    } else if (phone.length == 0) {
        error = [NSError errorWithDomain:TIOChatErrorDomain code:1000 userInfo:@{NSLocalizedDescriptionKey:@"开户手机号为空"}];
    } else if (idcard.length == 0) {
        error = [NSError errorWithDomain:TIOChatErrorDomain code:1000 userInfo:@{NSLocalizedDescriptionKey:@"开户的身份证为空"}];
    }
    
    if (error) {
        completion(nil, error);
        return;
    }

    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"uid"] = uid;
    params[@"name"] = name;
    params[@"mobile"] = phone;
    params[@"cardno"] = idcard;
    if (nick) {
        params[@"nickName"] = nick;
    }
    if (mac) {
        params[@"mac"] = mac;
    }
    
    [TIOHTTPSManager tio_POST:@"/pay/open" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"开户结果：%@",responseObject[@"data"]);
        completion(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}
-(void)accountGetBalanceWithCompletion:(void(^)(NSDictionary * __nullable responseObject, NSError * __nullable error))completion{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [TIOHTTPSManager tio_POST:@"/wxuser/coin/balance" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"查询余额：%@",responseObject[@"data"]);
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}
-(void)getFindDataCompletion:(void(^)(NSDictionary * __nullable responseObject, NSError * __nullable error))completion{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [TIOHTTPSManager tio_POST:@"/find/list" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"发现：%@",responseObject[@"data"]);
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

-(void)accountGetBalanceOrderWithCompletion:(void(^)(NSDictionary * __nullable responseObject, NSError * __nullable error))completion{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [TIOHTTPSManager tio_POST:@"/wxuser/coin/order" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"查询订单：%@",responseObject[@"data"]);
        completion(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}
-(void)accountRechargeMoney:(NSString *)money completion:(void(^)(NSDictionary * __nullable responseObject, NSError * __nullable error))completion{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"money"] = money;
    params[@"payType"] = @"wechat";
    [TIOHTTPSManager tio_POST:@"/wxuser/coin/recharge" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"充值：%@",responseObject[@"data"]);
        completion(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}
-(void)accountCashMoney:(NSString *)money completion:(void(^)(NSDictionary * __nullable responseObject, NSError * __nullable error))completion{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"money"] = money;
    [TIOHTTPSManager tio_POST:@"/wxuser/coin/withdraw" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"提现：%@",responseObject[@"data"]);
        completion(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}
-(void)accountGetBnakDetailWithType:(NSString *)type completion:(void(^)(NSDictionary * __nullable responseObject, NSError * __nullable error))completion{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"type"] = type;
    [TIOHTTPSManager tio_POST:@"/wxuser/coin/bank/detail" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"获取卡详情：%@",responseObject[@"data"]);
        completion(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

-(void)accountBindingWithType:(NSString *)type cardno:(NSString *)cardno username:(NSString *)username image:(NSString *)image completion:(void(^)(NSDictionary * __nullable responseObject, NSError * __nullable error))completion{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"type"] = type;
    params[@"cardno"] = cardno;
    params[@"username"] = username;
    params[@"image"] = image;
    [TIOHTTPSManager tio_POST:@"/wxuser/coin/bank/save" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"提现：%@",responseObject[@"data"]);
        completion(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}
@end

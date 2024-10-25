//
//  TIOWalletManager.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/4.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOWalletManager.h"
#import "TIOHTTPSManager.h"
#import "TIOMacros.h"
#import "NSObject+CBJSONSerialization.h"
#import "NSString+tio.h"
#import "TIOChat.h"
#import "NSString+MD5.h"

@implementation TIOWallet

@end

@implementation TIORedPackage
- (NSString *)avatar
{
    return _avatar.tio_resourceURLString;
}
@end

@implementation TIOGrabRedPackage
- (NSString *)avatar
{
    return _avatar.tio_resourceURLString;
}
@end

@implementation TIOWalletWaterDeatil

@end

@implementation TIOWalletWithdraw

@end

@implementation TIOBankCard

+ (NSDictionary<NSString *,NSString *> *)JSONKeyPropertyMapping
{
    return @{
        @"card_id" : @"id"
    };
}

@end

@implementation TIOWalletManager

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

- (void)fetchSafeTokenWithUid:(NSString *)uid walletid:(NSString *)walletid completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    NSDictionary *params = @{
        @"uid" : uid?:@"",
        @"walletid" : walletid?:@"",
        @"bizType" : @"ACCESS_SAFETY"
    };
    
    [TIOHTTPSManager tio_POST:@"/pay/getClientToken" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)fetchBankCardListTokenWithUid:(NSString *)uid walletid:(NSString *)walletid completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    NSDictionary *params = @{
        @"uid" : uid?:@"",
        @"walletid" : walletid?:@"",
        @"bizType" : @"ACCESS_CARDlIST"
    };
    
    [TIOHTTPSManager tio_POST:@"/pay/getClientToken" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)fetchWalletDetailWithUid:(NSString *)uid walletid:(nonnull NSString *)walletid completion:(nonnull void (^)(TIOWallet * _Nullable, NSError * _Nullable))completion
{
    NSDictionary *params = @{
        @"uid" : uid?:@"",
        @"walletid" : walletid?:@""
    };
    
    [TIOHTTPSManager tio_POST:@"/pay/getWalletInfo" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"钱包信息 ：%@",responseObject[@"data"]);
        TIOWallet *data = [TIOWallet objectWithJSONObject:responseObject[@"data"]];
        completion(data, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)fetchWalletInformation:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    [TIOHTTPSManager tio_GET:@"/pay/getWalletInfo" parameters:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)checkOpenAccountStatus:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    [TIOHTTPSManager tio_POST:@"/pay/openflag" parameters:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"开户状态 ：%@",responseObject[@"data"]);
        completion(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)rechargeMoney:(NSString *)amount walletid:(NSString *)walletid uid:(NSString *)uid remark:(NSString *)remark completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"uid"] = uid?:@"";
    params[@"walletid"] = walletid?:@"";
    params[@"amount"] = amount?:@"";
    if (remark) {
        params[@"remark"] = remark;
    }
    
    NSDictionary *p = params;
    
    [TIOHTTPSManager tio_POST:@"/pay/recharge" parameters:p success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"充值预下单\n ：%@",responseObject[@"data"]);
        completion(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)beforeRechargeMoney:(NSInteger)amount agrno:(NSString *)agrno remark:(NSString *)remark completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"agrno"] = agrno?:@"";
    params[@"amount"] = amount?@(amount):@(0);
    if (remark) {
        params[@"remark"] = remark;
    }
    
    [TIOHTTPSManager tio_POST:@"/pay/recharge" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"充值预下单\n ：%@",responseObject[@"data"]);
        completion(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)confirmRecharging:(NSString *)merorderid rid:(NSString *)rid sms:(NSString *)sms completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    NSDictionary *params = @{
        @"smscode" : sms,
        @"merorderid" : merorderid,
        @"rid" : rid
    };
    
    [TIOHTTPSManager tio_POST:@"/pay/rechargeconfirm" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"确认支付\n ：%@",responseObject[@"data"]);
        completion(responseObject[@"data"],  nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)queryRechargeStatusWithRid:(NSString *)rid reqid:(NSString *)reqid completion:(void (^)(NSInteger, NSError * _Nullable))completion
{
    NSDictionary *params = @{
        @"reqid" : reqid?:@"",
        @"rid" : rid?:@""
    };
    
    [TIOHTTPSManager tio_POST:@"/pay/rechargeQuery" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"充值结果查询\n ：%@",responseObject[@"data"]);
        completion([responseObject[@"data"][@"status"] integerValue],  nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(0, error);
    }];
}

- (void)withdrawMoney:(NSString *)amount walletid:(NSString *)walletid uid:(NSString *)uid remark:(NSString *)remark completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"uid"] = uid?:@"";
    params[@"walletid"] = walletid?:@"";
    params[@"amount"] = amount?:@"";
    if (remark) {
        params[@"remark"] = remark;
    }
    
    NSDictionary *p = params;
    
    [TIOHTTPSManager tio_POST:@"/pay/withhold" parameters:p success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"提现预下单\n ：%@",responseObject[@"data"]);
        completion(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)withdrawMoney:(NSInteger)amount agrno:(NSString *)agrno paypwd:(NSString *)paypwd remark:(NSString *)remark completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    NSString *plainStr  = [NSString stringWithFormat:@"${%@}%@",TIOChat.shareSDK.loginManager.userInfo.phone,paypwd];
    NSString *pd5       = plainStr.MD5Digest;
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"agrno"] = agrno?:@"";
    params[@"amount"] = amount?@(amount):@(0);
    params[@"paypwd"] = pd5;
    if (remark) {
        params[@"remark"] = remark;
    }
    
    [TIOHTTPSManager tio_POST:@"/pay/withhold" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"提现\n ：%@",responseObject);
        completion(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)queryWithdrawStatusWithWid:(NSString *)wid reqid:(NSString *)reqid completion:(nonnull void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    NSDictionary *params = @{
        @"reqid" : reqid?:@"",
        @"wid" : wid?:@""
    };
    
    [TIOHTTPSManager tio_POST:@"/pay/withholdQuery" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"提现结果查询\n ：%@",responseObject[@"data"]);
        completion(responseObject[@"data"],  nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(0, error);
    }];
}

- (void)sendRedPackageToSession:(NSString *)sessionid packetType:(NSInteger)packetType amount:(NSInteger)amount singleAmount:(NSInteger)singleAmount packetCount:(NSInteger)packetCount uid:(NSString *)uid walletid:(NSString *)walletid remark:(NSString *)remark completion:(nonnull void (^)(TIORedPackage * _Nullable, NSError * _Nullable))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (uid) {
        params[@"uid"] = uid;
    }
    if (walletid) {
        params[@"walletid"] = walletid;
    }
    if (remark) {
        params[@"remark"] = remark;
    }
    params[@"amount"] = @(amount);
    params[@"chatlinkid"] = sessionid?:@"";
    params[@"packetType"] = @(packetType);
    params[@"singleAmount"] = @(singleAmount);
    params[@"packetCount"] = @(packetCount);
    
    NSDictionary *p = params;
    
    [TIOHTTPSManager tio_POST:@"/pay/sendRedpacket" parameters:p success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"发红包预下单\n ：%@",responseObject[@"data"]);
        TIORedPackage *data = [TIORedPackage objectWithJSONObject:responseObject[@"data"]];
        completion(data, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
    
}

- (void)checkRedStatusWithRedNumber:(NSString *)serialNumber completion:(nonnull void (^)(NSString * _Nullable, NSString * _Nullable, NSInteger, NSError * _Nullable))completion
{
    if (!serialNumber) {
        completion(nil, nil, 0, [NSError errorWithDomain:TIOChatErrorDomain code:5000 userInfo:@{NSLocalizedDescriptionKey:@"单号为空"}]);
        return;
    }
    
    NSDictionary *params = @{
        @"serialnumber" : serialNumber
    };
    [TIOHTTPSManager tio_POST:@"/pay/redStatus" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"检查红包状态\n ：%@",responseObject[@"data"]);
        NSString *grabstatus = responseObject[@"data"][@"grabstatus"];
        NSString *redstatus = responseObject[@"data"][@"redstatus"];
        NSInteger openflag = [responseObject[@"data"][@"openflag"] integerValue];
        completion(grabstatus, redstatus, openflag, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error => %@",error);
        completion(nil, nil, 0, error);
    }];
    
}

- (void)grabRedpackageWithRedNumber:(NSString *)serialNumber sessionId:(nonnull NSString *)sessionId uid:(NSString * _Nullable)uid walletid:(NSString * _Nullable)walletid completion:(nonnull void (^)(TIOGrabRedPackage * _Nullable, NSError * _Nullable))completion
{
    if (!serialNumber) {
        completion(nil, [NSError errorWithDomain:TIOChatErrorDomain code:5000 userInfo:@{NSLocalizedDescriptionKey:@"单号为空"}]);
        return;
    }
    
    if (!sessionId) {
        completion(nil, [NSError errorWithDomain:TIOChatErrorDomain code:5000 userInfo:@{NSLocalizedDescriptionKey:@"会话ID为空"}]);
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (uid) {
        params[@"uid"] = uid;
    }
    if (walletid) {
        params[@"walletid"] = walletid;
    }
 
    params[@"chatlinkid"] = sessionId;
    params[@"serialnumber"] = serialNumber;
    
    NSDictionary *p = params;
    
    [TIOHTTPSManager tio_POST:@"/pay/grabRedpacket" parameters:p success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"抢红包成功\n ：%@",responseObject[@"data"]);
        TIOGrabRedPackage *grabRed = [TIOGrabRedPackage objectWithJSONObject:responseObject[@"data"]];
        completion(grabRed, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error => %@",error);
        completion(nil, error);
    }];
}

- (void)fetchRedDetailsWithSerialNumber:(NSString *)serialNumber completion:(nonnull void (^)(TIORedPackage * _Nullable, NSArray<TIOGrabRedPackage *> * _Nullable, NSError * _Nullable))completion
{
    if (!serialNumber) {
        completion(nil ,nil, [NSError errorWithDomain:TIOChatErrorDomain code:5000 userInfo:@{NSLocalizedDescriptionKey:@"红包单号为空"}]);
        return;
    }
    
    NSDictionary *params = @{
        @"serialnumber" : serialNumber
    };
    
    [TIOHTTPSManager tio_POST:@"/pay/redInfo" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"获取红包信息\n ：%@",responseObject[@"data"][@"info"]);
        TIOLog(@"获取红包被抢列表\n ：%@",responseObject[@"data"][@"grablist"]);
        TIORedPackage *info = [TIORedPackage objectWithJSONObject:responseObject[@"data"][@"info"]];
        NSArray *list = [TIOGrabRedPackage objectArrayWithJSONArray:responseObject[@"data"][@"grablist"]];
        completion(info, list, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error => %@",error);
        completion(nil, nil, error);
    }];
}

- (void)checkWithdrawResultWithSerialNumber:(NSString *)serialNumber completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    if (!serialNumber) {
        completion(nil, [NSError errorWithDomain:TIOChatErrorDomain code:5000 userInfo:@{NSLocalizedDescriptionKey:@"提现单号为空"}]);
        return;
    }
    
    NSDictionary *params = @{
        @"serialnumber" : serialNumber
    };
    
    [TIOHTTPSManager tio_POST:@"/pay/withholdQuery" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"提现查询\n ：%@",responseObject[@"data"]);
        completion(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error => %@",error);
        completion(nil, error);
    }];
}

- (void)fetchOwnGradRedListWithFilterYear:(NSString *)year pageNumber:(NSInteger)pageNumber completion:(nonnull void (^)(NSArray<TIOGrabRedPackage *> * _Nullable, BOOL, BOOL, NSError * _Nullable))completion
{
    
    NSDictionary *params = @{
        @"pageNumber" : @(pageNumber),
        @"period" : year?:@""
    };
    
    [TIOHTTPSManager tio_POST:@"/pay/grabRedpacketlist" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"获取自己抢到的红包list\n ：%@",responseObject[@"data"]);
        NSArray *list = [TIOGrabRedPackage objectArrayWithJSONArray:responseObject[@"data"][@"list"]];
        BOOL first = [responseObject[@"data"][@"firstPage"] boolValue];
        BOOL last = [responseObject[@"data"][@"lastPage"] boolValue];
        completion(list, first, last, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error => %@",error);
        completion(nil, 0, 0, error);
    }];
}

- (void)fetchOwnSendRedListWithFilterYear:(NSString *)year pageNumber:(NSInteger)pageNumber completion:(void (^)(NSArray<TIORedPackage *> * _Nullable, BOOL, BOOL, NSError * _Nullable))completion
{
    NSDictionary *params = @{
        @"pageNumber" : @(pageNumber),
        @"period" : year?:@""
    };
    
    [TIOHTTPSManager tio_POST:@"/pay/sendRedpacketlist" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"获取自己发出的红包list\n ：%@",responseObject[@"data"]);
        NSArray *list = [TIORedPackage objectArrayWithJSONArray:responseObject[@"data"][@"list"]];
        BOOL first = [responseObject[@"data"][@"firstPage"] boolValue];
        BOOL last = [responseObject[@"data"][@"lastPage"] boolValue];
        completion(list, first, last, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error => %@",error);
        completion(nil, 0, 0, error);
    }];
}

- (void)fetchWalletWaterListWithRequestType:(TIOWalletWaterRequestType)type pageNumber:(NSInteger)pageNumber completion:(nonnull void (^)(NSArray<TIOWalletWaterDeatil *> * _Nullable, BOOL, BOOL, NSError * _Nullable))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    if (type != TIOWalletWaterRequestTypeAll) {
        params[@"mode"] = @(type);
    }
    params[@"pageNumber"] = @(pageNumber);
    
    [TIOHTTPSManager tio_POST:@"/pay/getWalletItems" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"获取钱包流水明细list\n ：%@",responseObject[@"data"]);
        NSArray *list = [TIOWalletWaterDeatil objectArrayWithJSONArray:responseObject[@"data"][@"list"]];
        BOOL first = [responseObject[@"data"][@"firstPage"] boolValue];
        BOOL last = [responseObject[@"data"][@"lastPage"] boolValue];
        completion(list, first, last, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error => %@",error);
        completion(nil, 0, 0, error);
    }];
}

- (void)fetchWithdrawRecordsWithPageNumber:(NSInteger)pageNumber completion:(nonnull void (^)(NSArray<TIOWalletWithdraw *> * _Nullable, BOOL, BOOL, NSError * _Nullable))completion
{
    NSDictionary *params = @{
        @"pageNumber" : @(pageNumber)
    };
    
    [TIOHTTPSManager tio_POST:@"/pay/withholdlist" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"获取自己发出的红包list：\n %@",responseObject[@"data"]);
        NSArray *list = [TIOWalletWithdraw objectArrayWithJSONArray:responseObject[@"data"][@"list"]];
        BOOL first = [responseObject[@"data"][@"firstPage"] boolValue];
        BOOL last = [responseObject[@"data"][@"lastPage"] boolValue];
        completion(list, first, last, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error => %@",error);
        completion(nil, 0, 0, error);
    }];
}

- (void)fetchGrabDataWithFilterYear:(NSString *)year completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    NSDictionary *params = @{
        @"period" : year?:@""
    };
    
    [TIOHTTPSManager tio_POST:@"/pay/grabredpacketstat" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"统计自己抢到的红包数据\n ：%@",responseObject[@"data"]);
        completion(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error => %@",error);
        completion(nil, error);
    }];
}

- (void)fetchSendDataWithFilterYear:(NSString *)year completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    NSDictionary *params = @{
        @"period" : year?:@""
    };
    
    [TIOHTTPSManager tio_POST:@"/pay/sendredpacketstat" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"统计自己发出的红包数据\n ：%@",responseObject[@"data"]);
        completion(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error => %@",error);
        completion(nil, error);
    }];
}


- (void)createPaymentPassword:(NSString *)pwd completion:(nonnull void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    NSString *plainStr  = [NSString stringWithFormat:@"${%@}%@",TIOChat.shareSDK.loginManager.userInfo.phone,pwd];
    NSString *pd5       = plainStr.MD5Digest;
    
    NSDictionary *p = @{
        @"paypwd" : pd5
    };
    [TIOHTTPSManager tio_POST:@"/user/setpaypwd" parameters:p success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)updatePaymentPassword:(NSString *)initPassword toNewPassword:(NSString *)newPassword completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    NSString *plainStr  = [NSString stringWithFormat:@"${%@}%@",TIOChat.shareSDK.loginManager.userInfo.phone,newPassword];
    NSString *pd5       = plainStr.MD5Digest;
    
    NSDictionary *p = @{
        @"newPwd" : pd5,
        @"initPwd" : initPassword?:@""
    };
    [TIOHTTPSManager tio_POST:@"/user/updatepaypwd" parameters:p success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)findPaymentPasswordWithSMSCode:(NSString *)code newPassword:(NSString *)newPassword completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    NSString *plainStr  = [NSString stringWithFormat:@"${%@}%@",TIOChat.shareSDK.loginManager.userInfo.phone,newPassword];
    NSString *pd5       = plainStr.MD5Digest;
    
    NSDictionary *p = @{
        @"code" : code?:@"",
        @"paypwd" : pd5
    };
    [TIOHTTPSManager tio_POST:@"/user/resetpaypwd" parameters:p success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)checkPaymentPassword:(NSString *)password completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    NSString *plainStr  = [NSString stringWithFormat:@"${%@}%@",TIOChat.shareSDK.loginManager.userInfo.phone,password];
    NSString *pd5       = plainStr.MD5Digest;
    
    NSDictionary *p = @{
        @"paypwd" : pd5
    };
    [TIOHTTPSManager tio_POST:@"/user/checkpaypwd" parameters:p success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)fetchWalletRealInformation:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    [TIOHTTPSManager tio_GET:@"/pay/realinfo" parameters:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject,  nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)fetchBankCardList:(void (^)(NSArray * _Nullable, NSError * _Nullable))completion
{
    [TIOHTTPSManager tio_GET:@"/pay/bankcardlist" parameters:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSArray *array = [TIOBankCard objectArrayWithJSONArray:responseObject[@"data"]];
        completion(array,  nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)beginBindBankCard:(NSString *)banCardNo idCard:(NSString *)idCard mobile:(NSString *)mobile name:(NSString *)name availabledate:(NSString *)availabledate cvv2:(NSString *)cvv2 completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"bankcardno"] = banCardNo;
    params[@"name"] = name;
    params[@"mobile"] = mobile;
    params[@"cardno"] = idCard;
    
    if (availabledate) {
        params[@"availabledate"] = availabledate;
    }
    
    if (cvv2) {
        params[@"cvv2"] = cvv2;
    }
    
    [TIOHTTPSManager tio_POST:@"/pay/bindcard" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)finishBindBankCard:(NSString *)bankCardId merorderid:(NSString *)merorderid smscode:(NSString *)smscode completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    NSDictionary *params = @{
        @"bankcardid" : bankCardId,
        @"merorderid" : merorderid,
        @"smscode" : smscode
    };
    
    [TIOHTTPSManager tio_POST:@"/pay/bindcardconfirm" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)unbindBankCard:(NSString *)bankCardId agreementNo:(NSString *)agreementNo pwd:(NSString *)pwd completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    NSString *plainStr  = [NSString stringWithFormat:@"${%@}%@",TIOChat.shareSDK.loginManager.userInfo.phone,pwd];
    NSString *pd5       = plainStr.MD5Digest;
    
    NSDictionary *params = @{
        @"bankcardid" : bankCardId,
        @"agrno" : agreementNo,
        @"paypwd" : pd5
    };
    
    [TIOHTTPSManager tio_POST:@"/pay/unbindcard" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)fetchPaymentList:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    [TIOHTTPSManager tio_GET:@"/pay/paylistinfo" parameters:@{} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)initRedPackageWithAmount:(NSInteger)amount mode:(NSInteger)mode chatlinkid:(nonnull NSString *)chatlinkid num:(NSInteger)num singleAmount:(NSInteger)singleAmount remark:(NSString * _Nullable)remark completion:(nonnull void (^)(id _Nullable, NSError * _Nullable))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"cny"] = @(amount);
    params[@"mode"] = @(mode);
    params[@"chatlinkid"] = chatlinkid?:@"";
    params[@"num"] = @(num);
    params[@"singlecny"] = @(singleAmount);
    if (remark) {
        params[@"remark"] = remark;
    }
    
    [TIOHTTPSManager tio_POST:@"/pay/initredpacket" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"初始化红包: %@", responseObject[@"data"])
        completion(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)beforeQuickSendRedWithRedId:(NSString *)rid agrno:(NSString *)agrno completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    NSDictionary *params = @{
        @"agrno" : agrno?:@"",
        @"rid" : rid?:@""
    };
    
    [TIOHTTPSManager tio_POST:@"/pay/quickredpacket" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)confirmSendRedPackage:(NSString *)rid type:(NSInteger)type pwd:(NSString * _Nullable)pwd smscode:(NSString * _Nullable)smscode merorderId:(NSString * _Nullable)merorderId completion:(nonnull void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"rid"] = rid;
    params[@"paytype"] = @(type);
    
    if (pwd) {
        NSString *plainStr  = [NSString stringWithFormat:@"${%@}%@",TIOChat.shareSDK.loginManager.userInfo.phone,pwd];
        NSString *pd5       = plainStr.MD5Digest;
        params[@"paypwd"] = pd5;
    }
    
    if (smscode) {
        params[@"smscode"] = smscode;
    }
    
    if (merorderId) {
        params[@"merorderid"] = merorderId;
    }
    
    [TIOHTTPSManager tio_POST:@"/pay/payredpacket" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)queryPayResultForRed:(NSString *)rid reqid:(NSString *)reqid completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    NSDictionary *p = @{
        @"rid" : rid?:@"",
        @"reqid" : reqid?:@""
    };
    
    [TIOHTTPSManager tio_GET:@"/pay/redpacketpayquery" parameters:p success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)queryRedStatusForRed:(NSString *)rid completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    NSDictionary *parmas = @{
        @"rid" : rid,
    };
    
    [TIOHTTPSManager tio_GET:@"/pay/redStatus" parameters:parmas success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

- (void)queryRedInformationForRed:(NSString *)rid completion:(void (^)(TIORedPackage * _Nullable, NSArray<TIOGrabRedPackage *> * _Nullable, NSError * _Nullable))completion
{
    NSDictionary *params = @{
        @"rid" : rid?:@""
    };
    
    [TIOHTTPSManager tio_POST:@"/pay/redInfo" parameters:params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"获取红包信息\n ：%@",responseObject[@"data"][@"info"]);
        TIOLog(@"获取红包被抢列表\n ：%@",responseObject[@"data"][@"grablist"]);
        TIORedPackage *info = [TIORedPackage objectWithJSONObject:responseObject[@"data"][@"info"]];
        NSArray *list = [TIOGrabRedPackage objectArrayWithJSONArray:responseObject[@"data"][@"grablist"]];
        completion(info, list, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error => %@",error);
        completion(nil, nil, error);
    }];
}

- (void)grabRed:(NSString *)rid chatlinkid:(NSString *)chatlinkid completion:(void (^)(TIOGrabRedPackage * _Nullable, NSError * _Nullable))completion
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"chatlinkid"] = chatlinkid;
    params[@"rid"] = rid;
    
    NSDictionary *p = params;
    
    [TIOHTTPSManager tio_POST:@"/pay/grabRedpacket" parameters:p success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        TIOLog(@"抢红包成功\n ：%@",responseObject[@"data"]);
        TIOGrabRedPackage *grabRed = [TIOGrabRedPackage objectWithJSONObject:responseObject[@"data"]];
        completion(grabRed, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        TIOLog(@"error => %@",error);
        completion(nil, error);
    }];
}

- (void)fetchWithdrawConfigWithAmount:(NSInteger)amount completion:(void (^)(NSDictionary * _Nullable, NSError * _Nullable))completion
{
    [TIOHTTPSManager tio_GET:@"/pay/commission" parameters:@{@"amount" : @(amount)} success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        completion(responseObject[@"data"], nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        completion(nil, error);
    }];
}

@end

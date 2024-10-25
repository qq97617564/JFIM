//
//  TIOWalletManager.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/4.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TIOWalletWaterRequestType) {
    TIOWalletWaterRequestTypeAll,   ///< 请求查询所有类型的数据
    TIOWalletWaterRequestTypeRecharge,  ///< 充值
    TIOWalletWaterRequestTypeWithdraw,  ///< 提现
    TIOWalletWaterRequestTypeRed        ///< 红包
};

/// 钱包信息，针对红包
@interface TIOWallet : NSObject
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


/// 红包信息
/// 使用场景：获取红包信息、发送红包后返回的红包信息、发出的红包记录
@interface TIORedPackage : NSObject
/// 【易支付】普通红包:1;人品红包:2
@property (assign,  nonatomic) NSInteger packetType;
/// 【新生支付】普通红包:1;人品红包:2
@property (assign,  nonatomic) NSInteger mode;

/// 【易支付】发送红包的总金额
@property (assign,  nonatomic) NSInteger amount;
/// 【新生支付】发送红包的总金额
@property (assign,  nonatomic) NSInteger cny;

/// 【易支付】红包数量
@property (assign,  nonatomic) NSInteger packetcount;
/// 【新生支付】红包数量
@property (assign,  nonatomic) NSInteger num;

/// 【易支付】已领取的红包个数
@property (assign,  nonatomic) NSInteger receivedcount;
/// 【新生支付】已领取的红包个数
@property (assign,  nonatomic) NSInteger acceptnum;

/// 已领取的金额
@property (assign,  nonatomic) NSInteger receivedamount;
/// 单笔金额:以分为单位普通红包
@property (assign,  nonatomic) NSInteger singleAmount;

/// 1：私聊 2 ：群聊
@property (assign,  nonatomic) NSInteger chatmode;
/// 钱包ID
@property (copy,    nonatomic) NSString *walletId;
/// 订单号
@property (copy,    nonatomic) NSString *serialnumber;
/// 商户号
@property (copy,    nonatomic) NSString *merchantId;

/// 【易支付】订单状态：SUCCESS-已抢完;TIMEOUT-24小时超时;SEND-抢红包中
/// 【新生支付】如下：
/**
    
   byte PROCESS = 1; 处理中-发送中-SEND
   
   byte INIT = 2; 初始化

   byte PAYING = 3; 支付中

   byte PAYING_CONFIRM = 4; 支付确认中

   byte SUCCESS  = 5; 正常结束

   byte TIMEOUT = 6; 超时结束

   byte CANCEL = 7; 取消结束

   byte FAIL = 8; 失败
 */
@property (copy,    nonatomic) NSString *status;

/// 备注-用户填的返回
@property (copy,    nonatomic) NSString *remark;
/// 【新生支付】祝福语
@property (copy,    nonatomic) NSString *bless;

/// 下单token
@property (copy,    nonatomic) NSString *token;
/// 创建时间
@property (copy,    nonatomic) NSString *createDateTime;
/// 被抢完的时间
@property (copy,    nonatomic) NSString *bizcompletetime;
/// 红包发送时间
@property (copy,    nonatomic) NSString *bizcreattime;

/**
 * 新生支付
 */
/// 红包开始时间
@property (copy,    nonatomic) NSString *starttime;
/// 红包结束时间
@property (copy,    nonatomic) NSString *endtime;
/// 红包退回时间
@property (copy,    nonatomic) NSString *backtime;

@property (copy,    nonatomic) NSString *nick;

@property (copy,    nonatomic) NSString *avatar;

@property (copy,    nonatomic) NSString *uid;

@end

/// 抢红包的红包信息
/// 针对用户 场景：自己抢红包接口的返回，自己抢红包记录
@interface TIOGrabRedPackage : NSObject
/// 【易支付】发送红包的总金额
@property (assign,  nonatomic) NSInteger amount;
/// 【新生支付】发送红包的总金额
@property (assign,  nonatomic) NSInteger cny;
/// 1：普通红包 2 ：拼人品
@property (assign,  nonatomic) NSInteger mode;
/// 本次抢红包的单号
@property (copy,    nonatomic) NSString *serialnumber;
/// 红包的单号
@property (copy,    nonatomic) NSString *sendserialnumber;
/// 商户号
@property (copy,    nonatomic) NSString *merchantId;
/// 抢红包的钱包id
@property (copy,    nonatomic) NSString *receiveWalletId;
/// 创建时间
@property (copy,    nonatomic) NSString *createDateTime;
@property (copy,    nonatomic) NSString *bizcompletetime;
/// 【新生支付】抢红包时间
@property (copy,    nonatomic) NSString *grabtime;

/// 抢红包人的钱包ID
@property (copy,    nonatomic) NSString *walletid;
/// 抢红包人的头像
@property (copy,    nonatomic) NSString *avatar;
/// 抢红包人的uid
@property (copy,    nonatomic) NSString *uid;
/// 抢红包状态：INIT 未抢 SUCCESS
@property (copy,    nonatomic) NSString *status;
@property (copy,    nonatomic) NSString *nick;
@property (copy,    nonatomic) NSString *remark;
@property (copy,    nonatomic) NSString *reqid;
@property (copy,    nonatomic) NSString *token;

@property (assign,  nonatomic) BOOL isLucky;

@end


/// 流水明细model
/// 使用场景：钱包明细的各个流水记录：全部、充值、提现、红包等
@interface TIOWalletWaterDeatil : NSObject
/// 类型：1：充值；2：提现；3：红包
@property (assign,  nonatomic) NSInteger mode;
@property (assign,  nonatomic) NSInteger amount;
@property (assign,  nonatomic) NSInteger cny;
/// 收支：1：收入；2：支出
@property (assign,  nonatomic) NSInteger coinflag;
@property (copy,    nonatomic) NSString *uid;
/// 订单状态：SUCCESS;FAIL;PROCESS
@property (copy,    nonatomic) NSString *orderstatus;
/// 新生支付单号
@property (copy,    nonatomic) NSString *reqid;
/// 新生支付
@property (copy,    nonatomic) NSString *status;
/// 订单号
@property (copy,    nonatomic) NSString *serialnumber;
/// 业务描述
@property (copy,    nonatomic) NSString *bizstr;
/// 业务描述
@property (copy,    nonatomic) NSString *bizid;
@property (copy,    nonatomic) NSString *remark;
@property (copy,    nonatomic) NSString *bizcompletetime;
@property (copy,    nonatomic) NSString *bizcreattime;
@end

@interface TIOWalletWithdraw : NSObject
@property (assign,  nonatomic) NSInteger amount;
@property (assign,  nonatomic) NSInteger arrivalamount;
@property (copy,    nonatomic) NSString *cardno; // 新生支付专用卡号字段
@property (copy,    nonatomic) NSString *bankcardnumber;
@property (copy,    nonatomic) NSString *bankcode;
@property (copy,    nonatomic) NSString *bankicon;
@property (copy,    nonatomic) NSString *bankname;
@property (copy,    nonatomic) NSString *coinsyn;
@property (copy,    nonatomic) NSString *currency;
/// 订单号
@property (copy,    nonatomic) NSString *serialnumber;
/// 订单状态：SUCCESS;FAIL;PROCESS
@property (copy,    nonatomic) NSString *status;
@property (copy,    nonatomic) NSString *token;
@property (copy,    nonatomic) NSString *bizcreattime;
@property (copy,    nonatomic) NSString *bizcompletetime;
@property (copy,    nonatomic) NSString *walletid;
@property (copy,    nonatomic) NSString *merorderid;// 新生支付专用卡号字段 商户单号
@property (copy,    nonatomic) NSString *reqid;// 新生支付专用卡号字段 平台单号
@end

/**
 * 银行卡/支付选项
 */
@interface TIOBankCard : NSObject
@property (copy,    nonatomic) NSString *agrno;
@property (copy,    nonatomic) NSString *backcolor;
@property (copy,    nonatomic) NSString *bankcode;
@property (copy,    nonatomic) NSString *banklogo;
@property (copy,    nonatomic) NSString *bankname;
@property (copy,    nonatomic) NSString *bankwatermark;
@property (copy,    nonatomic) NSString *cardno;
@property (copy,    nonatomic) NSString *card_id;
@property (copy,    nonatomic) NSString *phone;
@end

@interface TIOWalletManager : NSObject

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

/// 获取安全设置的token
/// @param uid 用户uid
/// @param walletid 钱包id
- (void)fetchSafeTokenWithUid:(NSString *)uid
                     walletid:(NSString *)walletid
                   completion:(void(^)(NSDictionary * __nullable responseObject, NSError * __nullable error))completion;

/// 获取银行卡列表页的token
/// @param uid 用户uid
/// @param walletid 钱包id
- (void)fetchBankCardListTokenWithUid:(NSString *)uid
                             walletid:(NSString *)walletid
                           completion:(void(^)(NSDictionary * __nullable responseObject, NSError * __nullable error))completion;

/// 获取钱包详情 (易支付)
/// @param uid 用户ID
/// @param walletid 钱包ID
- (void)fetchWalletDetailWithUid:(NSString *)uid
                        walletid:(NSString *)walletid
                      completion:(void(^)(TIOWallet * __nullable wallet, NSError * __nullable error))completion;

/// 获取钱包详情 （新生支付）
- (void)fetchWalletInformation:(void(^)(NSDictionary * __nullable responseObject, NSError * __nullable error))completion;

/// 获取开户状态
- (void)checkOpenAccountStatus:(void(^)(NSDictionary * __nullable responseObject, NSError * __nullable error))completion;

/// 充值预下单 (易支付)
/// @param amount 金额
/// @param walletid 钱包ID
/// @param uid 用户ID
/// @param remark 备注说明
- (void)rechargeMoney:(NSString *)amount
             walletid:(NSString *)walletid
                  uid:(NSString *)uid
               remark:(NSString *)remark
           completion:(void(^)(NSDictionary * __nullable responseObject, NSError * __nullable error))completion;

/// 充值预下单 （新生支付）
/// @param amount 金额
/// @param agrno 协议卡号
/// @param remark 备注
- (void)beforeRechargeMoney:(NSInteger)amount agrno:(NSString *)agrno remark:(NSString * _Nullable)remark completion:(void(^)(NSDictionary * __nullable responseObject, NSError * __nullable error))completion;

/**
 data =     {
     agrno = XXXXX;
     amount = 1;
     appversion = "2.4.3";
     bankcardnumber = "";
     bankcode = "";
     bankicon = "";
     bankname = "";
     bizcompletetime = "";
     bizcreattime = "2021-03-16 16:52:34";
     bizfee = 0;
     checkdate = "";
     checkflag = 2;
     coinsyn = 2;
     createtime = "2021-03-16 16:52:35";
     device = 3;
     id = 205;
     ip = "115.227.197.169";
     merfee = 0;
     merid = XXXXXXXXX;
     merorderid = XXXXX;
     merstatus = "-1";
     notifyurl = "https://tx.t-io.org/mytio/paycallback/recharge.tio_x?uid=XXXX";
     ordererrormsg = "";
     querysyn = 2;
     recvacctamount = 0;
     reqid = "XXXXXXXX";
     status = 2;
     timeout = 5;
     uid = 37886;
     updatetime = "2021-03-16 16:52:50";
     walletid = XXXXX;
 };
 */
/// 确认充值 （新生支付）
/// @param merorderid 商户订单号
/// @param rid 预下单订单id
/// @param sms 短信
- (void)confirmRecharging:(NSString *)merorderid rid:(NSString *)rid sms:(NSString *)sms completion:(void(^)(NSDictionary * __nullable responseObject, NSError * __nullable error))completion;

/// 充值结果查询
/// @param rid  预下单订单id
/// @param reqid 支付请求id，请注意，不是商户订单号 从 上一步“确认充值 （新生支付）” 中获取
- (void)queryRechargeStatusWithRid:(NSString *)rid reqid:(NSString *)reqid completion:(void(^)(NSInteger status, NSError * __nullable error))completion;

/// 提现预下单 (易支付)
/// @param amount 金额
/// @param walletid 钱包ID
/// @param uid 用户ID
/// @param remark 备注说明
- (void)withdrawMoney:(NSString *)amount
             walletid:(NSString *)walletid
                  uid:(NSString *)uid
               remark:(NSString *)remark
           completion:(void(^)(NSDictionary * __nullable responseObject, NSError * __nullable error))completion;
/**
 responseObject 响应：
 id = 115;
 reqid = XXXXX;
 agrno = XXXXX;
 merorderid = XXXX;
 uid = XXX;
 amount = 1;
 ordererrormsg = ;
 appversion = 2.4.3;
 bizfee = 0;
 walletid = XX;
 merid = XX;
 merstatus = -1;
 ip = 115.227.197.169;
 bizcreattime = 2021-03-17 00:00:00;
 notifyurl = https://tx.t-io.org/mytio/paycallback/withhold.tio_x?uid=XX;
 device = 3;
 status = -1;
 arrivalamount = 1;
 */
/// 提现 (新生支付)
/// @param amount 金额 精确到分的整型    1 =  0.01 ，  10 = 0.1，  100 = 1
/// @param agrno 协议号
/// @param paypwd 密码明文
/// @param remark 备注
- (void)withdrawMoney:(NSInteger)amount agrno:(NSString *)agrno paypwd:(NSString *)paypwd remark:(NSString *_Nullable)remark completion:(void(^)(NSDictionary * __nullable responseObject, NSError * __nullable error))completion;

/// 提现查询
/// @param wid 提现订单ID
/// @param reqid 请求ID
- (void)queryWithdrawStatusWithWid:(NSString *)wid reqid:(NSString *)reqid completion:(void(^)(NSDictionary *_Nullable result, NSError * __nullable error))completion;

/// 【易支付】 发红包预下单
/// @param sessionid 会话ID
/// @param packetType 红包类型 （普通红包:1;人品红包:2）
/// @param amount 总金额
/// @param singleAmount 单个红包的金额 （一对一红包：总金额。群普通红包：每个红包的金额）
/// @param packetCount 群红包个数
/// @param uid 自己的用户ID【可选】
/// @param walletid 自己的钱包ID【可选】
/// @param remark 备注的祝福语【可选】
- (void)sendRedPackageToSession:(NSString *)sessionid
                     packetType:(NSInteger)packetType
                         amount:(NSInteger)amount
                   singleAmount:(NSInteger)singleAmount
                    packetCount:(NSInteger)packetCount
                            uid:(NSString * _Nullable )uid
                       walletid:(NSString * _Nullable )walletid
                         remark:(NSString * _Nullable )remark
                     completion:(void(^)(TIORedPackage * __nullable redPackage, NSError * __nullable error))completion;

///【易支付】 查询红包的状态：抢红包之前，调用此接口检查红包是否可抢
/// @param serialNumber 红包订单号
/// @param completion
/// grabstatus 自己抢的状态：INIT-未抢;SUCCESS-已抢
/// redstatus 红包状态：SUCCESS-已抢完;TIMEOUT-24小时超时;SEND-抢红包中
- (void)checkRedStatusWithRedNumber:(NSString *)serialNumber
                         completion:(void(^)(NSString * __nullable grabstatus,NSString * __nullable redstatus, NSInteger openflag, NSError * __nullable error))completion;

/// 【易支付】 抢红包
/// @param serialNumber 红包订单号
/// @param uid 抢红包人的uid
/// @param walletid 抢红包人的钱包ID
/// @param sessionId 会话ID
- (void)grabRedpackageWithRedNumber:(NSString *)serialNumber
                          sessionId:(NSString *)sessionId
                                uid:(NSString *_Nullable)uid
                           walletid:(NSString *_Nullable)walletid
                         completion:(void(^)(TIOGrabRedPackage * __nullable grabRedPackage, NSError * __nullable error))completion;

/// 【易支付】 获取红包详情：红包信息+抢红包的好友列表
/// @param serialNumber 红包单号
- (void)fetchRedDetailsWithSerialNumber:(NSString *)serialNumber
                             completion:(void(^)(TIORedPackage * __nullable redInfor, NSArray<TIOGrabRedPackage *> * __nullable grabList,  NSError * __nullable error))completion;

/// 【易支付】 查询提现结果 (易支付)
/// @param serialNumber 提现操作的单号
- (void)checkWithdrawResultWithSerialNumber:(NSString *)serialNumber
                                 completion:(void(^)(NSDictionary * __nullable responseObject, NSError * __nullable error))completion;

/// 获取自己的抢红包列表数据
- (void)fetchOwnGradRedListWithFilterYear:(NSString *)year pageNumber:(NSInteger)pageNumber completion:(void(^)(NSArray<TIOGrabRedPackage *>* __nullable grabList, BOOL first,BOOL last, NSError * __nullable error))completion;

/// 获取自己发出的红包列表数据
/// @param year 筛选的年份
/// @param pageNumber 页码
- (void)fetchOwnSendRedListWithFilterYear:(NSString *)year pageNumber:(NSInteger)pageNumber completion:(void(^)(NSArray<TIORedPackage *>* __nullable grabList, BOOL first,BOOL last, NSError * __nullable error))completion;

/// 钱包流水明细列表
/// @param type 类型：所有，充值，提现，红包
/// @param pageNumber 页码
- (void)fetchWalletWaterListWithRequestType:(TIOWalletWaterRequestType)type pageNumber:(NSInteger)pageNumber completion:(void(^)(NSArray<TIOWalletWaterDeatil *>* __nullable list, BOOL first,BOOL last, NSError * __nullable error))completion;

/// 获取提现记录数据
/// @param pageNumber 页码
- (void)fetchWithdrawRecordsWithPageNumber:(NSInteger)pageNumber completion:(void(^)(NSArray<TIOWalletWithdraw *>* __nullable withdrawList, BOOL first,BOOL last, NSError * __nullable error))completion;

/// 统计自己抢到的红包数据
/// @param year 筛选年份
- (void)fetchGrabDataWithFilterYear:(NSString *)year completion:(void(^)(NSDictionary *__nullable result, NSError * __nullable error))completion;

/// 统计自己发出的红包数据
/// @param year 筛选年份
- (void)fetchSendDataWithFilterYear:(NSString *)year completion:(void(^)(NSDictionary *__nullable result, NSError * __nullable error))completion;


/// 创建初始支付密码
/// @param pwd 密码明文
- (void)createPaymentPassword:(NSString *)pwd completion:(void(^)(NSDictionary *_Nullable responObject, NSError * _Nullable error))completion;

/// 修改支付密码
/// @param initPassword 原始密码明文
/// @param newPassword 新密码明文
- (void)updatePaymentPassword:(NSString *)initPassword toNewPassword:(NSString *)newPassword completion:(void(^)(NSDictionary *_Nullable responObject, NSError * _Nullable error))completion;

/// 忘记 找回支付密码
/// @param code 前一步的验证码
/// @param newPassword 新密码
- (void)findPaymentPasswordWithSMSCode:(NSString *)code newPassword:(NSString *)newPassword completion:(void(^)(NSDictionary *_Nullable responObject, NSError * _Nullable error))completion;

/// 检查验证支付密码
/// @param password 密码明文
- (void)checkPaymentPassword:(NSString *)password completion:(void(^)(NSDictionary *_Nullable responObject, NSError * _Nullable error))completion;

/// 获取钱包的实名信息
- (void)fetchWalletRealInformation:(void(^)(NSDictionary *_Nullable responObject, NSError * _Nullable error))completion;

/// 获取银行卡列表
- (void)fetchBankCardList:(void(^)(NSArray *_Nullable responObject, NSError * _Nullable error))completion;


/**
 data =     {
     cardno = "621799*********6";
     id = 1;
     merid = 300977;
     merorderid = 2021039767;
     phone = 1818553;
     reqid = "R007_37886_202103152";
     status = 2;
     uid = 2222;
     username = "";
     walletid = ;
 };
 */
/// 绑银行卡
/// @param banCardNo 卡号
/// @param idCard 身份证号
/// @param mobile 银行预留的手机号
/// @param name 银行预留的真实姓名
/// @param availabledate 信用卡有效期 绑储蓄卡传nil
/// @param cvv2 信用卡的cvv2 绑储蓄卡传nil
- (void)beginBindBankCard:(NSString *)banCardNo idCard:(NSString *)idCard mobile:(NSString *)mobile name:(NSString *)name availabledate:(NSString * _Nullable)availabledate cvv2:(NSString * _Nullable)cvv2 completion:(void(^)(NSDictionary *_Nullable responObject, NSError * _Nullable error))completion;

/// 确认绑卡
/// @param bankCardId 上一步 发起绑卡操作返回的id
/// @param merorderid 上一步 发起绑卡操作返回的merorderid
/// @param smscode 短信验证码
- (void)finishBindBankCard:(NSString *)bankCardId merorderid:(NSString *)merorderid smscode:(NSString *)smscode completion:(void(^)(NSDictionary *_Nullable responObject, NSError * _Nullable error))completion;

/// 解除绑定
/// @param bankCardId 获取的支付银行卡列表中的ID
/// @param agreementNo 协议号
/// @param pwd 支付密码
- (void)unbindBankCard:(NSString *)bankCardId agreementNo:(NSString *)agreementNo pwd:(NSString *)pwd completion:(void(^)(NSDictionary *_Nullable responObject, NSError * _Nullable error))completion;

/// 支付列表 包括余额信息 银行卡
- (void)fetchPaymentList:(void(^)(NSDictionary *_Nullable responObject, NSError * _Nullable error))completion;

#pragma mark - 新生支付 红包功能

/**
 responObject: 整型 红包id
 33333
 */
/// 初始化红包
/// @param amount 总金额
/// @param mode 普通红包:1;手气红包:2
/// @param chatlinkid 会话ID 同sessionId
/// @param num 红包数量:一对一红包数量为 1，普通群红包和拼手气红包 数量最大 100 个
/// @param singleAmount 单笔金额:以分为单位普通红包
/// @param remark 备注 选填
- (void)initRedPackageWithAmount:(NSInteger)amount mode:(NSInteger)mode chatlinkid:(NSString *)chatlinkid num:(NSInteger)num singleAmount:(NSInteger)singleAmount remark:(NSString *_Nullable)remark completion:(void(^)(id _Nullable responObject, NSError * _Nullable error))completion;

/**
 responObject:
 
 bizcreattime = XXX;
 merid 商户号
 merorderid = XXX;
 merstatus = SUCCESS;
 ordererrormsg = "";
 reqid = "XXX";
 uid = XXX;
 */
/// 红包支付 快捷支付发短信
/// @param rid 红包id
/// @param agrno 协议号
- (void)beforeQuickSendRedWithRedId:(NSString *)rid agrno:(NSString *)agrno completion:(void(^)(NSDictionary *_Nullable responObject, NSError * _Nullable error))completion;

/**
 acceptnum = 0;
 acceptuid = XX;
 agrno 协议号
 appversion APP版本号
 bizcompletetime = "";
 bizcreattime = "2021-03-17 19:14:33";
 bless = "\U606d\U559c\U53d1\U8d22\Uff0c\U5409\U7965\U5982\U610f";
 chatbizid = 37885;
 chatmode = 会话类型
 checkdate = "";
 checkflag = 2;
 cny = 1;
 coinsyn = 2;
 covers = "";
 createtime = "2021-03-17 19:14:04";
 device = 3;
 id = 12;
 ip = "115.227.197.169";
 merid = 商户号
 merorderid = 商户订单号
 mode = 1;
 num = 1;
 ordererrormsg  订单异常信息
 paynotifyurl = "https://tx.t-io.org/mytio/paycallback/redpacket.tio_x?uid=37886";
 paytimeout = 5;
 querysyn = 2;
 remark = "";
 reqid = "XX";
 status  红包发送状态 1:成功  4:银行处理中
 subwalletid = XX;
 uid = 37886;
 updatetime = "2021-03-17 19:14:44";
 walletid = XX;
 */
/// 红包支付 确认订单
/// @param rid 红包id 从上一步获得
/// @param type 支付类型：1：余额；2：快捷支付
/// @param pwd 密码 （余额支付时必传）
/// @param smscode 短信 （短信快捷支付）
/// @param merorderId 商户订单号 （短信快捷支付）
- (void)confirmSendRedPackage:(NSString *)rid type:(NSInteger)type pwd:(NSString *_Nullable)pwd smscode:(NSString *_Nullable)smscode merorderId:(NSString *_Nullable)merorderId completion:(void(^)(NSDictionary *_Nullable responObject, NSError * _Nullable error))completion;

/// 查询红包支付结果
/// @param rid 红包id
/// @param reqid 请求id 来自上一步确认支付中的id
- (void)queryPayResultForRed:(NSString *)rid reqid:(NSString *)reqid completion:(void(^)(NSDictionary *_Nullable responObject, NSError * _Nullable error))completion;

/*
 openflag   用户是否开户：1：是；2：否
 grabstatus 自己抢的状态：2-未抢;1-已抢
 redstatus  红包状态：5-已抢完;6-24小时超时;1-抢红包中
 */
/// 抢红包状态
/// @param rid 红包id
- (void)queryRedStatusForRed:(NSString *)rid completion:(void(^)(NSDictionary *_Nullable responObject, NSError * _Nullable error))completion;

/// 查询红包信息
/// @param rid 红包ID
- (void)queryRedInformationForRed:(NSString *)rid completion:(void(^)(TIORedPackage * __nullable redInfor, NSArray<TIOGrabRedPackage *> * __nullable grabList,  NSError * __nullable error))completion;

/// 抢红包
/// @param rid 红包ID
/// @param chatlinkid 会话id
- (void)grabRed:(NSString *)rid chatlinkid:(NSString *)chatlinkid completion:(void(^)(TIOGrabRedPackage * __nullable grabRedPackage, NSError * __nullable error))completion;

/// 获取提现配置信息 提现服务费、最大提现金、最小提现金
- (void)fetchWithdrawConfigWithAmount:(NSInteger)amount completion:(void(^)(NSDictionary *_Nullable responObject, NSError * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END

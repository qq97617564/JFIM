//
//  NWPay.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/5.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "NWPay.h"
#import "NWPayChannelPicker.h"
#import "NWPaymentObject.h"
#import "NWBindNewCardVC.h"
#import "NWPaymentAlert.h"
#import "NWSMSPaymentALert.h"
#import "NWRedPasswordPaymentAlert.h"
#import "NWSettingPayPasswordVC.h"

#import "TAlertController.h"

@interface NWPay ()
@property (assign,  nonatomic) BOOL lock;
/// 最新操作的code，当上一个业务操作未完成时，当前标记为temp
@property (assign,  nonatomic) NWBusinessCode tempCode;
@property (copy,    nonatomic) void(^nw_callback)(NSDictionary * _Nullable result, NWBusinessCode businessCode, NSError * _Nullable error);

@property (strong,  nonatomic) UIActivityIndicatorView *activityIndicatorView;

@property (strong,  nonatomic) id <NWPaymentChannel> payment;
@property (assign,  nonatomic) NSInteger balance;
/// 充值预下单返回
@property (strong,  nonatomic) NSDictionary *beforeRechargeResult;
/// 银行卡发红包预下单的响应  （快捷支付发短信的响应回调）
@property (strong,  nonatomic) NSDictionary *beforeSendRedByBankCardResult;

@end

@implementation NWPay

+ (instancetype)shareInstance
{
    static NWPay *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
        _sharedManager.balance = -1;
    });

    return _sharedManager;
}

- (void)setCode:(NWBusinessCode)code
{
    if (self.lock) {
        self.tempCode = code;
        return;
    }
    
    _code = code;
}

- (void)evoke:(void (^)(NSDictionary * _Nullable, NWBusinessCode, NSError * _Nullable))callback
{
    if (self.lock) {
        callback(nil, self.tempCode, [NSError errorWithDomain:@"" code:3000 userInfo:@{NSLocalizedDescriptionKey:@"当前有正在处理的业务"}]);
        return;
    }
    
//    self.lock = YES;
    self.nw_callback = callback;
    switch (self.code) {
        case NWBusinessCodeSelectPayment: // 直接吊选择支付方式
        {
            CBWeakSelf
            [self checkBindAnyCard:^(BOOL re) {
                CBStrongSelfElseReturn
                if (re) {
                    CBWeakSelf
                    [self showPaymentListWithShowBalance:NO completion:^(id<NWPaymentChannel> payment) {
                        CBStrongSelfElseReturn
                        self.nw_callback(@{@"result":payment}, self.code, nil);
                    }];
                }
            }];
        }
            break;
        case NWBusinessCodeNormalRed: // 普通红包
        case NWBusinessCodeRandomRed: // 随机红包
        {
            self.beforeSendRedByBankCardResult = nil;
            self.payment = nil;
            self.balance = -1;
            [self checkBindAnyCard:^(BOOL re) {
                if (re) {
                    [self sendRed];
                }
            }];
        }
            break;
        case NWBusinessCodeRecharge: // 充值
        {
            self.beforeRechargeResult = nil;
            self.payment = nil;
            [self checkBindAnyCard:^(BOOL re) {
                if (re) {
                    [self recharge];
                }
            }];
        }
            break;
        case NWBusinessCodeWithDraw: // 提现
        {
            [self checkBindAnyCard:^(BOOL re) {
                if (re) {
                    [self withdraw];
                }
            }];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 发红包

/// 带余额的付款   发红包
- (void)sendRed
{
//    [self alertSMSRedPayment]; // 先银行卡快捷支付
//    [self alertPwdRedPayment]; // 先余额支付
    
    if (self.balance == -1) { // 未获取最新金额
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            
            [TIOChat.shareSDK.walletManager fetchPaymentList:^(NSDictionary * _Nullable responObject, NSError * _Nullable error) {
                NSArray *banklist = [NWPaymentObject objectArrayWithJSONArray:responObject[@"banklist"]];
                self.balance = [responObject[@"walletinfo"][@"cny"] integerValue];
                if (banklist.count) {
                    self.payment = banklist.firstObject;
                }
                
                dispatch_semaphore_signal(semaphore);
            }];
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self alertPwdRedPayment];
            });
        });
    } else {
        [self alertPwdRedPayment];
    }
}

- (void)alertSMSRedPayment
{
    NWSMSPaymentALert *alert = [NWSMSPaymentALert alert];
    alert.titleLabel.text = @"发红包";
    alert.money = [NSString stringWithFormat:@"%.2f",self.amount/100.f];
    
    // 如果有已选、默认的第一张银行卡 ，默认显示这个付款方式
    if (self.balance != -1 && self.payment) {
        alert.paymentName = [NSString stringWithFormat:@"%@（%@）",self.payment.name, self.payment.backFourCardNo];
        alert.phone = self.payment.bank_phone;
    } else {
        alert.phone = @"";
    }
    
    CBWeakSelf
    /// 点击了切换支付方式 otherPaymentCompleted为点击事件
    alert.otherPaymentCompleted = ^(NWSMSPaymentALert * _Nonnull paymentAlert, void (^ _Nonnull completion)(BOOL)) {
        CBStrongSelfElseReturn
        /// 展示带有余额的支付选择器
        /// 如果选择了余额，要让当前alert消失，弹出余额支付框
        CBWeakSelf
        [self showPaymentListWithShowBalance:YES completion:^(id<NWPaymentChannel> payment) {
            CBStrongSelfElseReturn
            if (payment.type != NWPaymentTypeBalance) {
                paymentAlert.paymentName = [NSString stringWithFormat:@"%@（%@）",payment.name, payment.backFourCardNo];
                paymentAlert.phone = payment.bank_phone;
                self.payment = payment;
            } else {
                completion(YES); // 关闭弹窗
                [self alertPwdRedPayment]; // 切换成余额的支付窗
            }
        }];
    };
    
    /// 点击了取消按钮
    alert.cancelHandler = ^(BOOL paying, NWSMSPaymentALert * _Nonnull paymentALert, void (^ _Nonnull completion)(BOOL)) {
        CBStrongSelfElseReturn
        if (paying) {
            TAlertController *alert = [TAlertController alertControllerWithTitle:nil message:@"确定放弃充值吗" preferredStyle:TAlertControllerStyleAlert];
            [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
                
            }]];
            [alert addAction:[TAlertAction actionWithTitle:@"确定" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
                /// 支付弹窗消失
                completion(YES);
            }]];
            [self.currentViewController presentViewController:alert animated:YES completion:nil];
        }
    };
    
    /// 点击了获取验证码
    /// 实质是充值预下单，同时自动触发验证码发送
    alert.fetchSMSHandler = ^(NWSMSPaymentALert * _Nonnull paymentALert, void (^ _Nonnull startCounting)(BOOL)) {
        CBStrongSelfElseReturn
        
        if (self.payment) {
            CBWeakSelf
            [self showLoading];
            /// 快捷支付发短信
            if (self.payment) {
                [TIOChat.shareSDK.walletManager beforeQuickSendRedWithRedId:self.redId agrno:self.payment.agreementNo completion:^(NSDictionary * _Nullable responObject, NSError * _Nullable error) {
                    CBStrongSelfElseReturn
                    
                    [self hideLoading];
                    
                    if (!error) {
                        startCounting(YES);
                        /// 留待确认支付时使用
                        self.beforeSendRedByBankCardResult = responObject;
                    } else {
                    }
                }];
            }
        }
    };
    /// 确认充值
    alert.completeHandler = ^(NWSMSPaymentALert * _Nonnull paymentALert, NSString * _Nonnull sms, void (^ _Nonnull completion)(BOOL)) {
        CBStrongSelfElseReturn
        if (self.beforeSendRedByBankCardResult) {
            // 商户订单号
            NSString *merorderid = self.beforeSendRedByBankCardResult[@"merorderid"];
            
            [self showLoading];
            CBWeakSelf
            [TIOChat.shareSDK.walletManager confirmSendRedPackage:self.redId type:2 pwd:nil smscode:sms merorderId:merorderid completion:^(NSDictionary * _Nullable responObject, NSError * _Nullable error) {
                CBStrongSelfElseReturn
                [self hideLoading];
                completion(YES);
                if (error) {
                    self.nw_callback(nil, self.code, error);
                } else {
                    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:responObject];
                    dic[@"result"] = @(YES);
                    self.nw_callback(dic, self.code, nil);
                }
            }];
        } else {
            NSLog(@"验证码未获取");
        }
    };
    [alert showOnView:self.currentViewController.view];
}

/// 红包支付框 ： 用密码支付
- (void)alertPwdRedPayment
{
    NWRedPasswordPaymentAlert *alert = [NWRedPasswordPaymentAlert alert];
    alert.titleLabel.text = @"发红包";
    alert.money = [NSString stringWithFormat:@"%.2f",self.amount/100.f];
    alert.paymentName = [NSString stringWithFormat:@"余额（¥%.2f）",self.balance/100.f];
    
    CBWeakSelf
    /// 点击了切换支付方式 otherPaymentCompleted为点击事件
    alert.otherPaymentCompleted = ^(NWRedPasswordPaymentAlert * _Nonnull paymentAlert, void (^ _Nonnull completion)(BOOL)) {
        CBStrongSelfElseReturn
        /// 展示带有余额的支付选择器
        /// 如果选择了余额，要让当前alert消失，弹出余额支付框
        CBWeakSelf
        [self showPaymentListWithShowBalance:YES completion:^(id<NWPaymentChannel> payment) {
            CBStrongSelfElseReturn
            self.payment = payment;
            if (payment.type == NWPaymentTypeBalance) {
            } else {
                completion(YES); // 关闭弹窗
                [self alertSMSRedPayment]; // 切换成快捷支付窗
            }
        }];
    };
    
    /// 密码输入结束 开始支付
    alert.inputPasswordCompleted = ^(NSDictionary * _Nonnull result, NWRedPasswordPaymentAlert * _Nonnull alertt, NSString * _Nonnull pwd) {
        CBStrongSelfElseReturn
        /// 支付
        [self showLoading];
        CBWeakSelf
        [TIOChat.shareSDK.walletManager confirmSendRedPackage:self.redId type:1 pwd:pwd smscode:nil merorderId:nil completion:^(NSDictionary * _Nullable responObject, NSError * _Nullable error) {
            CBStrongSelfElseReturn
            [self hideLoading];
            if (error) {
                self.nw_callback(nil, self.code, error);
            } else {
                [alertt dismiss:@""];
                NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:responObject];
                dic[@"result"] = @(YES);
                self.nw_callback(dic, self.code, nil);
            }
        }];
    };
    [alert showOnView:self.currentViewController.view];
}

#pragma mark - 提现
/// 提现  只有银行卡
- (void)withdraw
{
    CBWeakSelf
    NWPaymentAlert *alert = [NWPaymentAlert alert];
    alert.titleLabel.text = @"提现";
    alert.money = [NSString stringWithFormat:@"%.2f",self.amount/100.f];
    alert.subLabel.attributedText = ({
        
        CGFloat fee = self.fee / 100.f;
        NSString *text1 = [NSString stringWithFormat:@"服务费：¥%.2f",fee];
        
        
        
        NSMutableAttributedString *attributedString = [NSMutableAttributedString.alloc init];
        [attributedString appendAttributedString:[NSAttributedString.alloc initWithString:text1 attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12], NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#333333"]}]];
        [attributedString appendAttributedString:[NSAttributedString.alloc initWithString:[NSString stringWithFormat:@"（费率%0.2f%%+%.2f元）",self.rate/10.f,self.withholdconst/100.f] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12], NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#9C9C9C"]}]];
        
        attributedString;
    });
    alert.inputPasswordCompleted = ^(NSDictionary * _Nonnull result, NWPaymentAlert * _Nonnull alertt, NSString * _Nonnull pwd) {
        CBStrongSelfElseReturn
        
        [self showLoading];
        
        CBWeakSelf
        [TIOChat.shareSDK.walletManager withdrawMoney:self.amount agrno:self.agrno paypwd:pwd remark:nil completion:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
            CBStrongSelfElseReturn
            [self hideLoading];
            if (error) {
                NSDictionary *dic = @{
                    @"result" : @(NO),
                };
                self.nw_callback(dic, self.tempCode, error);
            } else {
                NSMutableDictionary *result = [NSMutableDictionary dictionaryWithDictionary:responseObject];
                result[@"result"] = @(YES);
                self.nw_callback(result, self.tempCode, nil);
            }
            
            [alertt dismiss:@""];
        }];
        
    };
    [alert showOnView:self.currentViewController.view];
}

#pragma mark - 充值
/// 先弹出支付框，而后选择支付方式
- (void)recharge
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [TIOChat.shareSDK.walletManager fetchBankCardList:^(NSArray * _Nullable responObject, NSError * _Nullable error) {
            if (responObject.count) {
                NWPaymentObject *payment = [NWPaymentObject.alloc initWithModel:responObject.firstObject];
                self.payment = payment;
            }
            
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NWSMSPaymentALert *alert = [NWSMSPaymentALert alert];
            alert.titleLabel.text = @"充值";
            alert.money = [NSString stringWithFormat:@"%.2f",self.amount/100.f];
            if (self.payment) {
                alert.paymentName = [NSString stringWithFormat:@"%@（%@）",self.payment.name, self.payment.backFourCardNo];
                alert.phone = self.payment.bank_phone;
            } else {
                alert.phone = @"";
            }
            
            CBWeakSelf
            /// 点击了切换支付方式
            alert.otherPaymentCompleted = ^(NWSMSPaymentALert * _Nonnull paymentAlert, void (^ _Nonnull completion)(BOOL)) {
                CBStrongSelfElseReturn
                CBWeakSelf
                [self showPaymentListWithShowBalance:NO completion:^(id<NWPaymentChannel> payment) {
                    CBStrongSelfElseReturn
                    
                    paymentAlert.paymentName = [NSString stringWithFormat:@"%@（%@）",payment.name, payment.backFourCardNo];
                    paymentAlert.phone = payment.bank_phone;
                    self.payment = payment;
                }];
            };
            /// 点击了取消按钮
            alert.cancelHandler = ^(BOOL paying, NWSMSPaymentALert * _Nonnull paymentALert, void (^ _Nonnull completion)(BOOL)) {
                CBStrongSelfElseReturn
                if (paying) {
                    TAlertController *alert = [TAlertController alertControllerWithTitle:nil message:@"确定放弃充值吗" preferredStyle:TAlertControllerStyleAlert];
                    [alert addAction:[TAlertAction actionWithTitle:@"取消" style:TAlertActionStyleCancel handler:^(TAlertAction * _Nonnull action) {
                        
                    }]];
                    [alert addAction:[TAlertAction actionWithTitle:@"确定" style:TAlertActionStyleDone handler:^(TAlertAction * _Nonnull action) {
                        /// 支付弹窗消失
                        completion(YES);
                    }]];
                    [self.currentViewController presentViewController:alert animated:YES completion:nil];
                }
            };
            /// 点击了获取验证码
            /// 实质是充值预下单，同时自动触发验证码发送
            alert.fetchSMSHandler = ^(NWSMSPaymentALert * _Nonnull paymentALert, void (^ _Nonnull startCounting)(BOOL)) {
                CBStrongSelfElseReturn
                
                if (self.payment) {
                    CBWeakSelf
                    [self showLoading];
                    [TIOChat.shareSDK.walletManager beforeRechargeMoney:self.amount agrno:self.payment.agreementNo remark:nil completion:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
                        CBStrongSelfElseReturn
                        
                        [self hideLoading];
                        
                        if (!error) {
                            startCounting(YES);
                            /// 留待确认支付时使用
                            self.beforeRechargeResult = responseObject;
                        } else {
                        }
                    }];
                }
            };
            /// 确认充值
            alert.completeHandler = ^(NWSMSPaymentALert * _Nonnull paymentALert, NSString * _Nonnull sms, void (^ _Nonnull completion)(BOOL)) {
                CBStrongSelfElseReturn
                if (self.beforeRechargeResult) {
                    // 商户订单号
                    NSString *merorderid = self.beforeRechargeResult[@"merorderid"];
                    // 预下单订单id
                    NSString *rid = self.beforeRechargeResult[@"id"];
                    
                    [self showLoading];
                    CBWeakSelf
                    [TIOChat.shareSDK.walletManager confirmRecharging:merorderid rid:rid sms:sms completion:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
                        CBStrongSelfElseReturn
                        /// 关闭支付窗
                        completion(YES);
                        
                        if (error) {
                            [self hideLoading]; // 隐藏转圈
                            self.nw_callback(nil, self.tempCode, error);
                        } else {
                            [self hideLoading]; // 隐藏转圈
                            NSString *reqid = responseObject[@"reqid"];
                            NSInteger status = [responseObject[@"status"] integerValue];
                            NSDictionary *dic = @{
                                @"result" : @(YES),
                                @"rid" : rid?:@"",
                                @"reqid" : reqid?:@"",
                                @"status" : @(status),
                                @"ordererrormsg" : responseObject[@"ordererrormsg"]?:@""
                            };
                            self.nw_callback(dic, self.tempCode, nil);
                        }
                    }];
                } else {
                    NSLog(@"验证码未获取");
                }
            };
            [alert showOnView:self.currentViewController.view];
        });
    });
}

#pragma mark - 绑定银行卡

- (void)bindNewCard:(void(^)(NSDictionary *bindResult, UIViewController *vController))completion
{
    CBWeakSelf
    /// 先去验证身份
    NWSettingPayPasswordVC *pwdVC = [NWSettingPayPasswordVC.alloc initWithTitle:@"添加银行卡" code:NWPayPasswordCodeAuthorization];
    pwdVC.handler = ^(UIViewController * _Nonnull vController, BOOL re, NSString *pwd) {
        CBStrongSelfElseReturn
        if (!re) {
            [vController.navigationController popViewControllerAnimated:YES];
        } else {
            CBWeakSelf
            /// 验证通过，去绑定页
            NWBindNewCardVC *vc = [NWBindNewCardVC.alloc init];
            __block NWBindNewCardVC *weakBindVC = vc;
            vc.completion = ^(NSDictionary * _Nonnull result) {
                CBStrongSelfElseReturn
                /// 绑卡完成
                completion(result, weakBindVC);
            };
            [vController.navigationController pushViewController:vc animated:YES];
            
            NSArray *vcs = vController.navigationController.viewControllers;
            NSArray *tempVcs = [vcs subarrayWithRange:NSMakeRange(0, vcs.count - 2)];
            NSArray *nVcs = [tempVcs arrayByAddingObject:vc];
            [vc.navigationController setViewControllers:nVcs];
        }
    };
    [self.currentViewController.navigationController pushViewController:pwdVC animated:YES];
}

#pragma mark - 有没有绑定银行卡的过滤

- (void)checkBindAnyCard:(void(^)(BOOL re))completion
{
    // 调用银行卡列表接口判断数量
    
    [self showLoading];
    [TIOChat.shareSDK.walletManager fetchBankCardList:^(NSArray * _Nullable responObject, NSError * _Nullable error) {
        [self hideLoading];
        
        if (error) {
            completion(NO);
            self.nw_callback(nil, self.tempCode, error);
        } else {
            if (responObject.count) {
                completion(YES);
            } else {
                completion(NO);
                /// 可以再次做统一跳转绑卡处理，也可在外部调用的回调中处理，
                /// 建议在此处理，因本方法已经是最低粒度
                [self bindNewCard:^(NSDictionary *bindResult, UIViewController *vController) {
                    
                }];
            }
        }
    }];
}


/// 钱包支付
- (void)showPasswordPayment:(NSString *)title bank:(NSString *)bank
{
    CBWeakSelf
    
    NWPaymentAlert *alert = [NWPaymentAlert.alloc init];
    alert.titleLabel.text = title;
    alert.securityField.securityCharacterType = SecurityCharacterTypePlainText;
    alert.money = [NSString stringWithFormat:@"%.2f",self.amount/100.f];
    alert.subLabel.attributedText = ({
        NSMutableAttributedString *attributedString = [NSMutableAttributedString.alloc init];
        [attributedString appendAttributedString:[NSAttributedString.alloc initWithString:@"支付方式：钱包" attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12], NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#333333"]}]];
        
        attributedString;
    });
    alert.inputPasswordCompleted = ^(NSDictionary * _Nonnull result, NWPaymentAlert * _Nonnull alertt, NSString *pwd) {
        CBStrongSelfElseReturn
        /// 输入完验证码之后 开始请求
        UIActivityIndicatorView *loading = [UIActivityIndicatorView.alloc initWithFrame:CGRectMake(100, 100, 100, 100)];
        loading.layer.cornerRadius = 8;
        loading.layer.masksToBounds = YES;
        loading.center = CGPointMake(CGRectGetWidth(self.currentViewController.view.frame)*0.5, CGRectGetHeight(self.currentViewController.view.frame)*0.5);
        loading.color = UIColor.whiteColor;
        loading.backgroundColor = UIColor.grayColor;
        loading.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [self.currentViewController.view addSubview:loading];
        [loading startAnimating];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [loading stopAnimating];
            [alertt dismiss:@""];
        });
        
    };
    [alert showOnView:self.currentViewController.view];
}

#pragma mark - 展示支付选择器

/// 显示支付方式的
/// @param showBalance 是否需要显示余额选项
/// @param completion 选择完某一个支付方式
- (void)showPaymentListWithShowBalance:(BOOL)showBalance completion:(void(^)(id<NWPaymentChannel> payment))completion
{
    /// 是否显示余额选项
    if (!showBalance) {
        
        [self showLoading];
        CBWeakSelf
        /// 获取卡
        [TIOChat.shareSDK.walletManager fetchBankCardList:^(NSArray * _Nullable responObject, NSError * _Nullable error) {
            CBStrongSelfElseReturn
            [self hideLoading];
            
            NSMutableArray *array = [NSMutableArray arrayWithCapacity:responObject.count];
            for (TIOBankCard *card in responObject) {
                [array addObject:[NWPaymentObject.alloc initWithModel:card]];
            }

            NWPayChannelPicker *picker = [NWPayChannelPicker.alloc init];
            CBWeakSelf
            /// 去绑定新卡 , 并且完成新卡绑定的回调
            /// 回调内可以进行数据刷新
            picker.bindNewCard = ^(NWPayChannelPicker * _Nonnull p, void (^ _Nonnull refreshData)(NSArray<id<NWPaymentChannel>> * _Nonnull)) {
                CBStrongSelfElseReturn
                CBWeakSelf
                [TIOChat.shareSDK.walletManager fetchBankCardList:^(NSArray * _Nullable responObject, NSError * _Nullable error) {
                    CBStrongSelfElseReturn
                    NSMutableArray *array = [NSMutableArray arrayWithCapacity:responObject.count];
                    for (TIOBankCard *card in responObject) {
                        [array addObject:[NWPaymentObject.alloc initWithModel:card]];
                    }
                    
                    refreshData(array);
                }];
            };
            [picker showOnView:self.currentViewController.view items:array callBack:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
                CBStrongSelfElseReturn
                self.lock = NO;
                NSLog(@"result = %@, error = %@",result, error);
                /// 发送验证码
                
                completion(result?result[@"result"]:nil);
            }];
        }];
    }
    else
    {
        /// 显示余额
        [self showLoading];
        CBWeakSelf
        [TIOChat.shareSDK.walletManager fetchPaymentList:^(NSDictionary * _Nullable responObject, NSError * _Nullable error) {
            CBStrongSelfElseReturn
            [self hideLoading];
            
            NSArray *banklist = [NWPaymentObject objectArrayWithJSONArray:responObject[@"banklist"]];
            /*
             cny = 8;
             merid = 300008795977;
             ordererrormsg = "";
             uid = 37886;
             walletid = 100011636139;
             */
            NWPaymentObject *balance = [NWPaymentObject.alloc init];
            balance.bankname = @"余额"; // 名称
            balance.iconImage = [UIImage imageNamed:@"pay_balance"];//logo
            balance.type = NWPaymentTypeBalance; // 类型余额
            balance.amount = [responObject[@"walletinfo"][@"cny"] integerValue];// 金额
            
            /// 组装数据源
            NSArray *arr = [@[balance] arrayByAddingObjectsFromArray:banklist];
            NWPayChannelPicker *picker = [NWPayChannelPicker.alloc init];
            CBWeakSelf
            /// 去绑定新卡 , 并且完成新卡绑定的回调
            /// 回调内可以进行数据刷新
            picker.bindNewCard = ^(NWPayChannelPicker * _Nonnull p, void (^ _Nonnull refreshData)(NSArray<id<NWPaymentChannel>> * _Nonnull)) {
                CBStrongSelfElseReturn
                CBWeakSelf
                [TIOChat.shareSDK.walletManager fetchPaymentList:^(NSDictionary * _Nullable responObject, NSError * _Nullable error) {
                    CBStrongSelfElseReturn
                    NSArray *banklist = [NWPaymentObject objectArrayWithJSONArray:responObject[@"banklist"]];
                    /*
                     cny = 8;
                     merid = 300008795977;
                     ordererrormsg = "";
                     uid = 37886;
                     walletid = 100011636139;
                     */
                    NWPaymentObject *balance = [NWPaymentObject.alloc init];
                    balance.bankname = @"余额"; // 名称
                    balance.iconImage = [UIImage imageNamed:@"pay_balance"];//logo
                    balance.type = NWPaymentTypeBalance; // 类型余额
                    balance.amount = [responObject[@"walletinfo"][@"cny"] integerValue];// 金额
                    
                    /// 组装数据源
                    NSArray *arr = [@[balance] arrayByAddingObjectsFromArray:banklist];
                    refreshData(arr);
                }];
//                [TIOChat.shareSDK.walletManager fetchBankCardList:^(NSArray * _Nullable responObject, NSError * _Nullable error) {
//                    CBStrongSelfElseReturn
//                    NSMutableArray *array = [NSMutableArray arrayWithCapacity:responObject.count];
//                    for (TIOBankCard *card in responObject) {
//                        [array addObject:[NWPaymentObject.alloc initWithModel:card]];
//                    }
//                    
//                    refreshData(array);
//                }];
            };
            [picker showOnView:self.currentViewController.view items:arr callBack:^(NSDictionary * _Nullable result, NSError * _Nullable error) {
                CBStrongSelfElseReturn
                self.lock = NO;
                NSLog(@"result = %@, error = %@",result, error);
                /// 发送验证码
                
                completion(result?result[@"result"]:nil);
            }];
        }];
    }
    
}


- (UIActivityIndicatorView *)activityIndicatorView
{
    if (!_activityIndicatorView) {
        UIWindow *window = UIApplication.sharedApplication.keyWindow;
        _activityIndicatorView = [UIActivityIndicatorView.alloc initWithFrame:CGRectMake(100, 100, 100, 100)];
        _activityIndicatorView.layer.cornerRadius = 8;
        _activityIndicatorView.layer.masksToBounds = YES;
        _activityIndicatorView.center = CGPointMake(CGRectGetWidth(window.frame)*0.5, CGRectGetHeight(window.frame)*0.5);
        _activityIndicatorView.color = UIColor.whiteColor;
        _activityIndicatorView.backgroundColor = UIColor.grayColor;
        _activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        _activityIndicatorView.hidden = YES;
        [window addSubview:_activityIndicatorView];
    }
    return _activityIndicatorView;
}

- (void)showLoading
{
    self.activityIndicatorView.hidden = NO;
    [self.currentViewController.view bringSubviewToFront:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];
}

- (void)hideLoading
{
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden = YES;
}

@end

//
//  WalletManager.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/11.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "WalletManager.h"
#import "WalletOpenView.h"
#import "WalletRedPackageDetailsVC.h"
#import "TWalletAuthorizationVC.h"
#import "TMineWalletViewController.h"
#import "WalletSendSingleRedPackageVC.h"
#import "WalletSendTeamRedPackageVC.h"
#import "ImportSDK.h"
#import "EHKWeboxManager.h"
#import "utils.h"
#import "MBProgressHUD+NJ.h"

#import "NWHomeViewController.h"
#import "NWAuthorizationVC.h"
#import "NWSendP2PRedPackageVC.h"
#import "NWSendTeamRedPackageVC.h"
#import "NWSettingPayPasswordVC.h"

@implementation WalletManager

+ (instancetype)shareInstance
{
    static WalletManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
        
        /// 切换易支付和新生支付
        _sharedManager.vendor = WalletVendorNewPay;
    });

    return _sharedManager;
}

- (void)openRedPackage:(NSDictionary *)params callback:(void (^)(id _Nonnull))callback
{
    TIOMessage *model = params[@"model"];
    self.sessionId = params[@"sessionId"];
    
    UIViewController *topVC = [self topViewController];
    
    if (self.vendor == WalletVendorNewPay) {
        
        /**
         *
         * 新生支付
         *
         */
        
        [MBProgressHUD showLoading:@"" toView:topVC.view];
        CBWeakSelf
        [TIOChat.shareSDK.walletManager queryRedStatusForRed:model.attachmentObjects.firstObject.rid completion:^(NSDictionary * _Nullable responObject, NSError * _Nullable error) {
            CBStrongSelfElseReturn
            [MBProgressHUD hideHUDForView:topVC.view animated:YES];
            if (error) {
                [MBProgressHUD showError:error.localizedDescription toView:topVC.view];
                return;
            }
            
            NSInteger   openflag = [responObject[@"openflag"] integerValue];
            NSString    *grabstatus = [responObject[@"grabstatus"] stringValue];
            NSString    *redstatus = [responObject[@"redstatus"] stringValue];
            
            if (openflag == 2) {
                NWAuthorizationVC *vc = [NWAuthorizationVC.alloc init];
                [[self topViewController].navigationController pushViewController:vc animated:YES];
                return;
            }
            
            /// 私聊中，自己点击自己的红包, 直接进入红包详情页
            if (model.isOutgoingMsg && model.session.sessionType == TIOSessionTypeP2P) {
                [self push_redDetailVC:model.attachmentObjects.firstObject.rid];
                
                if ([redstatus isEqualToString:@"5"]) {
                    /// 已抢完
                    model.attachmentObjects.firstObject.status = @"GRAB";
                    callback(model);
                }
            } else {
                if ([grabstatus isEqualToString:@"1"]) {
                    /// 已抢，直接进入红包详情
                    model.attachmentObjects.firstObject.status = @"GRAB";
                    callback(model);
                    [self push_redDetailVC:model.attachmentObjects.firstObject.rid];
                } else if ([grabstatus isEqualToString:@"2"]) {
                    /// 未抢，弹出抢红包弹窗
                    if ([redstatus isEqualToString:@"1"]) {
                        /// 可以抢
                        [self evokeAlert:model redstatus:WalletStatusCanGet callback:^{
                            model.attachmentObjects.firstObject.status = @"GRAB";
                            callback(model);
                        }];
                    } else if ([redstatus isEqualToString:@"5"]) {
                        /// 已抢完
                        [self evokeAlert:model redstatus:WalletStatusWasGot callback:^{
                        }];
                    } else {
                        /// 超时
                        [self evokeAlert:model redstatus:WalletStatusWasExpired callback:^{
                            
                        }];
                    }
                } else {
                    /// 异常
                }
            }
        }];
        
        return;
    }
    
    /**
     *
     * 易支付
     *
     */
    
    NSLog(@"微包version => %@",[EHKWeboxManager.instanceManager verson]);
    
    [MBProgressHUD showLoading:@"" toView:topVC.view];
    CBWeakSelf
    [TIOChat.shareSDK.walletManager checkRedStatusWithRedNumber:model.attachmentObjects.firstObject.serialnumber completion:^(NSString * _Nullable grabstatus, NSString * _Nullable redstatus, NSInteger openflag, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        [MBProgressHUD hideHUDForView:topVC.view animated:YES];
        if (error) {
            [MBProgressHUD showError:error.localizedDescription toView:topVC.view];
            
            return;
        }
        
        if (openflag == 2) {
            TWalletAuthorizationVC *vc = [TWalletAuthorizationVC.alloc init];
            [[self topViewController].navigationController pushViewController:vc animated:YES];
            return;
        }
        
        /// 私聊中，自己点击自己的红包, 直接进入红包详情页
        if (model.isOutgoingMsg && model.session.sessionType == TIOSessionTypeP2P) {
            [self push_redDetailVC:model.attachmentObjects.firstObject.serialnumber];
            
            if ([redstatus isEqualToString:@"SUCCESS"]) {
                /// 已抢完
                model.attachmentObjects.firstObject.status = @"GRAB";
                callback(model);
            }
        } else {
            if ([grabstatus isEqualToString:@"SUCCESS"]) {
                /// 已抢，直接进入红包详情
                model.attachmentObjects.firstObject.status = @"GRAB";
                callback(model);
                [self push_redDetailVC:model.attachmentObjects.firstObject.serialnumber];
            } else if ([grabstatus isEqualToString:@"INIT"]) {
                /// 未抢，弹出抢红包弹窗
                if ([redstatus isEqualToString:@"SEND"]) {
                    /// 可以抢
                    [self evokeAlert:model redstatus:WalletStatusCanGet callback:^{
                        model.attachmentObjects.firstObject.status = @"GRAB";
                        callback(model);
                    }];
                } else if ([redstatus isEqualToString:@"SUCCESS"]) {
                    /// 已抢完
                    [self evokeAlert:model redstatus:WalletStatusWasGot callback:^{
                    }];
                } else {
                    /// 超时
                    [self evokeAlert:model redstatus:WalletStatusWasExpired callback:^{
                        
                    }];
                }
            } else {
                /// 异常
            }
        }
    }];
}


/// 开户
- (void)evokeOpenAccount:(NSDictionary *)params callback:(void (^)(id _Nonnull))callback
{
    [MBProgressHUD showLoading:@"" toView:[self topViewController].view];
    /// 1、检测是否开户
    CBWeakSelf
    [TIOChat.shareSDK.walletManager checkOpenAccountStatus:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        [MBProgressHUD hideHUDForView:[self topViewController].view animated:YES];
        NSInteger openflag = [responseObject[@"openflag"] integerValue];
        NSString *uid  = responseObject[@"uid"];
        // test - 要改为2
        if (openflag == 2) {
            /// 未开户
            if (self.vendor == WalletVendorNewPay) {
                NWAuthorizationVC *vc = [NWAuthorizationVC.alloc init];
                [[self topViewController].navigationController pushViewController:vc animated:YES];
                return;
            } else {
                TWalletAuthorizationVC *vc = [TWalletAuthorizationVC.alloc init];
                [[self topViewController].navigationController pushViewController:vc animated:YES];
            }
        } else {
            /// 已开户
            NSString *walletid = responseObject[@"walletid"];
            TIOChat.shareSDK.loginManager.userInfo.walletid = walletid;
            
            if (self.vendor == WalletVendorNewPay) {
                NSInteger paypwdflag = [responseObject[@"paypwdflag"] integerValue];
                if (paypwdflag == 1) {
                    /// 已经设置支付密码 进入钱包主页
                    NWHomeViewController *vc = [NWHomeViewController.alloc init];
                    [[self topViewController].navigationController pushViewController:vc animated:YES];
                } else {
                    /// 未设置支付密码 强制跳转支付密码设置页
                    NWSettingPayPasswordVC *vc = [NWSettingPayPasswordVC.alloc initWithTitle:@"设置支付密码" code:NWPayPasswordCodeCreate];
                    CBWeakSelf
                    vc.handler = ^(UIViewController * _Nonnull vController, BOOL re, NSString *pwd) {
                        CBStrongSelfElseReturn
                        /// 表示身份验证结果
                        if (re) {
                            /// 先push钱包主页
                            NWHomeViewController *vc = [NWHomeViewController.alloc init];
                            [[self topViewController].navigationController pushViewController:vc animated:YES];
                            
                            /// 重设钱包主页的返回栈     跳过密码设置页
                            NSArray *tempVCs = [vc.navigationController.viewControllers subarrayWithRange:NSMakeRange(0, vc.navigationController.viewControllers.count-2)];
                            /// 个人中心页 + 钱包主页。保证钱包主页返回是个人中心页
                            [vc.navigationController setViewControllers:[tempVCs arrayByAddingObject:vc]];
                        }
                    };
                    [[self topViewController].navigationController pushViewController:vc animated:YES];
                }
            } else {
             
                /// 检查钱包信息
                CBWeakSelf
                [TIOChat.shareSDK.walletManager fetchWalletDetailWithUid:uid walletid:walletid completion:^(TIOWallet * _Nullable wallet, NSError * _Nullable error) {
                    CBStrongSelfElseReturn
                    if (!error) {
                        if (!wallet.setUpPasswrod) {
                            /// 没有设置初始密码
                            /// 唤起微包
                            [self evokeSafe:wallet uid:uid];
                        } else {
                            /// 已经设置初始密码
                            TMineWalletViewController *vc = [TMineWalletViewController.alloc init];
                            vc.uid = uid;
                            vc.walletid = walletid;
                            [[self topViewController].navigationController pushViewController:vc animated:YES];
                        }
                    }
                }];
            }
        }
    }];
}

- (void)evokeSendRedViewController:(NSDictionary *)params
{
    UIViewController *currentVC = params[@"currentVC"];
    id object = params[@"user"];
    NSString *sessionId = params[@"sessionId"];
    
    if ([object isKindOfClass:TIOUser.class]) {
        TIOUser *user = object;
        if (self.vendor == WalletVendorNewPay) {
            NWSendP2PRedPackageVC *vc = [NWSendP2PRedPackageVC.alloc initWithFriend:user sessionId:sessionId];
            [currentVC.navigationController pushViewController:vc animated:YES];
        } else {
            WalletSendSingleRedPackageVC *vc = [WalletSendSingleRedPackageVC.alloc initWithFriend:user sessionId:sessionId];
            [currentVC.navigationController pushViewController:vc animated:YES];
        }
    } else if ([object isKindOfClass:TIOTeam.class]) {
        TIOTeam *team = object;
        if (self.vendor == WalletVendorNewPay) {
            NWSendTeamRedPackageVC *vc = [NWSendTeamRedPackageVC.alloc init];
            vc.team = team;
            vc.sessionId = sessionId;
            [currentVC.navigationController pushViewController:vc animated:YES];
        } else {
            WalletSendTeamRedPackageVC *vc = [WalletSendTeamRedPackageVC.alloc init];
            vc.team = team;
            vc.sessionId = sessionId;
            [currentVC.navigationController pushViewController:vc animated:YES];
        }
    }
    
}

#pragma mark - private

- (void)push_redDetailVC:(NSString *)serialNumber
{
    UIViewController *topVC = [self topViewController];
    WalletRedPackageDetailsVC *vc = [WalletRedPackageDetailsVC.alloc init];
    vc.serialNumber = serialNumber;
    [topVC.navigationController pushViewController:vc animated:YES];
}

- (void)evokeAlert:(TIOMessage *)model redstatus:(WalletStatus)redstatus callback:(void(^)(void))callback
{
    NSString *remark = model.attachmentObjects.firstObject.text?:@"恭喜发财，吉祥如意";
    UIViewController *topVC = [self topViewController];
    WalletOpenView *openView = [WalletOpenView.alloc initWithFrame:topVC.view.bounds Type:redstatus isSelf:model.isOutgoingMsg avatar:model.avatar nick:model.from remark:remark];
    CBWeakSelf
    /// 开红包
    openView.openBlock = ^(id  _Nonnull data) {
        CBStrongSelfElseReturn
        
        
        if (self.vendor == WalletVendorYiPay) {
            
            /// 易支付
            
            CBWeakSelf
            NSString *serialnumber = model.attachmentObjects.firstObject.serialnumber;
            [TIOChat.shareSDK.walletManager grabRedpackageWithRedNumber:serialnumber?:@"" sessionId:self.sessionId uid:nil walletid:nil completion:^(TIOGrabRedPackage * _Nullable grabRedPackage, NSError * _Nullable error) {
                CBStrongSelfElseReturn
                if (!error) {
                    [self push_redDetailVC:serialnumber];
                    callback();
                } else {
                    [MBProgressHUD showError:error.localizedDescription toView:topVC.view];
                }
            }];
        } else {
            
            /// 新生支付
            
            CBWeakSelf
            NSString    *rid = model.attachmentObjects.firstObject.rid;
            [TIOChat.shareSDK.walletManager grabRed:rid chatlinkid:self.sessionId completion:^(TIOGrabRedPackage * _Nullable grabRedPackage, NSError * _Nullable error) {
                CBStrongSelfElseReturn
                if (!error) {
                    [self push_redDetailVC:rid];
                    callback();
                } else {
                    [MBProgressHUD showError:error.localizedDescription toView:topVC.view];
                }
            }];
        }
        
    };
    /// 发红包的人查看其他人抢的结果，直接跳到红包详情页
    openView.seeOthersBlock = ^(id  _Nonnull data) {
        CBStrongSelfElseReturn
        if (self.vendor == WalletVendorYiPay) {
            [self push_redDetailVC:model.attachmentObjects.firstObject.serialnumber];
        } else {
            [self push_redDetailVC:model.attachmentObjects.firstObject.rid];
        }
    };
    [[self topViewController].view addSubview:openView];
}

- (void)evokeSafe:(TIOWallet *)wallet uid:(NSString *)uid
{
    [TIOChat.shareSDK.walletManager fetchSafeTokenWithUid:uid walletid:wallet.walletId completion:^(NSDictionary * _Nullable responseObject, NSError * _Nullable error) {
        NSString *token = responseObject[@"token"];
        [self evoke_safe:token walletid:wallet.walletId];
    }];
}

-(void)evoke_safe:(NSString *)token walletid:(NSString *)walletid {
    CBWeakSelf
    EHKWeboxManager * wallet = [EHKWeboxManager instanceManager];
    [utils configuration:wallet walletid:walletid token:token businessCode:EHKWEBOX_BUSINESSCODE_SETTING vc:[self topViewController]];

    BOOL hideNavigationBar = [self topViewController].navigationController.isNavigationBarHidden;
    
    [wallet evoke:^(EHKWeboxManager * _Nonnull wallet, EHKWeboxStatus status) {
        [self topViewController].navigationController.navigationBarHidden = hideNavigationBar;
        CBStrongSelfElseReturn
        /// 重新获取钱包信息，查看是否完成密码设置，是的话，进入钱包主页
        [self handler:wallet.walletId];
    }];
}

- (void)handler:(NSString *)walletid
{
    NSString *uid = TIOChat.shareSDK.loginManager.userInfo.userId;
    CBWeakSelf
    [TIOChat.shareSDK.walletManager fetchWalletDetailWithUid:uid walletid:walletid completion:^(TIOWallet * _Nullable wallet, NSError * _Nullable error) {
        CBStrongSelfElseReturn
        if (!error) {
            if (wallet.setUpPasswrod) {
                /// 已经设置初始密码
                /// 进入下一页：钱包主页
                TMineWalletViewController *nextVC = [TMineWalletViewController.alloc init];
                nextVC.uid = uid;
                nextVC.walletid = walletid;
                [[self topViewController].navigationController pushViewController:nextVC animated:YES];
            }
        }
    }];
}

- (UIViewController*)topVC:(UIViewController*)VC {

    if([VC isKindOfClass:[UINavigationController class]]) {

        return[self topVC:[(UINavigationController*)VC topViewController]];

    }

    if([VC isKindOfClass:[UITabBarController class]]) {

        return[self topVC:[(UITabBarController*)VC selectedViewController]];

    }

    return VC;

}

 

- (UIViewController*)topViewController {

    UIViewController*vc = [self topVC:[UIApplication sharedApplication].keyWindow.rootViewController];

    while(vc.presentedViewController) {

        vc = [self topVC:vc];

    }

    return vc;

}

@end

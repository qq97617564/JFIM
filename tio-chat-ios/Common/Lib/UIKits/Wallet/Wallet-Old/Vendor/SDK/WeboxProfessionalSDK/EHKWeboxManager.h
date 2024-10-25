//
//  EHKWeboxManager.h
//  EHKWebox
//
//  Created by pill on 2019/11/12.
//  Copyright © 2019 EHK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EHKConfigurationEnum.h"

@class EHKWeboxManager;

/**
 * 回调结果类型
 */
typedef NS_ENUM(NSInteger, EHKWeboxStatus) {
    EHKWEBOX_STASTUS_NONE = 1,
    EHKWEBOX_STASTUS_PROCESS, // 操作进行中（一般只在支付中产生，没有支付进行中操作）
    EHKWEBOX_STASTUS_SUCCESS, //操作成功 （一般只在支付中产生，支付成功）
    EHKWEBOX_STASTUS_FAILURE, //操作失败 （一般只在支付中产生，支付失败，具体原因请查看errorMessage）
    EHKWEBOX_STASTUS_CANCEL, //操作取消
};

typedef void(^EPCallBack)(EHKWeboxManager * _Nonnull wallet,  EHKWeboxStatus status);

typedef NS_ENUM(NSInteger, EHKWEBOX_BUSINESSCODE) {
    EHKWEBOX_BUSINESSCODE_NONE,
    EHKWEBOX_BUSINESSCODE_BANK = 1,//银行卡列表
    EHKWEBOX_BUSINESSCODE_SETTING ,//设置
    EHKWEBOX_BUSINESSCODE_REDPACKAGE ,//红包
    EHKWEBOX_BUSINESSCODE_WITHDRAW ,//提现
    EHKWEBOX_BUSINESSCODE_TRANSFER,//转账
    EHKWEBOX_BUSINESSCODE_RECHARGE,//充值
    EHKWEBOX_BUSINESSCODE_ORDER,//订单支付
    EHKWEBOX_BUSINESSCODE_VALIDATE_PASSWORD,//密码确认
    EHKWEBOX_BUSINESSCODE_APP_PAY,//境内收单-微包app支付
    EHKWEBOX_BUSINESSCODE_MANUAL_CHECK_CER,//手动检测是否安装证书
    EHKWEBOX_BUSINESSCODE_AUTO_CHECK_CER//自动检测是否安装证书
};

NS_ASSUME_NONNULL_BEGIN

@interface EHKWeboxManager : NSObject

/**
* 是否开启debug模式
*/
@property (nonatomic, assign) BOOL isOpenDebug;

#pragma mark - style

/**
 * 按钮颜色值设置
 */
@property (nonatomic,copy) UIColor * themeButtonTitleColor;

/**
 * 基本主题颜色设置
 */
@property (nonatomic,copy) UIColor * themeButtonColor;

/**
 * 导航栏标题颜色设置
 */
@property (nonatomic,copy) UIColor * themeNavigationTitleColor;

/**
 * 导航栏颜色设置
 */
@property (nonatomic,copy) UIColor * themeNavigationColor;

#pragma mark - request
/**
 * 钱包id
 */
@property (nonatomic,copy) NSString * walletId;

/**
 * 商户id
 */
@property (nonatomic,copy) NSString * merchantId;

/**
 * 授权token
 */
@property (nonatomic,copy) NSString * token;

/**
 * 操作码
 */
@property (nonatomic,assign ) EHKWEBOX_BUSINESSCODE businessCode;

/**
 * 导航控制器
 */
@property (nonatomic,strong) UINavigationController * navigation;

/**
 * 安全键盘配置  默认乱序
 */
@property (nonatomic,assign) EHKWeboxSafeKeyboardType isRandomKeyboard;

/**
 * 当应用是支持tabbar 并且第二个页面要跳转SDK 的时候请设置这个属性为 YES
 *
 * 该功能目的 当你设置这个属性为YES的时候会在页面跳转到时候设置 vc.hidesBottomBarWhenPushed = YES;
 *
 * 如果不变化，则不执行这个操作
 *
 * tabbar 控制开关 由于sdk 设计到了页面跳转，tabar 有的需要会要求隐藏该功能，如果需要隐藏的话设置成YES
 */
@property (nonatomic,assign) BOOL hidesBottomBarWhenPushed;

/**
* 是否开启手势交互
*/
@property (nonatomic,assign) BOOL isOpenGestureRecognition;

#pragma mark - init
/**
 * 单例
 */
+ (id)instanceManager;

/**
 * 删除证书
 */
- (BOOL)deleteCer:(NSString *)walletId;

#pragma mark - callback
/**
 * 操作发起方法
 */
- (void)evoke:(EPCallBack )result;

/**
 * 如果报错可以在这里看到具体错误信息
 */
@property (nonatomic,copy) NSString * errorMessage;

/**
 * 回调信息
 */
@property (nonatomic,copy) EPCallBack  callback;

/**
 * 手动完全释放微包SDK
 */
-(void)freed;

/**
 * 取消支付
 */
- (void)cancelPay;

/**
 * 当前版本
 */
@property (nonnull,copy,readonly) NSString * verson;

#pragma mark - invalid method (过期方法)或者不可用
/**
 * 当前配置方式，已经移交后端进行配置，手机端配置无效
 *
 * 设置支付方式，默认不设置，none
 */
@property (nonatomic,assign) EHKWeboxPayType payType NS_UNAVAILABLE;

/**
 * 键盘遮挡，页面遮挡适配设置默认为YES，，建议使用 IQKeyboardManager 稳定（设置成NO）
 *
 * 键盘遮挡， 默认值为 NO ，建议使用 IQKeyboardManager 稳定（设置成NO）  如果设置YES的话可以简单的适配键盘弹出的情况
 *
 * 当前方法已经失效，请使用IQKeyboardManager 来适配textFied 高度问题
 */
@property (nonatomic,assign) BOOL autoKeyBoard NS_UNAVAILABLE;

/**
 * 收银台页面标题显示文字，只能在订单支付中生效，此方法已作废
 */
@property (nonatomic,assign) EHKWeboxSafeKeyboardType showTitle NS_UNAVAILABLE;

/**
 * 没有遵循协议可以不写
 */
- (id)copy NS_UNAVAILABLE;

/**
 * 没有遵循协议可以不写
 */
- (id)mutableCopy NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END

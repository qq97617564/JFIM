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

@class EHKValueAddServiceManager;

/**
 * 回调结果类型
 */
typedef NS_ENUM(NSInteger, EHKValueAddServiceStatus) {
    EHKVALUEADDSERVICE_STASTUS_NONE = 1,
    EHKVALUEADDSERVICE_STASTUS_FAILURE ,//操作失败
    EHKVALUEADDSERVICE_STASTUS_CANCEL ,//操作取消
};

typedef void(^EHKValueAddServiceCallBack)(EHKValueAddServiceManager * _Nonnull  wallet,  EHKValueAddServiceStatus status);

typedef NS_ENUM(NSInteger, EHKVALUEADDSERVICE_BUSINESSCODE) {
    EHKVALUEADDSERVICE_BUSINESSCODE_NONE,
    EHKVALUEADDSERVICE_BUSINESSCODE_VALUE_ADDED = 1,//增值服务
};

NS_ASSUME_NONNULL_BEGIN

@interface EHKValueAddServiceManager : NSObject

#pragma mark - style

/**
* 是否开启debug模式
*/
@property (nonatomic, assign) BOOL isOpenDebug;

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
@property (nonatomic,assign ) EHKVALUEADDSERVICE_BUSINESSCODE businessCode;

/**
 * 导航控制器
 */
@property (nonatomic,strong) UINavigationController * navigation;

#pragma mark - Configuration

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

#pragma mark - callback
/**
 * 操作发起方法
 */
- (void)evoke:(EHKValueAddServiceCallBack )result;

/**
 * 如果报错可以在这里看到具体错误信息
 */
@property (nonatomic,copy) NSString * errorMessage;

/**
 * 回调信息
 */
@property (nonatomic,copy) EHKValueAddServiceCallBack  callback;

/**
 * 手动完全释放微包SDK
 */
-(void)freed;

/**
 * 当前版本
 */
@property (nonnull,copy,readonly) NSString * version;

@end

NS_ASSUME_NONNULL_END

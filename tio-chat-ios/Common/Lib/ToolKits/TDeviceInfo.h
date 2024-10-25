//
//  TDeviceInfo.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/10/22.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TDeviceInfo : NSObject

/** 设备信息 iphone 6s*/
+ (NSString *)deviceModel;

/** IMEI */
+ (NSString *)IMEI;

/** 分辨率 */
+ (NSString *)resolution;

/** 尺寸 */
+ (NSString *)size;

/** 移动运营商 */
+ (NSString *)mobileOperator;

/// 操作系统
+ (NSString *)sys;

@end

NS_ASSUME_NONNULL_END

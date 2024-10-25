//
//  UIDevice+CBExtension.h
//  CawBar
//
//  Created by 刘宇 on 2017/10/16.
//

#import <UIKit/UIKit.h>

@interface UIDevice (CBExtension)

/** 设备信息 iphone 6s*/
- (NSString *)deviceModel;

/** IMEI */
- (NSString *)IMEI;

/** 分辨率 */
- (NSString *)resolution;

/** 尺寸 */
- (NSString *)size;

/** 移动运营商 */
- (NSString *)mobileOperator;

@end

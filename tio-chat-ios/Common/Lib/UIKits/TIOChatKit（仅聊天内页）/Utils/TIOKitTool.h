//
//  IMKitTool.h
//  CawBar
//
//  Created by admin on 2019/11/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIOKitTool : NSObject

/// 从资源文件读取图片
/// @param imageName 图片名
+ (nullable UIImage *)imkit_imageName:(NSString *)imageName;

+ (UIWindow *)keyWindow;

+ (NSString *)showTime:(NSTimeInterval)msglastTime showDetail:(BOOL)showDetail;

+ (NSInteger)timeSwitchTimestamp:(NSString *)formatTime;

/// 文件大小带单位转换 1024B --> 1KB  （1024*1024）B--> 1M
/// @param size 字节大小
+ (NSString *)fileSize:(long long)size;

+ (NSString *)timestrampToTimeLengthFomat:(NSTimeInterval)haosecond;

+ (NSString *)timeStringWithSecond:(NSTimeInterval)second;

@end

NS_ASSUME_NONNULL_END

//
//  WaterMarkTool.h
//  WaterMark
//
//  Created by 刘宇 on 2021/2/22.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WaterMarkTool : NSObject

/// 添加水印到图片上
/// @param waterText 水印内容，富文本形式
/// @param originImage 原始图片，水印载体
/// @param rotation 水印内容的倾斜弧度 。默认不倾斜，水平
/// @param horizontalSpacing 水印水平间距 ，阅读方向为水平方向
/// @param verticalSpacing 水印垂直方向间距，每一行水印的间隔位竖直方向
+ (UIImage *)addWatermark:(NSMutableAttributedString *)waterText
            toOriginImage:(UIImage *)originImage
        withRotationAngle:(CGFloat)rotation
        horizontalSpacing:(CGFloat)horizontalSpacing
          verticalSpacing:(CGFloat)verticalSpacing;

/// 使用默认配置添加水印
/// @param text 水印内容
/// @param onImage 附着的载体图片
+ (UIImage *)addWatermark:(NSString *)text toOriginImage:(UIImage *)onImage;

@end

NS_ASSUME_NONNULL_END

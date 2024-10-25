//
//  QRCodeImage.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/12/8.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface QRCodeImage : NSObject

/// 根据字符串生成二维码
/// @param infor 字符串信息
/// @param width 宽度
+ (UIImage *)QRImageWithString:(NSString *)infor size:(CGFloat)width logo:(UIImage  * _Nullable)logo;

/// 根据字典生成二维码
/// @param infor 字典
/// @param width 宽度
+ (UIImage *)QRImageWithDictonary:(NSDictionary *)infor size:(CGFloat)width logo:(UIImage * _Nullable)logo;

+ (UIImage *)QRImageWithData:(NSData *)infor
                        size:(CGFloat)width
                   codeColor:(UIColor *)codeColor
                        logo:(UIImage * _Nullable)logo
              logoBoderColor:(UIColor *)logoBoderColor
              logoBoderWidth:(CGFloat)logoBoderWidth
                    logoSize:(CGSize)logoSize
                   maskImage:(UIImage * _Nullable)maskImage;

@end

NS_ASSUME_NONNULL_END

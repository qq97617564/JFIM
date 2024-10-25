//
//  UIImage+T_gzip.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/23.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (T_gzip)

/// 压缩成NSData
/// @param toSize 目标尺寸
/// @param scale 控制压缩速度 0～1
- (NSData *)compressImageToSize:(NSInteger)toSize scale:(CGFloat)scale;

/// 根据扩展名返回icon
/// @param ext 扩展名
+ (UIImage *)fileIconWithExt:(NSString *)ext;

@end

NS_ASSUME_NONNULL_END

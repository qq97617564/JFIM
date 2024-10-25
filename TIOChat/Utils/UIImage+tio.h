//
//  UIImage+tio.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/3/4.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (tio)

- (UIImage *)image_compressToByte:(NSUInteger)maxLength;
- (NSData *)data_compressToByte:(NSUInteger)maxLength;

@end

NS_ASSUME_NONNULL_END

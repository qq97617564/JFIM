//
//  NSString+T_Attribute.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/10.
//  Copyright © 2020 刘宇. All rights reserved.
//


#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (T_Attribute)

- (NSMutableAttributedString *)regularKey:(NSString *)key keyAttributes:(NSDictionary *)keyAttributes normalAttributes:(NSDictionary *)normalAttributes;

@end

NS_ASSUME_NONNULL_END

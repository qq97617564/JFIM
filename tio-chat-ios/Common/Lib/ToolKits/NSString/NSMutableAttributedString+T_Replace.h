//
//  NSMutableAttributedString+T_Replace.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/10.
//  Copyright © 2020 刘宇. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TAttributedString : NSObject

/// 要替换的字符串
@property (copy, nonatomic) NSString *text;
/// 属性集合
@property (strong, nonatomic) NSDictionary *attributes;

@end

@interface NSMutableAttributedString (T_Replace)


/// 替换指定字符串属性
/// @param strings 要替换的字符串
- (NSMutableAttributedString *)replaceAttributesWithStrings:(NSArray *)strings;

@end

NS_ASSUME_NONNULL_END

//
//  NSMutableAttributedString+T_Replace.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/10.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "NSMutableAttributedString+T_Replace.h"

@implementation TAttributedString

@end

@implementation NSMutableAttributedString (T_Replace)

- (NSMutableAttributedString *)replaceAttributesWithStrings:(NSArray<TAttributedString *> *)strings
{
    [strings enumerateObjectsUsingBlock:^(TAttributedString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self replaceAttributes:obj.attributes forText:obj.text];
    }];
    
    return self;
}

- (NSMutableAttributedString *)replaceAttributes:(NSDictionary *)attributes forText:(NSString *)text
{
    NSString *originString = [self string];
    // 正则
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:text options:NSRegularExpressionCaseInsensitive error:nil];
    // 取出range
    NSArray *matches = [reg matchesInString:originString options:0 range:NSMakeRange(0,originString.length)];
    // 设置富文本
    for(NSTextCheckingResult *result in [matches objectEnumerator]) {
        NSRange range = [result range];
        [self addAttributes:attributes range:range];
    }
    
    return self;
}

@end

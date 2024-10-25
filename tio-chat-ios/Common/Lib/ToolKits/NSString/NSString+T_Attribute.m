//
//  NSString+T_Attribute.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/10.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "NSString+T_Attribute.h"

@implementation NSString (T_Attribute)

- (NSMutableAttributedString *)regularKey:(NSString *)key keyAttributes:(nonnull NSDictionary *)keyAttributes normalAttributes:(nonnull NSDictionary *)normalAttributes
{
    NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc] initWithString:self];
    [attriStr addAttributes:normalAttributes range:NSMakeRange(0,self.length)];
    
    // 正则
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:key options:NSRegularExpressionCaseInsensitive error:nil];
    // 取出range
    NSArray *matches = [reg matchesInString:self options:0 range:NSMakeRange(0,self.length)];
    // 设置富文本
    for(NSTextCheckingResult *result in [matches objectEnumerator]) {
        NSRange range = [result range];
        [attriStr addAttributes:keyAttributes range:range];
    }
    
    return attriStr;
}

@end

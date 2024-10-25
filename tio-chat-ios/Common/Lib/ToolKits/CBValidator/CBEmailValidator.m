//
//  CBEmailValidator.m
//  CawBar
//
//  Created by 刘宇 on 2017/10/17.
//

#import "CBEmailValidator.h"

@implementation CBEmailValidator

+ (BOOL)validateText:(NSString *)text error:(NSError **)error
{
    if (!text.length) {
        *error = [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier code:1000 userInfo:@{NSLocalizedDescriptionKey: @"邮箱不能为空。"}];
        return NO;
    }
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    BOOL match = [predicate evaluateWithObject:text];
    if (!match) {
        *error = [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier code:1000 userInfo:@{NSLocalizedDescriptionKey: @"请输入有效的邮箱地址。"}];
        return NO;
    }
    return YES;
}

@end

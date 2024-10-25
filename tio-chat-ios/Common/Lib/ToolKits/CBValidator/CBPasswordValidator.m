//
//  CBPasswordValidator.m
//  CawBar
//
//  Created by 刘宇 on 2017/10/17.
//

#import "CBPasswordValidator.h"

@implementation CBPasswordValidator

+ (BOOL)validateText:(NSString *)text error:(NSError **)error
{
    if (!text.length) {
        *error = [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier code:1000 userInfo:@{NSLocalizedDescriptionKey: @"密码不能为空。"}];
        return NO;
    }
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString * regex = @"^[0-9A-Za-z]{6,20}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL match = [pred evaluateWithObject:text];
    if (!match) {
        *error = [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier code:1000 userInfo:@{NSLocalizedDescriptionKey: @"请输入6～18位有效密码。"}];
        return NO;
    }
    return YES;
}

@end

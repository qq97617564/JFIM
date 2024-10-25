//
//  CBIDCardValidator.m
//  CawBar
//
//  Created by admin on 2017/12/18.
//

#import "CBIDCardValidator.h"

@implementation CBIDCardValidator

+ (BOOL)validateText:(NSString *)text error:(NSError *__autoreleasing *)error
{
    if (!text.length) {
        *error = [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier code:1000 userInfo:@{NSLocalizedDescriptionKey: @"身份证号码不能为空。"}];
        return NO;
    }
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (text.length != 18) {
        *error = [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier code:1000 userInfo:@{NSLocalizedDescriptionKey: @"请输入18位身份证号码。"}];
        return NO;
    }
    NSString * regex = @"^[1-9]\\d{5}(18|19|([23]\\d))\\d{2}((0[1-9])|(10|11|12))(([0-2][1-9])|10|20|30|31)\\d{3}[0-9Xx]$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL match = [pred evaluateWithObject:text];
    if (!match) {
        *error = [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier code:1000 userInfo:@{NSLocalizedDescriptionKey: @"请输入18位有效身份证号码。"}];
        return NO;
    }
    return YES;
}

@end

//
//  CBMobileValidator.m
//  CawBar
//
//  Created by 刘宇 on 2017/10/17.
//

#import "CBMobileValidator.h"

@implementation CBMobileValidator

+ (BOOL)validateText:(NSString *)text error:(NSError **)error
{
    if (!text.length) {
        *error = [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier code:1000 userInfo:@{NSLocalizedDescriptionKey: @"手机号码不能为空。"}];
        return NO;
    }
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (text.length != 11) {
        *error = [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier code:1000 userInfo:@{NSLocalizedDescriptionKey: @"请输入11位手机号。"}];
        return NO;
    }
    
    /**
     * 规则 -- 更新日期 2017-03-30
     * 手机号码: 13[0-9], 14[5,7,9], 15[0, 1, 2, 3, 5, 6, 7, 8, 9], 17[0, 1, 6, 7, 8], 18[0-9]
     * 移动号段: 134,135,136,137,138,139,147,150,151,152,157,158,159,170,178,182,183,184,187,188
     * 联通号段: 130,131,132,145,155,156,170,171,175,176,185,186
     * 电信号段: 133,149,153,170,173,177,180,181,189
     *
     * [数据卡]: 14号段以前为上网卡专属号段，如中国联通的是145，中国移动的是147,中国电信的是149等等。
     * [虚拟运营商]: 170[1700/1701/1702(电信)、1703/1705/1706(移动)、1704/1707/1708/1709(联通)]、171（联通）
     * [卫星通信]: 1349
     */
    
    /**
     * 中国移动：China Mobile
     * 134,135,136,137,138,139,147(数据卡),150,151,152,157,158,159,170[5],178,182,183,184,187,188,198,199,166
     */
//    NSString *CM_NUM = @"^((13[4-9])|(147)|(15[0-2,7-9])|(17[8])|(18[2-4,7-8])|(19[8-9])|(166))\\d{8}|(170[5])\\d{7}$";
    NSString *CM_NUM = @"^(1[3-9])\\d{9}$";
    
    /**
     * 中国联通：China Unicom
     * 130,131,132,145(数据卡),155,156,170[4,7-9],171,175,176,185,186
     */
    NSString *CU_NUM = @"^((13[0-2])|(145)|(15[5-6])|(17[156])|(18[5,6]))\\d{8}|(170[4,7-9])\\d{7}$";
    
    /**
     * 中国电信：China Telecom
     * 133,149(数据卡),153,170[0-2],173,177,180,181,189
     */
    NSString *CT_NUM = @"^((133)|(149)|(153)|(17[3,7])|(18[0,1,9]))\\d{8}|(170[0-2])\\d{7}$";
    
    NSPredicate *pred_CM = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CM_NUM];
    NSPredicate *pred_CU = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CU_NUM];
    NSPredicate *pred_CT = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",CT_NUM];
    BOOL isMatch_CM = [pred_CM evaluateWithObject:text];
    BOOL isMatch_CU = [pred_CU evaluateWithObject:text];
    BOOL isMatch_CT = [pred_CT evaluateWithObject:text];
    if (!isMatch_CM && !isMatch_CT && !isMatch_CU) {
        *error = [NSError errorWithDomain:NSBundle.mainBundle.bundleIdentifier code:1000 userInfo:@{NSLocalizedDescriptionKey: @"手机号格式错误"}];
        return NO;
    }
    
    return YES;
}

@end

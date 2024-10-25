//
//  utils.m
//  EHKWeboxDemo
//
//  Created by pill on 2019/11/22.
//  Copyright © 2019 EHK. All rights reserved.
//

#import "utils.h"

@implementation utils

+ (UIColor *)getNavColor {
    NSString *colorStr = [[NSUserDefaults standardUserDefaults] objectForKey:@"_colorView.textDetail.text"];
    if ([colorStr isEqualToString:@"红色"]) {
        return [UIColor redColor];
    } else if ([colorStr isEqualToString:@"蓝色"]) {
        return [UIColor blueColor];
    }
    return [UIColor whiteColor];
}

+(NSString *)getSymbol:(NSString * )type {
    NSString * typeStr = @"";
    if ([type isEqualToString:@"DECREASE"] ) {
        typeStr = @"-";
    } else if ([type isEqualToString:@"INCREASE"] ) {
        typeStr = @"+";
    }
    return typeStr;
}
+(NSString *)getOrderName:(NSString * )type  {
    NSString * typeStr = @"";
    if ([type isEqualToString:@"WEBOX_RECHARGE"] ) {
        typeStr = @"充值";
    } else if ([type isEqualToString:@"WEBOX_REDPACKET"] ) {
        typeStr = @"红包";
    } else if ([type isEqualToString:@"WEBOX_TRANSFER"] ) {
        typeStr = @"转账";
    } else if ([type isEqualToString:@"WEBOX_WITHHOLDING"] ) {
        typeStr = @"提现";
    } else if ([type isEqualToString:@"WEBOX_REDPACKET_REFUND"] ) {
        typeStr = @"红包退款";
    } else if ([type isEqualToString:@"WEBOX_TRANSFER_REFUND"] ) {
        typeStr = @"转账退款";
    } else if ([type isEqualToString:@"WEBOX_ONLINEPAY"] ) {
        typeStr = @"订单支付";
    } else if ([type isEqualToString:@"WEBOX_ONLINEPAY_REFUND"] ) {
        typeStr = @"订单退款";
    }
    return typeStr;
}

+(void)configuration:(EHKWeboxManager * )wallet walletid:(nonnull NSString *)walletid token:(nonnull NSString *)token businessCode:(EHKWEBOX_BUSINESSCODE)businessCode vc:(nonnull UIViewController *)sender{
    wallet.walletId = walletid;
    wallet.token = token;
    wallet.themeNavigationColor = UIColor.whiteColor;
    wallet.themeButtonColor = [UIColor colorWithHex:0x4C94FF];
    wallet.themeButtonTitleColor = UIColor.whiteColor;
    wallet.themeNavigationTitleColor = [UIColor colorWithHex:0x333333];
    wallet.merchantId = @"";
    wallet.businessCode = businessCode;
    wallet.navigation = sender.navigationController;
    wallet.hidesBottomBarWhenPushed = YES;
}

@end

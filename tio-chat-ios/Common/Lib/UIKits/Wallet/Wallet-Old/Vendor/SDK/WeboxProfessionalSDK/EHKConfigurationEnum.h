//
//  EHKConfigurationEnum.h
//  EHKWebox
//
//  Created by pill on 2020/3/4.
//  Copyright © 2020 EHK. All rights reserved.
//

#ifndef EHKConfigurationEnum_h
#define EHKConfigurationEnum_h
//安全键盘设置是
typedef NS_ENUM(NSInteger, EHKWeboxSafeKeyboardType) {
    EHKWEBOX_SAFEKEYBOARD_NONE = 1,
    EHKWEBOX_SAFEKEYBOARD_SEQUENCE,  // 安全键盘顺序
    EHKWEBOX_SAFEKEYBOARD_RANDOM , // 安全键盘乱序
};

typedef NS_ENUM(NSInteger, EHKWeboxPayType) {
    EHKWEBOX_PAY_NONE = 1,
    EHKWEBOX_PAY_ONLYBALANCE,  // 只支持余额支付
};



#endif /* EHKConfigurationEnum_h */

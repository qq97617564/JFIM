//
//  WalletDefines.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/11.
//  Copyright © 2020 刘宇. All rights reserved.
//

#ifndef WalletDefines_h
#define WalletDefines_h

typedef NS_ENUM(NSUInteger, WalletStatus) {
    WalletStatusUnkonwn,    ///< 未知错误
    WalletStatusCanGet,     ///< 可以领取, 未被领取
    WalletStatusWasGot,     ///< 领完
    WalletStatusWasExpired, ///< 已过期
};

typedef NS_ENUM(NSUInteger, WalletGrabStatus) {
    WalletGrabStatusUnkonwn,    ///< 未知错误
    WalletGrabStatusUnGrab,     ///< 未领
    WalletGrabStatusGrabed,     ///< 已领
};

typedef NS_ENUM(NSUInteger, WalletVendor) {
    WalletVendorYiPay,  ///< 易支付
    WalletVendorNewPay, ///< 新生支付
};

#endif /* WalletDefines_h */

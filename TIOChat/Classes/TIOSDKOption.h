//
//  TIOSDKOption.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/6.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TIOSDKOption : NSObject

/// 普通推送证书
@property (copy, nonatomic) NSString *APNsCerName;

/// PushKit的推送证书
@property (copy, nonatomic) NSString *PushKitCerName;

/// 是否开启SSL, 默认开启
@property (assign,  nonatomic) BOOL isOpenSSL;

@end

NS_ASSUME_NONNULL_END

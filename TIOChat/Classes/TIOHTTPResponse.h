//
//  TIOHTTPResponse.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/6.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#if __has_include(<AFNetworking/AFNetworking-umbrella.h>)
#import <AFNetworking/AFNetworking-umbrella.h>
#else
#import "AFNetworking-umbrella.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface TIOHTTPResponse : AFJSONResponseSerializer

@end

NS_ASSUME_NONNULL_END

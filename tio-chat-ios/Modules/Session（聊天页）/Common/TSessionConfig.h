//
//  TP2PSessionConfig.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/14.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMSessionConfig.h"
#import "IMInputViewProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface TSessionConfig : NSObject <IMSessionConfig, IMKitInputViewConfig>

- (instancetype)initWithSession:(TIOSession *)session;

@end

NS_ASSUME_NONNULL_END

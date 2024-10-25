//
//  TIOMessageReceipt.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/25.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class TIOMessage;

@interface TIOMessageReceipt : NSObject
@property (copy, nonatomic) NSString *messageId;

- (instancetype)initWithMessage:(TIOMessage *)message;

@end

NS_ASSUME_NONNULL_END

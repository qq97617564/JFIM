//
//  TIOMessageObject.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/12/2.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 本类，不直接使用
/// 仅仅作为聊天消息和系统通知的根类
@interface TIOMessageObject : NSObject

@property (nullable, nonatomic, strong) id resp;

@end

NS_ASSUME_NONNULL_END

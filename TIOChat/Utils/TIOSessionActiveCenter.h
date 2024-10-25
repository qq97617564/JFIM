//
//  TIOSessionActiveCenter.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/8/27.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 维持激活会话的状态机
@interface TIOSessionActiveCenter : NSObject

@property (nonatomic,   strong) NSDictionary *focusMap;

@property (nonatomic,   copy) void(^clearSession)(NSString *sesionId);

+ (instancetype)shareInstance;

- (BOOL)isActive:(NSString *)sessionId;

@end

NS_ASSUME_NONNULL_END

//
//  IMKitSessionDataProvider.h
//  CawBar
//
//  Created by admin on 2019/11/13.
//

#import <Foundation/Foundation.h>
#import "TIOKitDependency.h"

NS_ASSUME_NONNULL_BEGIN

@class IMKitMessageModel;
@class TIOMessage;
@class TIOSession;

/**
 *  返回消息结果集的回调
 *  @param messages 消息结果集
 *  @discussion 消息结果需要排序，内部按消息结果已经事先排序处理。
 */
typedef void (^IMKitDataProvideHandler)(NSError *error, NSArray<TIOMessage *> *messages);

/// 消息（数据）提供器
@protocol IMKitSessionDataProvider <NSObject>

- (void)pullDown:(nullable TIOMessage *)firstMessage session:(TIOSession *)session handler:(IMKitDataProvideHandler)handler;

- (void)loadNew:(nullable TIOMessage *)endMessage session:(TIOSession *)session handler:(IMKitDataProvideHandler)handler;

@end

NS_ASSUME_NONNULL_END

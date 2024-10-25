//
//  TCallAudioViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/6/9.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface TCallAudioViewController : TCBaseViewController

/// 接听初始化
/// @param caller 呼叫者
/// @param callId 通话ID
- (instancetype)initWithCaller:(TIOUser *)caller callId:(NSString *)callId;
/// 呼叫初始化
/// @param callee 接听者
- (instancetype)initWithCallee:(TIOUser *)callee;

@end

NS_ASSUME_NONNULL_END

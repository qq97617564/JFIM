//
//  TCallViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/5/18.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"
#import "ImportSDK.h"

NS_ASSUME_NONNULL_BEGIN

@interface TCallViewController : TCBaseViewController

- (instancetype)initWithCaller:(TIOUser *)caller callId:(NSString *)callId;
- (instancetype)initWithCallee:(TIOUser *)callee;

@end

NS_ASSUME_NONNULL_END

//
//  TIOApplyUser.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/18.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOUser.h"

NS_ASSUME_NONNULL_BEGIN

@interface TIOApplyUser : TIOUser

/// 申请状态：1：申请通过；2：申请中
@property (assign, nonatomic) NSInteger status;

/// 申请ID
@property (assign, nonatomic) NSInteger applyId;

/// 招呼语
@property (copy, nonatomic) NSString *greet;

/// 申请时间
@property (copy, nonatomic) NSString *replytime;

@end

NS_ASSUME_NONNULL_END

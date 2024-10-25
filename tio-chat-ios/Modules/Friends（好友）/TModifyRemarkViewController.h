//
//  TModifyRemarkViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/19.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TModifyRemarkViewController : TCBaseViewController

/// 好友的UID
@property (nonatomic, copy) NSString *uid;

@property (nonatomic, copy) void (^modifiedCallback)(NSString *remark);

@end

NS_ASSUME_NONNULL_END

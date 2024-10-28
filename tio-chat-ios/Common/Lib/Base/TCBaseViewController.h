//
//  TCBaseViewController.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/31.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import "TIOKitBaseViewController.h"
#import "UIViewController+T_callback.h"
#import "ImportSDK.h"
#import "MBProgressHUD+NJ.h"

NS_ASSUME_NONNULL_BEGIN

/// Demo
@interface TCBaseViewController : TIOKitBaseViewController
@property (strong, nonatomic) NSDictionary *params;

@end

NS_ASSUME_NONNULL_END

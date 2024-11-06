//
//  GFWallterPwdSettingVC.h
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/11/3.
//  Copyright © 2024 wgf. All rights reserved.
//

#import "TCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GFWallterPwdSettingVC : TCBaseViewController
@property (copy,    nonatomic) void(^changeBlock)(void);
@end

NS_ASSUME_NONNULL_END

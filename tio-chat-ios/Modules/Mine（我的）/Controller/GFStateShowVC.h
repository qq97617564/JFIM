//
//  GFStateShowVC.h
//  tio-chat-ios
//
//  Created by 王刚锋 on 2024/10/28.
//  Copyright © 2024 wgf. All rights reserved.
//

#import "TCBaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GFStateShowVC : TCBaseViewController
@property(nonatomic,assign)NSInteger status;//0-待审核；1-已通过；2-未通过
@end

NS_ASSUME_NONNULL_END

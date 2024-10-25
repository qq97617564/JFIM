//
//  UIViewController+T_callback.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/3.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ModuleCallback)(UIViewController *viewController, id _Nullable data);
typedef void(^CTCallback)(UIViewController *viewController, id _Nullable data);

@interface UIViewController (T_callback)

@property (nonatomic, copy) CTCallback t_callback;

@end

NS_ASSUME_NONNULL_END

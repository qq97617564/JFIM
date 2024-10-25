//
//  UIViewController+T_callback.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/1/3.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "UIViewController+T_callback.h"
#import <objc/runtime.h>

static NSString *key = @"CTCallback";

@implementation UIViewController (T_callback)

- (void)setT_callback:(CTCallback)t_callback
{
    objc_setAssociatedObject(self, &key, t_callback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (CTCallback)t_callback
{
    return objc_getAssociatedObject(self, &key);
}

@end

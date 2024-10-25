//
//  UIImageView+User.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/4/13.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "UIImageView+User.h"
#import <objc/runtime.h>

static NSString *key = @"uid";

@implementation UIImageView (User)

- (void)setUid:(NSString *)uid
{
    objc_setAssociatedObject(self, &key, uid, OBJC_ASSOCIATION_COPY);
}

- (NSString *)uid
{
    return objc_getAssociatedObject(self, &key);
}

@end

//
//  YYAnimatedImageView+T_fix.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/9/18.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "YYAnimatedImageView+T_fix.h"
#import <objc/runtime.h>

@implementation YYAnimatedImageView (T_fix)

+ (void)load
{
    Method a = class_getInstanceMethod(self, @selector(displayLayer:));
    Method b = class_getInstanceMethod(self, @selector(swizzing_displayLayer:));
    method_exchangeImplementations(a, b);
}

- (void)swizzing_displayLayer:(CALayer *)layer
{   
    //通过变量名称获取类中的实例成员变量
    Ivar ivar = class_getInstanceVariable(self.class, "_curFrame");
    UIImage *_curFrame = object_getIvar(self, ivar);

    if (_curFrame) {
        layer.contents = (__bridge id)_curFrame.CGImage;
    } else {
        if (@available(iOS 14.0, *)) {
            [super displayLayer:layer];
        }
    }
}

@end

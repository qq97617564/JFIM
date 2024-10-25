//
//  UIControl+T_LimitClickCount.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/9/18.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "UIControl+T_LimitClickCount.h"
#import <objc/runtime.h>

static int T_spaceClickTime = 0.5;

static const char * UIControl_acceptEventInterval = "UIControl_acceptEventInterval";
static const char * UIControl_ignoreEvent = "UIControl_ignoreEvent";

@implementation UIControl (T_LimitClickCount)

-(void)setAcceptEventInterval:(double)acceptEventInterval {
    //关联属性对象
    objc_setAssociatedObject(self, UIControl_acceptEventInterval,@(acceptEventInterval), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(NSTimeInterval)acceptEventInterval{
    return [objc_getAssociatedObject(self, UIControl_acceptEventInterval) doubleValue];
}

-(void)setT_ignoreEvent:(BOOL)T_ignoreEvent
{
   //关联属性对象
    objc_setAssociatedObject(self, UIControl_ignoreEvent, @(T_ignoreEvent), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)T_ignoreEvent
{
    return [objc_getAssociatedObject(self, UIControl_ignoreEvent) boolValue];
}

//所有类即将加入内存的时候都会走load方法，所以我们在这个里面交换方法
+(void)load{
    Method a = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
    Method b = class_getInstanceMethod(self, @selector(swizzing_sendAction:to:forEvent:));
    method_exchangeImplementations(a, b);
}

-(void)swizzing_sendAction:(SEL)action to:(id)tagert forEvent:(UIEvent*)event{
    if (self.T_ignoreEvent) {
        NSLog(@"点击的太快");
        return;
    }
    if (self.acceptEventInterval) {
        self.T_ignoreEvent = YES;
        [self performSelector:@selector(setIgnoreWithNo) withObject:nil afterDelay:self.acceptEventInterval];
    }

    [self swizzing_sendAction:action to:tagert forEvent:event];
}
-(void)setIgnoreWithNo{
    self.T_ignoreEvent = NO;
}

@end

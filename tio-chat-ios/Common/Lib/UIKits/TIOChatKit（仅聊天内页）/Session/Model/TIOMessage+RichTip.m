//
//  TIOMessage+RichTip.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/9/8.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOMessage+RichTip.h"
#include <objc/runtime.h>


@implementation TIOMessage (RichTip)

- (NSString *)t_linkString
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setT_linkString:(NSString *)t_externString
{
    objc_setAssociatedObject(self, @selector(t_linkString), t_externString, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (UIFont *)t_font
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setT_font:(UIFont *)t_font
{
    objc_setAssociatedObject(self, @selector(t_font), t_font, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)t_color
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setT_color:(UIColor *)t_color
{
    objc_setAssociatedObject(self, @selector(t_color), t_color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)t_selctorName
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setT_selctorName:(NSString *)t_selctorName
{
    objc_setAssociatedObject(self, @selector(t_selctorName), t_selctorName, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSInteger)t_tipCode
{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

- (void)setT_tipCode:(NSInteger)t_tipCode
{   
    objc_setAssociatedObject(self, @selector(t_tipCode), @(t_tipCode), OBJC_ASSOCIATION_ASSIGN);
}

@end

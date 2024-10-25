//
//  TBottomMessageHUD.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/1/13.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "TBottomMessageHUD.h"
#import "FrameAccessor.h"
#import <objc/runtime.h>
#import "UIImage+TColor.h"

static NSString *key1 = @"cb_notificationView";

@implementation UIView (CBVideoHUD)

- (void)setT_HUD:(TBottomMessageHUD *)t_HUD
{
    objc_setAssociatedObject(self, &key1, t_HUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TBottomMessageHUD *)t_HUD
{
    return objc_getAssociatedObject(self, &key1);
}

@end

@interface TBottomMessageHUD ()
@property (copy,    nonatomic) ButtonClicked callback;
@end

@implementation TBottomMessageHUD

static NSString *key = @"action";

+ (TBottomMessageHUD *)showOnView:(UIView *)onView callback:(nonnull ButtonClicked)callback
{
    TBottomMessageHUD *object = [TBottomMessageHUD buttonWithType:UIButtonTypeCustom];
    object.bounds = CGRectMake(0, 0, 124, 38);
    UIImage *normalBackgroundImage = [UIImage colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:object.bounds andColors:@[[UIColor colorWithHex:0x72ABFF],[UIColor colorWithHex:0x3B8AFF]]];
    UIImage *highlightBackgroundImage = [UIImage colorWithGradientStyle:UIGradientStyleLeftToRight withFrame:object.bounds andColors:@[[UIColor colorWithHex:0xA3C6F9],[UIColor colorWithHex:0x84B5FF]]];
    [object setBackgroundImage:[normalBackgroundImage imageWithCornerRadius:25 size:object.viewSize] forState:UIControlStateNormal];
    [object setBackgroundImage:[highlightBackgroundImage imageWithCornerRadius:25 size:object.viewSize] forState:UIControlStateHighlighted];
    [object setImage:[UIImage imageNamed:@"new_msg"] forState:UIControlStateNormal];
    [object setTitle:@"你有新消息" forState:UIControlStateNormal];
    [object setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [object.titleLabel setFont:[UIFont systemFontOfSize:14]];
    object.callback = callback;
    
    [onView addSubview:object];
    onView.t_HUD = object;
    
    return object;
}

- (void)setCallback:(ButtonClicked)callback
{
    objc_setAssociatedObject(self, &key, callback, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(confirm:) forControlEvents:UIControlEventTouchUpInside];
}

- (ButtonClicked)callback
{
    return objc_getAssociatedObject(self, &key);
}

- (void)confirm:(id)sender
{
    if (self.callback) {
        self.callback(self);
    }
}

+ (TBottomMessageHUD *)HUDForView:(UIView *)onView
{
    return onView.t_HUD;
}

+ (void)hideForView:(UIView *)onView
{
    if (onView.t_HUD) {
        [UIView animateWithDuration:0.3 animations:^{
            [onView.t_HUD removeFromSuperview];
            onView.t_HUD = nil;
        }];
    }
}

@end

//
//  UIView+Popup.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/11/9.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "UIView+Popup.h"

@implementation UIView (Popup)

- (void)gp_showPopup
{
    self.alpha = 0.0;
    self.transform = CGAffineTransformMakeScale(0.2, 0.2);
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 1.0;
        self.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)gp_dismissPopup:(void (^)(void))completion
{
    [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alpha = 0.0;
        self.transform = CGAffineTransformMakeScale(0.5, 0.5);
    } completion:^(BOOL finished) {
        !completion ?: completion();
    }];
}

@end

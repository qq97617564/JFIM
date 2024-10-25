//
//  IMKitNavigationBar.m
//  CawBar
//
//  Created by admin on 2019/11/25.
//

#import "TIOKitNavigationBar.h"
#import "FrameAccessor.h"

@implementation TIOKitNavigationBar

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (@available(iOS 11.0, *)) {
        [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:NSClassFromString(@"_UIBarBackground")]) {
                obj.hidden = YES;
            } else if ([obj isKindOfClass:NSClassFromString(@"_UINavigationBarContentView")]) {
                
                CGRect statusBarFrame = CGRectZero;
                if (@available(iOS 13.0, *)) {
                    statusBarFrame = UIApplication.sharedApplication.windows[0].windowScene.statusBarManager.statusBarFrame;
                } else {
                    #pragma clang diagnostic push
                    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    statusBarFrame = UIApplication.sharedApplication.statusBarFrame;
                    #pragma clang diagnostic push
                }
                
                if (CGRectIntersectsRect([self convertRect:obj.frame toView:self.window], statusBarFrame)) {
                    obj.top = CGRectGetMaxY(statusBarFrame);
                    obj.height = self.height - CGRectGetMaxY(statusBarFrame);
                } else {
                    obj.centerY = self.middleY;
                    [self setTitleVerticalPositionAdjustment:2 forBarMetrics:UIBarMetricsDefault];
                }
            }
        }];
    }
}

@end

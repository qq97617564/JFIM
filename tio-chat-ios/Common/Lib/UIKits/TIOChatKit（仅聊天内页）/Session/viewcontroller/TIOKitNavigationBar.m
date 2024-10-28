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
                    obj.top = [self IsIphoneX]? 44 : 20;
                    obj.height = 44;
                } else {
                    obj.centerY = self.middleY;
                    [self setTitleVerticalPositionAdjustment:2 forBarMetrics:UIBarMetricsDefault];
                }
            }
        }];
    }
}
-(BOOL)IsIphoneX
{
    if (@available(iOS 11.0, *)) {
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
                window = windowScene.windows.firstObject;
                break;
            }
        } else {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Wdeprecated-declarations"
            window = UIApplication.sharedApplication.keyWindow;
            #pragma clang diagnostic push
        }
        
        return window.safeAreaInsets.bottom > 0.0;
    }
    return NO;
}
-(UILabel *)titleL{
    if (!_titleL) {
        _titleL = [[UILabel alloc]initWithFrame:CGRectMake(50, Height_StatusBar, ScreenWidth()-100, 44)];
        _titleL.textAlignment = NSTextAlignmentCenter;
        _titleL.textColor = [UIColor blackColor];
        _titleL.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
        [self addSubview:_titleL];
    }
    return _titleL;
}
@end

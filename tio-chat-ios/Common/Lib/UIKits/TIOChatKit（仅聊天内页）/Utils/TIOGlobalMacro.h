//
//  IMGlobalMacro.h
//  CawBar
//
//  Created by admin on 2019/11/13.
//

#ifndef IMGlobalMacro_h
#define IMGlobalMacro_h

#define IMKit_Dispatch_Sync_Main(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#define IMKit_Dispatch_Async_Main(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}

#define IM_Height_StatusBar (imIsIphoneX() ? 44.0f : 20.0f)
#define IM_Height_NavBar (imIsIphoneX() ? 88.0f : 64.0f)
#define IM_Height_TabBar (imIsIphoneX() ? 83.0f : 49.0f)
#define IM_safeBottomHeight (imIsIphoneX() ? 34 : 0)

#define IMKit_ColorRGB(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]
#define IMKit_ColorRGBA(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

static inline BOOL imIsIphoneX()
{
    if (@available(iOS 11.0, *)) {
        UIWindow *window = nil;
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene* windowScene in [UIApplication sharedApplication].connectedScenes) {
                window = windowScene.windows.firstObject;
                if (window) {
                    break;
                }
            }
            return window.safeAreaInsets.bottom > 0.0;
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

#endif /* IMGlobalMacro_h */

//
//  TBottomMessageHUD.h
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/1/13.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TBottomMessageHUD;

@interface UIView (TBottomMessageHUD)

/**
 父容器的通知对象
 */
@property (strong, nonatomic) TBottomMessageHUD *t_HUD;

@end

typedef void(^ButtonClicked)(TBottomMessageHUD *HUD);

@interface TBottomMessageHUD : UIButton

+ (TBottomMessageHUD *)showOnView:(UIView *)onView callback:(ButtonClicked)callback;
+ (TBottomMessageHUD *)HUDForView:(UIView *)onView;
+ (void)hideForView:(UIView *)onView;

@end

NS_ASSUME_NONNULL_END

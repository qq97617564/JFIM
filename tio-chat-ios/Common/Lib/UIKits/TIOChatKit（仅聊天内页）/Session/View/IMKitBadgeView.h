//
//  CBIMBadgeView.h
//  CawBar
//
//  Created by admin on 2019/11/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface IMKitBadgeView : UIView

@property (strong) UIColor *badgeBackgroundColor;

@property (strong) UIColor *badgeTextColor;

@property (nonatomic) UIFont *badgeTextFont;

@property (nonatomic) CGFloat badgeHeight; // 默认0  根据字体自适应

@property (nonatomic) CGFloat badgeTopPadding; //数字顶部到红圈的距离

@property (nonatomic) CGFloat badgeLeftPadding; //数字左部到红圈的距离

@property (nonatomic) CGFloat whiteCircleWidth; //最外层白圈的宽度

@property (copy, nonatomic) NSString *badgeValue;

+ (instancetype)viewWithBadgeTip:(NSString *)badgeValue;

@end

NS_ASSUME_NONNULL_END

//
//  CBRatingTrasitioning.h
//  evaluate
//
//  Created by 刘宇 on 2017/12/17.
//  Copyright © 2017年 刘宇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AlertPresentStyle) {
    AlertPresentStyleCenterSpring = 0,  ///< 中间弹簧动画
    AlertPresentStyleBottomToCenterSpring, ///< 从底部到中间的弹簧动画
    AlertPresentStyleTopToCenterSpring, ///< 从顶部到中间的弹簧动画
    AlertPresentStyleBottom,    /// 朝着屏幕底部消失
};

@interface TAlertTrasitioning : NSObject <UIViewControllerAnimatedTransitioning>

@property (assign, nonatomic) AlertPresentStyle presentingStyle;
@property (assign, nonatomic) AlertPresentStyle dismissStyle;
@property (assign, nonatomic) CGFloat duration;
@property (assign, nonatomic) CGFloat maskAlpha;
@property (assign, nonatomic) BOOL cancelSpring;

@property (assign, nonatomic) CGSize contentOffset;

@end

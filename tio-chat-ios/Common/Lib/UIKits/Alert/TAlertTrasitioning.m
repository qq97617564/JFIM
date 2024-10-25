//
//  CBRatingTrasitioning.m
//  evaluate
//
//  Created by 刘宇 on 2017/12/17.
//  Copyright © 2017年 刘宇. All rights reserved.
//

#import "TAlertTrasitioning.h"

@interface UIViewController (Private)

@property (assign, nonatomic) BOOL allowsCancel;

@end

@interface TAlertTrasitioning () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) UIViewController *presentedViewController;
@property (weak, nonatomic) UIControl *backgroundMask;

- (void)backgroundMaskClicked:(UIControl *)sender;

@end

@implementation TAlertTrasitioning

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.maskAlpha = 0.7;
        self.duration = 0.25;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return self.duration;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
//    fromViewController.view.backgroundColor = [UIColor colorWithRed:61/255.0 green:61/255.0 blue:62/255.0 alpha:1.0];
//    fromViewController.view.alpha = 1;
    
    CGRect toFinalFrame = [transitionContext finalFrameForViewController:toViewController];
    if (fromViewController.isBeingDismissed) {
        // dismiss
        switch (self.dismissStyle) {
            case AlertPresentStyleCenterSpring:
            {
                [UIView animateWithDuration:0.3 animations:^{
                    toViewController.view.alpha = 1;
                    fromViewController.view.alpha = 0.0;
                    fromViewController.view.transform = CGAffineTransformMakeScale(0.5, 0.5);
//                    fromViewController.view.bounds = CGRectMake(0, 0, 50, 50);
                } completion:^(BOOL finished) {
                    [self.presentedViewController.view removeFromSuperview];
                    BOOL wasCancelled = [transitionContext transitionWasCancelled];
                    [transitionContext completeTransition:!wasCancelled];
                }];
                break;
            }
            case AlertPresentStyleBottomToCenterSpring:
            {
                [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//                    fromViewController.view.alpha = 0;
                    fromViewController.view.frame = CGRectMake(0, CGRectGetHeight(toViewController.view.frame), CGRectGetWidth(toViewController.view.frame), CGRectGetHeight(fromViewController.view.frame));
                    toViewController.view.alpha = 1;
                } completion:^(BOOL finished) {
                    BOOL wasCancelled = [transitionContext transitionWasCancelled];
                    [transitionContext completeTransition:!wasCancelled];
                }];
                break;
            }
            case AlertPresentStyleTopToCenterSpring:
            {
                [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                    fromViewController.view.alpha = 0;
                    fromViewController.view.frame = CGRectOffset(fromViewController.view.frame, 0, -CGRectGetHeight(fromViewController.view.frame));
                    toViewController.view.alpha = 1;
                } completion:^(BOOL finished) {
                    BOOL wasCancelled = [transitionContext transitionWasCancelled];
                    [transitionContext completeTransition:!wasCancelled];
                }];
                break;
            }
            default:
                break;
        }
    } else {
        // present
        [transitionContext.containerView addSubview:toViewController.view];
        toFinalFrame = CGRectMake((CGRectGetWidth(transitionContext.containerView.frame) - toViewController.preferredContentSize.width)*0.5 - self.contentOffset.width,
                                  (CGRectGetHeight(transitionContext.containerView.frame) - toViewController.preferredContentSize.height) * 0.5 - self.contentOffset.height,
                                  toViewController.preferredContentSize.width,
                                  toViewController.preferredContentSize.height);
        
        switch (self.presentingStyle) {
            case AlertPresentStyleCenterSpring:
            {
                toViewController.view.frame = toFinalFrame;
                toViewController.view.transform = CGAffineTransformMakeScale(0.2, 0.2);
                [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.6 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    toViewController.view.transform = CGAffineTransformIdentity;
                    fromViewController.view.alpha = self.maskAlpha;
                } completion:^(BOOL finished) {
                    BOOL wasCancelled = [transitionContext transitionWasCancelled];
                    [transitionContext completeTransition:!wasCancelled];
                }];
                break;
            }
            case AlertPresentStyleBottomToCenterSpring:
            {
                toViewController.view.frame = CGRectOffset(toFinalFrame, 0, CGRectGetHeight(toFinalFrame));
                [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.6 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    toViewController.view.frame = toFinalFrame;
                    fromViewController.view.alpha = self.maskAlpha;
                } completion:^(BOOL finished) {
                    BOOL wasCancelled = [transitionContext transitionWasCancelled];
                    [transitionContext completeTransition:!wasCancelled];
                }];
                break;
            }
            case AlertPresentStyleTopToCenterSpring:
            {
                toViewController.view.frame = CGRectOffset(toFinalFrame, 0, -(CGRectGetHeight(toFinalFrame)+CGRectGetMaxY(toFinalFrame)));
                [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                    fromViewController.view.alpha = self.maskAlpha;
                }];
                [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.2 usingSpringWithDamping:0.4 initialSpringVelocity:0.4 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    toViewController.view.frame = toFinalFrame;
                } completion:^(BOOL finished) {
                    BOOL wasCancelled = [transitionContext transitionWasCancelled];
                    [transitionContext completeTransition:!wasCancelled];
                }];
                break;
            }
            case AlertPresentStyleBottom:
            {
                CGRect originFrame = toFinalFrame;
                originFrame.origin.y = CGRectGetHeight(transitionContext.containerView.frame);
                toFinalFrame = CGRectOffset(transitionContext.containerView.frame, 0, CGRectGetHeight(transitionContext.containerView.frame) - CGRectGetHeight(toFinalFrame));
//                toFinalFrame = CGRectOffset(originFrame, 0,  - CGRectGetHeight(originFrame));
                toViewController.view.frame = originFrame;
                if (self.cancelSpring) {
                    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0.6 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        toViewController.view.frame = toFinalFrame;
                        fromViewController.view.alpha = self.maskAlpha;
                    } completion:^(BOOL finished) {
                        BOOL wasCancelled = [transitionContext transitionWasCancelled];
                        [transitionContext completeTransition:!wasCancelled];
                    }];
                } else {
                    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        fromViewController.view.alpha = self.maskAlpha;
                        toViewController.view.frame = toFinalFrame;
                    } completion:^(BOOL finished) {
                        BOOL wasCancelled = [transitionContext transitionWasCancelled];
                        [transitionContext completeTransition:!wasCancelled];
                    }];
                }
                break;
            }
            default:
                break;
        }
    }
}

- (void)backgroundMaskClicked:(UIControl *)sender
{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

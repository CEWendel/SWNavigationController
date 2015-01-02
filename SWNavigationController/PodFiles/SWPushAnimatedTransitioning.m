//
//  SWPushAnimatedTransitioning.m
//  SWNavigationController
//
//  Created by Christopher Wendel on 12/31/14.
//  Copyright (c) 2014 Christopher Wendel. All rights reserved.
//  Based off of 'SlideAnimatedTransitioning' https://github.com/visnup/swipe-left/blob/master/SwipeLeft/SlideAnimatedTransitioning.m
//

#import "SWPushAnimatedTransitioning.h"

#define kSWToLayerShadowRadius 5
#define kSWToLayerShadowOpacity 0.5
#define kSWFromLayerShadowOpacity 0.1
#define kSWPushTransitionDuration 0.2

@implementation SWPushAnimatedTransitioning

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView];
    UIView *toView = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view;
    UIView *fromView = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view;
    
    CGFloat containerViewWidth = containerView.frame.size.width;
    UIView *snapshotToView = [toView snapshotViewAfterScreenUpdates:YES];
    
    [containerView addSubview:snapshotToView];
    
    // Calculate new frame for fromView
    CGRect fromViewFinalFrame = fromView.frame;
    fromViewFinalFrame.origin.x = -containerViewWidth/3.f;
    
    // Calculate the new frame for toView snapshot
    CGRect toViewFinalFrame = toView.frame;
    toViewFinalFrame.origin.x = containerViewWidth;
    
    // Use a shadow path to make rendering during the interactive transition better 
    snapshotToView.frame = toViewFinalFrame;
    snapshotToView.layer.shadowRadius = kSWToLayerShadowRadius;
    snapshotToView.layer.shadowOpacity = kSWFromLayerShadowOpacity;
    CGRect shadowFrame = snapshotToView.layer.bounds;
    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
    snapshotToView.layer.shadowPath = shadowPath;
    
    // Tries to mimic the shadow animation on the default pop animation
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    anim.fromValue = [NSNumber numberWithFloat:kSWFromLayerShadowOpacity];
    anim.toValue = [NSNumber numberWithFloat:kSWToLayerShadowOpacity];
    anim.duration = [self transitionDuration:transitionContext];
    [snapshotToView.layer addAnimation:anim forKey:@"shadowOpacity"];
    snapshotToView.layer.shadowOpacity = kSWToLayerShadowOpacity;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        // Move views to final frames
        snapshotToView.frame = fromView.frame;
        fromView.frame = fromViewFinalFrame;
    } completion:^(BOOL finished) {
        snapshotToView.layer.shadowOpacity = 0;
        
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
        
        // If transition was not cancelled, actually add the toView to our view hierarchy
        if (![transitionContext transitionWasCancelled]) {
            [containerView addSubview:toView];
            [snapshotToView removeFromSuperview];
        }
    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return kSWPushTransitionDuration;
}

@end

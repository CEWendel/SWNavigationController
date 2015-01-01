//
//  SWPushAnimatedTransitioning.m
//  SWNavigationController
//
//  Created by Christopher Wendel on 12/31/14.
//  Copyright (c) 2014 Christopher Wendel. All rights reserved.
//

#import "SWPushAnimatedTransitioning.h"

#define kSWToLayerShadowRadius 5
#define kSWToLayerShadowOpacity 0.5
#define kSWFromLayerShadowOpacity 0.1
#define kSWPushTransitionDuration 0.2

@implementation SWPushAnimatedTransitioning

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = [transitionContext containerView],
    *fromView = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view,
    *toView   = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey].view;
    
    CGFloat width = containerView.frame.size.width;
    UIView *snapshotToView = [toView snapshotViewAfterScreenUpdates:YES];
    
    CGRect offsetLeft = fromView.frame;
    offsetLeft.origin.x = -width/3;
    
    CGRect offscreenRight = toView.frame;
    offscreenRight.origin.x = width;
    
    snapshotToView.frame = offscreenRight;
    snapshotToView.layer.shadowRadius = kSWToLayerShadowRadius;
    snapshotToView.layer.shadowOpacity = kSWFromLayerShadowOpacity;
    
    [containerView addSubview:snapshotToView];
    
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
    anim.fromValue = [NSNumber numberWithFloat:kSWFromLayerShadowOpacity];
    anim.toValue = [NSNumber numberWithFloat:kSWToLayerShadowOpacity];
    anim.duration = [self transitionDuration:transitionContext];
    [snapshotToView.layer addAnimation:anim forKey:@"shadowOpacity"];
    snapshotToView.layer.shadowOpacity = kSWToLayerShadowOpacity;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        snapshotToView.frame = fromView.frame;
        
        fromView.frame = offsetLeft;
        fromView.layer.opacity = 0.9;
    } completion:^(BOOL finished) {
        fromView.layer.opacity = 1;
        snapshotToView.layer.shadowOpacity = 0;
        
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
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

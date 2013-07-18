//
//  TLTransitionAnimator.m
//  UIViewController-Transitions-Example
//
//  Created by Ash Furrow on 2013-07-18.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLTransitionAnimator.h"

@implementation TLTransitionAnimator

// This is used for percent driven interactive transitions, as well as for container controllers that have companion animations that might need to
// synchronize with the main animation.
- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5f;
}

// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect endFrame = CGRectMake(80, 280, 160, 100);
    
    if (self.presenting) {
        [transitionContext.containerView addSubview:fromVC.view];
        
        UIView *toView = [toVC view];
        [transitionContext.containerView addSubview:toView];
        
        CGRect startFrame = endFrame;
        startFrame.origin.x += 320;
        toView.frame = startFrame;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            toView.frame = endFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        UIView *toView = [toVC view];
        [transitionContext.containerView addSubview:toView];
        [transitionContext.containerView addSubview:fromVC.view];
        
        endFrame.origin.x += 320;
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            fromVC.view.frame = endFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}

@end
//
//  TLMenuInteractor.m
//  UIViewController-Transitions-Example
//
//  Created by Ash Furrow on 2013-07-18.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLMenuInteractor.h"
#import "TLMenuViewController.h"

@interface TLMenuInteractor ()

@property (nonatomic, assign, getter = isPresenting) BOOL presenting;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;

@end

@implementation TLMenuInteractor

-(id)initWithParentViewController:(UIViewController *)viewController {
    if (!(self = [super init])) return nil;
    
    _parentViewController = viewController;
    
    return self;
}

-(void)userDidPan:(UIScreenEdgePanGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.parentViewController.view];
    CGPoint velocity = [recognizer velocityInView:self.parentViewController.view];
    
    // Note: Only one presentation may occur at a time, as per usual
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.interactive = YES;
        
        if (location.x < CGRectGetMidX(recognizer.view.bounds)) {
            self.presenting = YES;
            TLMenuViewController *viewController = [[TLMenuViewController alloc] initWithMenuInteractor:self];
            viewController.modalPresentationStyle = UIModalPresentationCustom;
            viewController.transitioningDelegate = self;
            [self.parentViewController presentViewController:viewController animated:YES completion:nil];
        }
        else {
            self.presenting = NO;
            [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat ratio = location.x / CGRectGetWidth(self.parentViewController.view.bounds);
        [self updateInteractiveTransition:ratio];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (self.presenting) {
            if (velocity.x > 0) {
                [self finishInteractiveTransition];
            }
            else {
                [self cancelInteractiveTransition];
            }
        }
        else {
            if (velocity.x < 0) {
                [self finishInteractiveTransition];
            }
            else {
                [self cancelInteractiveTransition];
            }
        }
    }
}

-(void)presentMenu {
    self.presenting = YES;
    
    TLMenuViewController *viewController = [[TLMenuViewController alloc] initWithMenuInteractor:self];
    viewController.modalPresentationStyle = UIModalPresentationCustom;
    viewController.transitioningDelegate = self;
    [self.parentViewController presentViewController:viewController animated:YES completion:nil];
}

- (void)animationEnded:(BOOL)transitionCompleted {
    // Reset to our default state
    self.interactive = NO;
    self.presenting = NO;
    self.transitionContext = nil;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    if (self.interactive) {
        return self;
    }
    
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    if (self.interactive) {
        return self;
    }
    
    return nil;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.3f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.interactive) {
        // nop as per documentation
    }
    else {
        UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        CGRect endFrame = [[transitionContext containerView] bounds];
        
        if (self.presenting) {
            [transitionContext.containerView addSubview:fromVC.view];
            
            UIView *toView = [toVC view];
            [transitionContext.containerView addSubview:toView];
            
            CGRect startFrame = endFrame;
            startFrame.origin.x -= CGRectGetWidth([[transitionContext containerView] bounds]);
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
            
            endFrame.origin.x -= CGRectGetWidth([[transitionContext containerView] bounds]);
            
            [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
                fromVC.view.frame = endFrame;
            } completion:^(BOOL finished) {
                [transitionContext completeTransition:YES];
            }];
        }
    }
}

-(void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect endFrame = [[transitionContext containerView] bounds];
    
    if (self.presenting)
    {
        [transitionContext.containerView addSubview:fromVC.view];
        
        UIView *toView = [toVC view];
        endFrame.origin.x -= CGRectGetWidth([[transitionContext containerView] bounds]);
        toView.frame = endFrame;
        [transitionContext.containerView addSubview:toView];
    }
    else {
        UIView *toView = [toVC view];
        toView.frame = endFrame;
        [transitionContext.containerView addSubview:toView];
        
        [transitionContext.containerView addSubview:fromVC.view];
    }
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect endFrame = [[transitionContext containerView] bounds];
    // Presenting goes from 0...1 and dismissing goes from 1...0
    endFrame.origin.x -= CGRectGetWidth([[transitionContext containerView] bounds]) * (1.0f - percentComplete);
    
    if (self.presenting)
    {
        UIView *toView = [toVC view];
        toView.frame = endFrame;
    }
    else {
        UIView *fromView = [fromVC view];
        fromView.frame = endFrame;
    }
}

- (void)finishInteractiveTransition {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.presenting)
    {
        CGRect endFrame = [[transitionContext containerView] bounds];
        
        [UIView animateWithDuration:0.5f animations:^{
            UIView *toView = [toVC view];
            toView.frame = endFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        CGRect endFrame = CGRectOffset([[transitionContext containerView] bounds], -CGRectGetWidth([[self.transitionContext containerView] bounds]), 0);
        
        [UIView animateWithDuration:0.5f animations:^{
            UIView *fromView = [fromVC view];
            fromView.frame = endFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    
}

- (void)cancelInteractiveTransition {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect endFrame = [[transitionContext containerView] bounds];
    
    if (self.presenting)
    {
        UIView *toView = [toVC view];
        
        endFrame.origin.x -= CGRectGetWidth([[transitionContext containerView] bounds]);
        
        [UIView animateWithDuration:0.5f animations:^{
            toView.frame = endFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:NO];
        }];
    }
    else {
        [UIView animateWithDuration:0.5f animations:^{
            UIView *fromView = [fromVC view];
            fromView.frame = endFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:NO];
        }];
    }
}

@end

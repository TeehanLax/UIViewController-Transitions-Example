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
    CGPoint location = [recognizer locationInView:recognizer.view];
    CGPoint velocity = [recognizer velocityInView:recognizer.view];
    
    // Note: Only one presentation may occur at a time, as per usual
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.presenting = YES;
        
        TLMenuViewController *viewController = [[TLMenuViewController alloc] init];
        viewController.modalPresentationStyle = UIModalPresentationCustom;
        viewController.transitioningDelegate = self;
        [self.parentViewController presentViewController:viewController animated:YES completion:nil];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat ratio = location.x / CGRectGetWidth(self.parentViewController.view.bounds);
        [self updateInteractiveTransition:ratio];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (velocity.x > 0) {
            [self finishInteractiveTransition];
        }
        else {
            [self cancelInteractiveTransition];
        }
    }
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.5f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    // nop as per documentation
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
        
    }
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect endFrame = [[transitionContext containerView] bounds];
    
    if (self.presenting)
    {
        UIView *toView = [toVC view];

        endFrame.origin.x -= CGRectGetWidth([[transitionContext containerView] bounds]) * (1.0f - percentComplete);
        
        toView.frame = endFrame;
    }
    else {
        
    }
}

- (void)finishInteractiveTransition {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect endFrame = [[transitionContext containerView] bounds];
    
    if (self.presenting)
    {
        [UIView animateWithDuration:0.5f animations:^{
            UIView *toView = [toVC view];
            toView.frame = endFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        
    }
    
}

- (void)cancelInteractiveTransition {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
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
        
    }
}

@end

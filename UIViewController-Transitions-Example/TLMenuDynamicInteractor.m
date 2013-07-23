//
//  TLMenuDynamicInteractor.m
//  UIViewController-Transitions-Example
//
//  Created by Ash Furrow on 2013-07-23.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLMenuDynamicInteractor.h"

@interface TLMenuDynamicInteractor () <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIViewControllerInteractiveTransitioning, UIDynamicAnimatorDelegate>

@property (nonatomic, assign, getter = isInteractive) BOOL interactive;
@property (nonatomic, assign, getter = isPresenting) BOOL presenting;
@property (nonatomic, assign, getter = isCompleting) BOOL completing;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UICollisionBehavior *collisionBehaviour;
@property (nonatomic, strong) UIGravityBehavior *gravityBehaviour;

@end

@implementation TLMenuDynamicInteractor

#pragma mark - Public Methods

-(id)initWithParentViewController:(UIViewController *)viewController {
    if (!(self = [super init])) return nil;
    
    _parentViewController = viewController;
    
    return self;
}

/*
 Note: Unlike when we connect a gesture recognizer to a view via an attachment behaviour,
 our recognizer is going to remain agnostic to how the view controller is presented. This
 implementation is identical to the TLMenuInteractor.
 */
-(void)userDidPan:(UIScreenEdgePanGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.parentViewController.view];
    CGPoint velocity = [recognizer velocityInView:self.parentViewController.view];
    
    // Note: Only one presentation may occur at a time, as per usual
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // We're being invoked via a gesture recognizer – we are necessarily interactive
        self.interactive = YES;
        
        // The side of the screen we're panning from determines whether this is a presentation (left) or dismissal (right)
        if (location.x < CGRectGetMidX(recognizer.view.bounds)) {
            self.presenting = YES;
            TLMenuViewController *viewController = [[TLMenuViewController alloc] initWithPanTarget:self];
            viewController.modalPresentationStyle = UIModalPresentationCustom;
            viewController.transitioningDelegate = self;
            [self.parentViewController presentViewController:viewController animated:YES completion:nil];
        }
        else {
            [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        // Determine our ratio between the left edge and the right edge. This means our dismissal will go from 1...0.
        CGFloat ratio = location.x / CGRectGetWidth(self.parentViewController.view.bounds);
        [self updateInteractiveTransition:ratio];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        // Depending on our state and the velocity, determine whether to cancel or complete the transition.
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
    
    TLMenuViewController *viewController = [[TLMenuViewController alloc] initWithPanTarget:self];
    viewController.modalPresentationStyle = UIModalPresentationCustom;
    viewController.transitioningDelegate = self;
    [self.parentViewController presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    // Return nil if we are not interactive
    if (self.interactive) {
        return self;
    }
    
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    // Return nil if we are not interactive
    if (self.interactive) {
        return self;
    }
    
    return nil;
}

#pragma mark - UIViewControllerAnimatedTransitioning Methods

- (void)animationEnded:(BOOL)transitionCompleted {
    // Reset to our default state
    self.interactive = NO;
    self.presenting = NO;
    self.transitionContext = nil;
    
    [self.animator removeAllBehaviors], self.animator = nil;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    // Instead of using this to animate a transition, we'll use it as an upper-bounds to the UIKit Dynamics simulation elapsedTime.
    // We'll use 2 seconds.
    return 2.0f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;
    
    if (self.interactive) {
        // nop as per documentation
    }
    else {
        // Guaranteed to complete since this is a non-interactive transition
        self.completing = YES;
        
        // This code is lifted wholesale from the TLTransitionAnimator class
        UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        
        CGRect startFrame = [[transitionContext containerView] bounds];
        CGRect endFrame = [[transitionContext containerView] bounds];
        
        self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:transitionContext.containerView];
        self.animator.delegate = self;
        
        if (self.presenting) {
            // The order of these matters – determines the view hierarchy order.
            [transitionContext.containerView addSubview:fromViewController.view];
            [transitionContext.containerView addSubview:toViewController.view];
            
            startFrame.origin.x -= CGRectGetWidth([[transitionContext containerView] bounds]);
            
            toViewController.view.frame = startFrame;
            
            self.collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[toViewController.view]];
            [self.collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, -CGRectGetWidth(transitionContext.containerView.bounds), 0, 0)];
            
            self.gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[toViewController.view]];
            [self.gravityBehaviour setXComponent:5 yComponent:0];
            
            UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[toViewController.view]];
            itemBehaviour.elasticity = 0.5f;
            [self.animator addBehavior:itemBehaviour];
        }
        else {
            [transitionContext.containerView addSubview:toViewController.view];
            [transitionContext.containerView addSubview:fromViewController.view];
            
            endFrame.origin.x -= CGRectGetWidth(self.transitionContext.containerView.bounds);
            
            fromViewController.view.frame = startFrame;
            
            self.collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[fromViewController.view]];
            [self.collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, -CGRectGetWidth(transitionContext.containerView.bounds), 0, 0)];
            
            self.gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[fromViewController.view]];
            [self.gravityBehaviour setXComponent:-5 yComponent:0];
            
            UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[fromViewController.view]];
            itemBehaviour.elasticity = 0.5f;
            [self.animator addBehavior:itemBehaviour];
        }
        
        [self.animator addBehavior:self.collisionBehaviour];
        [self.animator addBehavior:self.gravityBehaviour];
        
        // We need to *guarantee* that our transition completes at some point.
        double delayInSeconds = [self transitionDuration:self.transitionContext];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // If we still have an animator, we're still animating, so we need to complete our transition immediately. 
            if (self.animator) {
                BOOL presenting = self.presenting;
                
                [self.transitionContext completeTransition:YES];
                
                if (presenting) {
                    toViewController.view.frame = endFrame;
                }
                else {
                    fromViewController.view.frame = endFrame;
                }
            }
        });
    }
}

#pragma mark - UIViewControllerInteractiveTransitioning Methods

-(void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect endFrame = [[transitionContext containerView] bounds];
    
    if (self.presenting)
    {
        // The order of these matters – determines the view hierarchy order.
        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        
        endFrame.origin.x -= CGRectGetWidth([[transitionContext containerView] bounds]);
    }
    else {
        [transitionContext.containerView addSubview:toViewController.view];
        [transitionContext.containerView addSubview:fromViewController.view];
    }
    
    toViewController.view.frame = endFrame;
    
}

#pragma mark - UIPercentDrivenInteractiveTransition Overridden Methods

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // Presenting goes from 0...1 and dismissing goes from 1...0
    CGRect frame = CGRectOffset([[transitionContext containerView] bounds], -CGRectGetWidth([[transitionContext containerView] bounds]) * (1.0f - percentComplete), 0);
    
    if (self.presenting)
    {
        toViewController.view.frame = frame;
    }
    else {
        fromViewController.view.frame = frame;
    }
}

- (void)finishInteractiveTransition {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.presenting)
    {
        CGRect endFrame = [[transitionContext containerView] bounds];
        
        [UIView animateWithDuration:0.5f animations:^{
            toViewController.view.frame = endFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        CGRect endFrame = CGRectOffset([[transitionContext containerView] bounds], -CGRectGetWidth([[self.transitionContext containerView] bounds]), 0);
        
        [UIView animateWithDuration:0.5f animations:^{
            fromViewController.view.frame = endFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    
}

- (void)cancelInteractiveTransition {
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    if (self.presenting)
    {
        CGRect endFrame = CGRectOffset([[transitionContext containerView] bounds], -CGRectGetWidth([[transitionContext containerView] bounds]), 0);
        
        [UIView animateWithDuration:0.5f animations:^{
            toViewController.view.frame = endFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:NO];
        }];
    }
    else {
        CGRect endFrame = [[transitionContext containerView] bounds];
        
        [UIView animateWithDuration:0.5f animations:^{
            fromViewController.view.frame = endFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:NO];
        }];
    }
}

#pragma mark - UIDynamicAnimatorDelegate Methods

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator*)animator {
    [self.transitionContext completeTransition:self.completing];
}

@end

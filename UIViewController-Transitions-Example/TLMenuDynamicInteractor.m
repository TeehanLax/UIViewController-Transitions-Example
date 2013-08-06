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
@property (nonatomic, assign, getter = isInteractiveTransitionInteracting) BOOL interactiveTransitionInteracting;
@property (nonatomic, assign, getter = isInteractiveTransitionUnderway) BOOL interactiveTransitionUnderway;
@property (nonatomic, strong) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehaviour;
@property (nonatomic, assign) CGPoint lastKnownVelocity;

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
    
    self.lastKnownVelocity = velocity;
    
    // Note: Only one presentation may occur at a time, as per usual
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // We *must* check if we already have an interactive transition underway
        
        // TODO: Still need this?
        if (self.interactiveTransitionUnderway == NO) {
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
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        // Determine our ratio between the left edge and the right edge. This means our dismissal will go from 1...0.
        CGFloat ratio = location.x / CGRectGetWidth(self.parentViewController.view.bounds);
        [self updateInteractiveTransition:ratio];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        // Depending on our state and the velocity, determine whether to cancel or complete the transition.
        
        if (self.interactiveTransitionInteracting) {
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
}

-(void)presentMenu {
    self.presenting = YES;
    
    TLMenuViewController *viewController = [[TLMenuViewController alloc] initWithPanTarget:self];
    viewController.modalPresentationStyle = UIModalPresentationCustom;
    viewController.transitioningDelegate = self;
    
    [self.parentViewController presentViewController:viewController animated:YES completion:nil];
}

#pragma mark - Private Methods 

-(void)ensureSimulationCompletesWithDesiredEndFrame:(CGRect)endFrame {
    // Take a "snapshot" of the transitionContext when this method is first invoked. We'll compare it to self.transitionContext
    // When the dispatch_after block is invoked.
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    // We need to *guarantee* that our transition completes at some point.
    double delayInSeconds = [self transitionDuration:self.transitionContext];
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // If we still have an animator, we're still animating, so we need to complete our transition immediately.
        id<UIViewControllerContextTransitioning> blockContext = self.transitionContext;
        UIDynamicAnimator *blockAnimator = self.animator;
        
        if (blockAnimator && blockContext == transitionContext) {
            BOOL presenting = self.presenting;
            
            [transitionContext completeTransition:YES];
            
            if (presenting) {
                toViewController.view.frame = endFrame;
            }
            else {
                fromViewController.view.frame = endFrame;
            }
        }
    });
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
    
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    fromViewController.view.userInteractionEnabled = YES;
    toViewController.view.userInteractionEnabled = YES;
    
    // Reset to our default state
    self.interactive = NO;
    self.presenting = NO;
    self.transitionContext = nil;
    self.completing = NO;
    self.interactiveTransitionInteracting = NO;
    self.interactiveTransitionUnderway = NO;
    
    [self.animator removeAllBehaviors], self.animator.delegate = nil, self.animator = nil;
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
            
            UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[toViewController.view]];
            [collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, -CGRectGetWidth(transitionContext.containerView.bounds), 0, 0)];
            
            UIGravityBehavior *gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[toViewController.view]];
            gravityBehaviour.gravityDirection = CGVectorMake(5.0f, 0.0f);
            
            UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[toViewController.view]];
            itemBehaviour.elasticity = 0.5f;
            
            [self.animator addBehavior:collisionBehaviour];
            [self.animator addBehavior:gravityBehaviour];
            [self.animator addBehavior:itemBehaviour];
        }
        else {
            [transitionContext.containerView addSubview:toViewController.view];
            [transitionContext.containerView addSubview:fromViewController.view];
            
            endFrame.origin.x -= CGRectGetWidth(self.transitionContext.containerView.bounds);
            
            fromViewController.view.frame = startFrame;
            
            UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[fromViewController.view]];
            [collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, -CGRectGetWidth(transitionContext.containerView.bounds), 0, 0)];
            
            UIGravityBehavior *gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[fromViewController.view]];
            gravityBehaviour.gravityDirection = CGVectorMake(-5.0f, 0.0f);
            
            UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[fromViewController.view]];
            itemBehaviour.elasticity = 0.5f;
            
            [self.animator addBehavior:collisionBehaviour];
            [self.animator addBehavior:gravityBehaviour];
            [self.animator addBehavior:itemBehaviour];
        }
        
        [self ensureSimulationCompletesWithDesiredEndFrame:endFrame];
    }
}

#pragma mark - UIViewControllerInteractiveTransitioning Methods

-(void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    NSAssert(self.animator == nil, @"Duplicating animators – likely two presentations running concurrently.");
    
    self.transitionContext = transitionContext;
    self.interactiveTransitionInteracting = YES;
    self.interactiveTransitionUnderway = YES;
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    fromViewController.view.userInteractionEnabled = NO;
    
    CGRect frame = [[transitionContext containerView] bounds];
    
    if (self.presenting)
    {
        // The order of these matters – determines the view hierarchy order.
        [transitionContext.containerView addSubview:fromViewController.view];
        [transitionContext.containerView addSubview:toViewController.view];
        
        frame.origin.x -= CGRectGetWidth([[transitionContext containerView] bounds]);
    }
    else {
        [transitionContext.containerView addSubview:toViewController.view];
        [transitionContext.containerView addSubview:fromViewController.view];
    }
    
    toViewController.view.frame = frame;
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:transitionContext.containerView];
    self.animator.delegate = self;
    
    id <UIDynamicItem> dynamicItem;
    
    if (self.presenting) {
        dynamicItem = toViewController.view;
        self.attachmentBehaviour = [[UIAttachmentBehavior alloc] initWithItem:dynamicItem attachedToAnchor:CGPointMake(0.0f, CGRectGetMidY(transitionContext.containerView.bounds))];
    }
    else {
        dynamicItem = fromViewController.view;
        self.attachmentBehaviour = [[UIAttachmentBehavior alloc] initWithItem:dynamicItem attachedToAnchor:CGPointMake(CGRectGetWidth(transitionContext.containerView.bounds), CGRectGetMidY(transitionContext.containerView.bounds))];
    }
    
    UICollisionBehavior *collisionBehaviour = [[UICollisionBehavior alloc] initWithItems:@[dynamicItem]];
    [collisionBehaviour setTranslatesReferenceBoundsIntoBoundaryWithInsets:UIEdgeInsetsMake(0, -CGRectGetWidth(transitionContext.containerView.bounds), 0, 0)];
    
    UIDynamicItemBehavior *itemBehaviour = [[UIDynamicItemBehavior alloc] initWithItems:@[dynamicItem]];
    itemBehaviour.elasticity = 0.5f;
    
    [self.animator addBehavior:collisionBehaviour];
    [self.animator addBehavior:itemBehaviour];
    [self.animator addBehavior:self.attachmentBehaviour];
}

#pragma mark - UIPercentDrivenInteractiveTransition Overridden Methods

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    self.attachmentBehaviour.anchorPoint = CGPointMake(CGRectGetWidth(self.transitionContext.containerView.bounds) * percentComplete, CGRectGetMidY(self.transitionContext.containerView.bounds));
}

- (void)finishInteractiveTransition {
    self.interactiveTransitionInteracting = NO;
    self.completing = YES;
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    [self.animator removeBehavior:self.attachmentBehaviour];
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect endFrame = transitionContext.containerView.bounds;
    
    id<UIDynamicItem> dynamicItem;
    CGFloat gravityXComponent = 0.0f;
    
    if (self.presenting)
    {
        dynamicItem = toViewController.view;
        gravityXComponent = 5.0f;
    }
    else {
        dynamicItem = fromViewController.view;
        gravityXComponent = -5.0f;
        
        endFrame.origin.x -= CGRectGetWidth(endFrame);
    }
    
    UIGravityBehavior *gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[dynamicItem]];
    gravityBehaviour.gravityDirection = CGVectorMake(gravityXComponent, 0.0f);
    
    UIPushBehavior *pushBehaviour = [[UIPushBehavior alloc] initWithItems:@[dynamicItem] mode:UIPushBehaviorModeInstantaneous];
    pushBehaviour.pushDirection = CGVectorMake(self.lastKnownVelocity.x / 10.0f, 0.0f);
    
    [self.animator addBehavior:gravityBehaviour];
    [self.animator addBehavior:pushBehaviour];
    
    [self ensureSimulationCompletesWithDesiredEndFrame:endFrame];
}

- (void)cancelInteractiveTransition {
    self.interactiveTransitionInteracting = NO;
    id<UIViewControllerContextTransitioning> transitionContext = self.transitionContext;
    
    [self.animator removeBehavior:self.attachmentBehaviour];
    
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGRect endFrame = transitionContext.containerView.bounds;
    
    id<UIDynamicItem> dynamicItem;
    CGFloat gravityXComponent = 0.0f;
    
    if (self.presenting)
    {
        dynamicItem = toViewController.view;
        gravityXComponent = -5.0f;
        
        endFrame.origin.x -= CGRectGetWidth(endFrame);
    }
    else {
        dynamicItem = fromViewController.view;
        gravityXComponent = 5.0f;
    }
    
    UIGravityBehavior *gravityBehaviour = [[UIGravityBehavior alloc] initWithItems:@[dynamicItem]];
    gravityBehaviour.gravityDirection = CGVectorMake(gravityXComponent, 0.0f);
    
    UIPushBehavior *pushBehaviour = [[UIPushBehavior alloc] initWithItems:@[dynamicItem] mode:UIPushBehaviorModeInstantaneous];
    pushBehaviour.pushDirection = CGVectorMake(self.lastKnownVelocity.x / 10.0f, 0.0f);
    
    [self.animator addBehavior:gravityBehaviour];
    [self.animator addBehavior:pushBehaviour];
    
    [self ensureSimulationCompletesWithDesiredEndFrame:endFrame];
}

#pragma mark - UIDynamicAnimatorDelegate Methods

- (void)dynamicAnimatorDidPause:(UIDynamicAnimator*)animator {
    // We need this check to determine if the user is still interacting with the transition (ie: they stopped moving their finger)
    if (!self.interactiveTransitionInteracting) {
        [self.transitionContext completeTransition:self.completing];
    }
}

@end

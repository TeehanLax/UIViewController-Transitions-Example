//
//  TLMenuInteractor.h
//  UIViewController-Transitions-Example
//
//  Created by Ash Furrow on 2013-07-18.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TLMenuViewController.h"

@interface TLMenuInteractor : UIPercentDrivenInteractiveTransition <TLMenuViewControllerPanTarget>

-(id)initWithParentViewController:(UIViewController *)viewController;

@property (nonatomic, readonly) UIViewController *parentViewController;

-(void)userDidPan:(UIScreenEdgePanGestureRecognizer *)recognizer; // Used as a target for a UIScreenEdgePanGestureRecognizer
-(void)presentMenu; // Presents the menu non-interactively

@end

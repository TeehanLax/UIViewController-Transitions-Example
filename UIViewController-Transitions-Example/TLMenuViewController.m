//
//  TLMenuViewController.m
//  UIViewController-Transitions-Example
//
//  Created by Ash Furrow on 2013-07-18.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLMenuViewController.h"

#import "TLMenuInteractor.h"

@interface TLMenuViewController ()

@end

@implementation TLMenuViewController

-(id)initWithMenuInteractor:(id<TLMenuViewControllerPanTarget>)menuInteractor
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _menuInteractor = menuInteractor;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // Just to differentiate use visually
    self.view.backgroundColor = [UIColor orangeColor];
    
    // Set up our done button
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [doneButton setTitle:@"Dismiss" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneWasPressed:) forControlEvents:UIControlEventTouchUpInside];
    doneButton.frame = CGRectMake(0, 0, 100, 44);
    doneButton.center = self.view.center;
    [self.view addSubview:doneButton];
    
    UIScreenEdgePanGestureRecognizer *gestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self.menuInteractor action:@selector(userDidPan:)];
    gestureRecognizer.edges = UIRectEdgeRight;
    [self.view addGestureRecognizer:gestureRecognizer];
}

-(void)doneWasPressed:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}


@end

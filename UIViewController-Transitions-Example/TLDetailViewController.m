//
//  TLDetailViewController.m
//  UIViewController-Transitions-Example
//
//  Created by Ash Furrow on 2013-07-12.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLDetailViewController.h"

@interface TLDetailViewController ()

@end

@implementation TLDetailViewController

-(IBAction)doneWasPressed:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

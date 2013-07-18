//
//  TLAppDelegate.m
//  UIViewController-Transitions-Example
//
//  Created by Ash Furrow on 2013-07-12.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLAppDelegate.h"

@interface TLAppDelegate () <UINavigationControllerDelegate>

@end

@implementation TLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    UINavigationController *navigationController = (UINavigationController *)(self.window.rootViewController);
    navigationController.delegate = self;
    
    return YES;
}

@end

//
//  TLMenuViewController.h
//  UIViewController-Transitions-Example
//
//  Created by Ash Furrow on 2013-07-18.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TLMenuInteractor;

@interface TLMenuViewController : UIViewController

-(id)initWithMenuInteractor:(TLMenuInteractor *)menuInteractor;

@property (nonatomic, readonly) TLMenuInteractor *menuInteractor;

@end

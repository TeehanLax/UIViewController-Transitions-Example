//
//  TLMasterViewController.m
//  UIViewController-Transitions-Example
//
//  Created by Ash Furrow on 2013-07-12.
//  Copyright (c) 2013 Teehan+Lax. All rights reserved.
//

#import "TLMasterViewController.h"

#import "TLDetailViewController.h"

#import "TLTransitionAnimator.h"


@interface TLMasterViewController () <UIViewControllerTransitioningDelegate>
{
    NSMutableArray *_objects;
}
@end

@implementation TLMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    self.navigationItem.rightBarButtonItem = addButton;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)insertNewObject:(id)sender
{
    if (!_objects) {
        _objects = [[NSMutableArray alloc] init];
    }
    [_objects insertObject:[NSDate date] atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    UIViewController *detailViewController = segue.destinationViewController;
    
    detailViewController.transitioningDelegate = self;
    detailViewController.modalPresentationStyle = UIModalPresentationCustom;
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDate *object = _objects[indexPath.row];
    cell.textLabel.text = [object description];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source {
    
    if ([presented isKindOfClass:[TLDetailViewController class]]) {
        TLTransitionAnimator *animator = [TLTransitionAnimator new];
        //Configure the animator
        animator.presenting = YES;
        return animator;
    }
    else {
        return nil;
    }
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if ([dismissed isKindOfClass:[TLDetailViewController class]]) {
        TLTransitionAnimator *animator = [TLTransitionAnimator new];
        return animator;
    }
    else {
        return nil;
    }
}


@end



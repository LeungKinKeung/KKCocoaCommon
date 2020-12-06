//
//  NSView+KKNavigation.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "NSView+KKNavigation.h"
#import <objc/runtime.h>
#import "NSView+KKAnimation.h"

static CGFloat gAnimationDefaultDuration    = 0.4;
static NSString *const KKAnimationPushKey   = @"KKAnimationPushKey";
static NSString *const KKAnimationPopKey    = @"KKAnimationPopKey";

@implementation NSView (KKNavigation)

#pragma mark - 视图控制器
- (void)setViewControllers:(NSMutableArray<__kindof NSViewController *> *)viewControllers
{
    objc_setAssociatedObject(self, @selector(viewControllers), viewControllers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableArray<__kindof NSViewController *> *)viewControllers
{
    NSMutableArray *controllers =
    objc_getAssociatedObject(self, @selector(viewControllers));
    
    if (controllers == nil) {
        controllers = [NSMutableArray array];
        [self setViewControllers:controllers];
    }
    return controllers;
}

- (NSViewController *)topViewController
{
    return self.viewControllers.lastObject;
}

#pragma mark 根视图
- (void)setRootViewController:(NSViewController *)rootViewController
{
    NSMutableArray *viewControllers = self.viewControllers;
    for (NSViewController *vc in viewControllers) {
        [vc.view removeFromSuperview];
        [self removeChildViewControllerFromWindowContentViewController:vc];
    }
    [viewControllers removeAllObjects];
    [viewControllers addObject:rootViewController];
    [self addChildViewControllerToWindowContentViewController:rootViewController];
    if (rootViewController.isViewLoaded || [[NSBundle mainBundle] pathForResource:[rootViewController className] ofType:@"nib"]) {
        rootViewController.view.frame = self.bounds;
        [self addSubview:rootViewController.view];
    } else {
        NSView *view = [[NSView alloc] initWithFrame:self.bounds];
        [rootViewController setView:view];
        [rootViewController viewDidLoad];
        [self addSubview:view];
        KKNavigationBar *bar = rootViewController.navigationBar;
        if (bar) {
            [self addSubview:bar];
            CGSize size             = [bar intrinsicContentSize];
            bar.frame               = CGRectMake(0, self.isFlipped ? 0 : self.bounds.size.height - size.height, size.width, size.height);
//            bar.autoresizingMask    = NSViewWidthSizable | NSViewMinYMargin;
//            bar.backButton.hidden   = YES;
//            bar.separator.hidden    = YES;
//            bar.backgroundView.hidden   = YES;
        }
    }
    rootViewController.view.autoresizingMask    = NSViewWidthSizable | NSViewHeightSizable;
}

- (NSViewController *)rootViewController
{
    return self.viewControllers.firstObject;
}

- (void)pushViewController:(NSViewController *)viewController animated:(BOOL)animated
{
    NSViewController *previous      = self.viewControllers.lastObject;
    NSView *previousView            = previous.view;
    KKNavigationBar *previousBar    = previous.navigationBar;
    
    [self.viewControllers addObject:viewController];
    [self addChildViewControllerToWindowContentViewController:viewController];
    NSView *addedView               = nil;
    if (viewController.isViewLoaded) {
        addedView                   = viewController.view;
        [self addSubview:addedView];
        addedView.frame             = self.bounds;
    } else {
        addedView                   = [[NSView alloc] initWithFrame:self.bounds];
        [viewController setView:addedView];
        [viewController viewDidLoad];
        [self addSubview:addedView];
    }
    addedView.translatesAutoresizingMaskIntoConstraints   = NO;
    addedView.autoresizingMask      = NSViewWidthSizable | NSViewHeightSizable;
    
    KKNavigationBar *bar            = viewController.navigationBar;
    if (bar) {
        [self addSubview:bar];
        CGSize size             = [bar intrinsicContentSize];
        bar.frame               = CGRectMake(0, self.isFlipped ? 0 : self.bounds.size.height - size.height, size.width, size.height);
        bar.autoresizingMask    = NSViewWidthSizable | NSViewMinYMargin;
    }
    
    if (animated) {
        
        // 自右向左进入动画
        CGPoint addedViewFromPoint  = CGPointMake(self.frame.size.width, addedView.frame.origin.y);
        CGPoint addedViewToPoint    = CGPointMake(0, addedView.frame.origin.y);
        [addedView addCAAnimationWithDuration:gAnimationDefaultDuration fromPoint:addedViewFromPoint toPoint:addedViewToPoint forKey:KKAnimationPushKey removedOnCompletion:YES completionBlock:nil];
        
        CGPoint barFromPoint        = CGPointMake(self.frame.size.width, bar.frame.origin.y);
        CGPoint barToPoint          = CGPointMake(0, bar.frame.origin.y);
        [bar addCAAnimationWithDuration:gAnimationDefaultDuration fromPoint:barFromPoint toPoint:barToPoint forKey:KKAnimationPushKey removedOnCompletion:YES completionBlock:nil];
        
        // 自右向左渐变消失动画
        CGPoint previousViewFromPoint   = previousView.frame.origin;
        CGPoint previousViewToPoint     = CGPointMake(-(self.frame.size.width * 0.3), previousView.frame.origin.y);
        __weak typeof(previousView) weakPreviousView    = previousView;
        [previousView addCAAnimationWithDuration:gAnimationDefaultDuration fromPoint:previousViewFromPoint toPoint:previousViewToPoint fromOpacity:1 toOpacity:0 forKey:KKAnimationPushKey removedOnCompletion:NO completionBlock:^(BOOL animationFinished) {
            if (weakPreviousView == nil) {
                return;
            }
            if (animationFinished) {
                weakPreviousView.hidden = YES;
            }
            [weakPreviousView removeAllCAAnimations];
        }];
        
        CGPoint previousBarFromPoint    = previousBar.frame.origin;
        CGPoint previousBarToPoint      = CGPointMake(-(self.frame.size.width * 0.3), previousBar.frame.origin.y);
        __weak typeof(previousBar) weakPreviousBar    = previousBar;
        [previousBar addCAAnimationWithDuration:gAnimationDefaultDuration fromPoint:previousBarFromPoint toPoint:previousBarToPoint fromOpacity:1 toOpacity:0 forKey:KKAnimationPushKey removedOnCompletion:NO completionBlock:^(BOOL animationFinished) {
            if (weakPreviousBar == nil) {
                return;
            }
            if (animationFinished) {
                weakPreviousBar.hidden = YES;
            }
            [weakPreviousBar removeAllCAAnimations];
        }];
        
    } else {
        previousView.hidden         = YES;
        previousBar.hidden          = YES;
    }
}

- (NSViewController *)popViewControllerAnimated:(BOOL)animated
{
    NSMutableArray *viewControllers     = self.viewControllers;
    if (viewControllers.count <= 1) {
        return nil;
    }
    NSViewController *viewController    =
    [viewControllers objectAtIndex:viewControllers.count - 2];
    
    return [self popToViewController:viewController animated:animated].firstObject;
}

- (NSArray<__kindof NSViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
{
    return [self popToViewController:self.viewControllers.firstObject animated:animated];
}

- (NSArray<__kindof NSViewController *> *)popToViewController:(NSViewController *)viewController animated:(BOOL)animated
{
    NSMutableArray *viewControllers = self.viewControllers;
    if (viewControllers.count <= 1) {
        return nil;
    }
    if ([viewControllers containsObject:viewController] == NO) {
        return nil;
    }
    NSInteger index = [viewControllers indexOfObject:viewController] + 1;
    NSMutableArray *removeControllers       = [NSMutableArray array];
    
    for (NSInteger i = index; i < viewControllers.count; i++) {
        [removeControllers addObject:viewControllers[i]];
    }
    [viewControllers removeObjectsInArray:removeControllers];
    
    NSViewController *top       = removeControllers.lastObject;
    NSView *topView             = top.view;
    KKNavigationBar *topBar     = top.navigationBar;
    
    NSViewController *last      = viewControllers.lastObject;
    NSView *lastView            = last.view;
    KKNavigationBar *lastBar    = last.navigationBar;
    lastView.hidden             = NO;
    lastBar.hidden              = NO;
    
    if (animated) {
        // 自左向右消失动画
        [topView removeCAAnimationForKey:KKAnimationPushKey];
        [lastView removeCAAnimationForKey:KKAnimationPushKey];
        
        CGPoint topFromPoint    = topView.frame.origin;
        CGPoint topToPoint      = CGPointMake(self.frame.size.width, topView.frame.origin.y);
        __weak typeof(self) weakself = self;
        [topView addCAAnimationWithDuration:gAnimationDefaultDuration fromPoint:topFromPoint toPoint:topToPoint forKey:KKAnimationPopKey removedOnCompletion:NO completionBlock:^(BOOL animationFinished) {
            for (NSViewController *viewController in removeControllers) {
                [viewController.view removeFromSuperview];
                [viewController.navigationBar removeFromSuperview];
                [weakself removeChildViewControllerFromWindowContentViewController:viewController];
            }
        }];
        
        CGPoint topBarFromPoint    = topBar.frame.origin;
        CGPoint topBarToPoint      = CGPointMake(self.frame.size.width, topBar.frame.origin.y);
        [topBar addCAAnimationWithDuration:gAnimationDefaultDuration fromPoint:topBarFromPoint toPoint:topBarToPoint forKey:KKAnimationPopKey removedOnCompletion:NO completionBlock:nil];
        
        // 自左向右渐变呈现动画
        CGPoint previousViewFromPoint   = CGPointMake(-(lastView.frame.size.width * 0.3), lastView.frame.origin.y);
        CGPoint previousViewToPoint     = CGPointMake(0, lastView.frame.origin.y);
        [lastView addCAAnimationWithDuration:gAnimationDefaultDuration fromPoint:previousViewFromPoint toPoint:previousViewToPoint fromOpacity:0 toOpacity:1 forKey:KKAnimationPopKey removedOnCompletion:YES completionBlock:nil];
        
        CGPoint previousBarFromPoint   = CGPointMake(-(lastBar.frame.size.width * 0.3), lastBar.frame.origin.y);
        CGPoint previousBarToPoint     = CGPointMake(0, lastBar.frame.origin.y);
        [lastBar addCAAnimationWithDuration:gAnimationDefaultDuration fromPoint:previousBarFromPoint toPoint:previousBarToPoint fromOpacity:0 toOpacity:1 forKey:KKAnimationPopKey removedOnCompletion:YES completionBlock:nil];
    } else {
        for (NSViewController *viewController in removeControllers) {
            [viewController.view removeFromSuperview];
            [viewController.navigationBar removeFromSuperview];
            [self removeChildViewControllerFromWindowContentViewController:viewController];
        }
    }
    return removeControllers;
}

- (void)addChildViewControllerToWindowContentViewController:(NSViewController *)childViewController
{
    NSViewController *windowViewController  = self.window.contentViewController;
    if (windowViewController && windowViewController.view == self) {
        [windowViewController addChildViewController:childViewController];
    }
}
- (void)removeChildViewControllerFromWindowContentViewController:(NSViewController *)childViewController
{
    NSViewController *windowViewController  = self.window.contentViewController;
    if (windowViewController &&
        windowViewController.view == self &&
        [windowViewController.childViewControllers containsObject:childViewController]) {
        NSInteger index = [windowViewController.childViewControllers indexOfObject:childViewController];
        [windowViewController removeChildViewControllerAtIndex:index];
    }
}

- (void)addConstraintToBar:(NSView *)bar
{
    {
        NSLayoutConstraint *constraint =
        [NSLayoutConstraint constraintWithItem:bar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        constraint.priority = NSLayoutPriorityRequired;
        [self addConstraint:constraint];
    }
    {
        NSLayoutConstraint *constraint =
        [NSLayoutConstraint constraintWithItem:bar attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        constraint.priority = NSLayoutPriorityDefaultLow;
        [self addConstraint:constraint];
    }
    {
        NSLayoutConstraint *constraint =
        [NSLayoutConstraint constraintWithItem:bar attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        constraint.priority = NSLayoutPriorityDefaultLow;
        [self addConstraint:constraint];
    }
}

- (void)addConstraintToView:(NSView *)view
{
    {
        NSLayoutConstraint *constraint =
        [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1 constant:0];
        constraint.priority = NSLayoutPriorityDefaultLow;
        [self addConstraint:constraint];
    }
    {
        NSLayoutConstraint *constraint =
        [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:0];
        constraint.priority = NSLayoutPriorityDefaultLow;
        [self addConstraint:constraint];
    }
    {
        NSLayoutConstraint *constraint =
        [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1 constant:0];
        constraint.priority = NSLayoutPriorityDefaultLow;
        [self addConstraint:constraint];
    }
    {
        NSLayoutConstraint *constraint =
        [NSLayoutConstraint constraintWithItem:view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:0];
        constraint.priority = NSLayoutPriorityDefaultLow;
        [self addConstraint:constraint];
    }
}

@end

@implementation NSViewController (KKNavigation)

- (NSView *)navigationView
{
    return self.view.superview;
}

@end

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

static CGFloat KKAnimationDefaultDuration = 0.4;
static NSString *KKAnimationPushKey = @"KKAnimationPushKey";
static NSString *KKAnimationPopKey = @"KKAnimationPopKey";

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
    if (rootViewController.isViewLoaded) {
        rootViewController.view.frame = self.bounds;
        [self addSubview:rootViewController.view];
    } else {
        NSView *view = [[NSView alloc] initWithFrame:self.bounds];
        [rootViewController setView:view];
        [rootViewController viewDidLoad];
        [self addSubview:view];
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
    addedView.autoresizingMask      = NSViewWidthSizable | NSViewHeightSizable;
    
    if (animated) {
        
        // 自右向左进入动画
        CGPoint addedViewFromPoint  = CGPointMake(self.frame.size.width, addedView.frame.origin.y);
        CGPoint addedViewToPoint    = CGPointMake(0, addedView.frame.origin.y);
        [addedView addCAAnimationWithDuration:KKAnimationDefaultDuration fromPoint:addedViewFromPoint toPoint:addedViewToPoint forKey:KKAnimationPushKey completionBlock:nil];
        
        // 自右向左渐变消失动画
        CGPoint previousViewFromPoint   = previousView.frame.origin;
        CGPoint previousViewToPoint     = CGPointMake(-(self.frame.size.width * 0.3), previousView.frame.origin.y);
        __weak typeof(previousView) weakPreviousView    = previousView;
        [previousView addCAAnimationWithDuration:KKAnimationDefaultDuration fromPoint:previousViewFromPoint toPoint:previousViewToPoint fromOpacity:1 toOpacity:0 forKey:KKAnimationPushKey completionBlock:^(BOOL animationFinished) {
            if (weakPreviousView == nil) {
                return;
            }
            if (animationFinished) {
                weakPreviousView.hidden = YES;
            }
            [weakPreviousView removeAllCAAnimations];
        }];
    } else {
        previousView.hidden         = YES;
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
    
    NSViewController *last      = viewControllers.lastObject;
    NSView *lastView            = last.view;
    lastView.hidden             = NO;
    
    if (animated) {
        // 自左向右消失动画
        [topView removeCAAnimationForKey:KKAnimationPushKey];
        [lastView removeCAAnimationForKey:KKAnimationPushKey];
        
        CGPoint topFromPoint    = topView.frame.origin;
        CGPoint topToPoint      = CGPointMake(self.frame.size.width, topView.frame.origin.y);
        __weak typeof(self) weakself = self;
        [topView addCAAnimationWithDuration:KKAnimationDefaultDuration fromPoint:topFromPoint toPoint:topToPoint  forKey:KKAnimationPopKey completionBlock:^(BOOL animationFinished) {
            for (NSViewController *viewController in removeControllers) {
                [viewController.view removeFromSuperview];
                [weakself removeChildViewControllerFromWindowContentViewController:viewController];
            }
        }];
        
        // 自左向右渐变呈现动画
        CGPoint previousViewFromPoint   = CGPointMake(-(lastView.frame.size.width * 0.3), lastView.frame.origin.y);
        CGPoint previousViewToPoint     = CGPointMake(0, lastView.frame.origin.y);
        [lastView addCAAnimationWithDuration:KKAnimationDefaultDuration fromPoint:previousViewFromPoint toPoint:previousViewToPoint fromOpacity:0 toOpacity:1 forKey:KKAnimationPopKey completionBlock:nil];
    } else {
        for (NSViewController *viewController in removeControllers) {
            [viewController.view removeFromSuperview];
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

@end

@implementation NSViewController (KKNavigation)

- (NSView *)navigationView
{
    return self.view.superview;
}

- (BOOL)isRootViewController
{
    return self.navigationView.rootViewController == self;
}

@end

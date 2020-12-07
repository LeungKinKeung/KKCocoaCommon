//
//  KKNavigationController.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/12/4.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKNavigationController.h"
#import <QuartzCore/CoreAnimation.h>
#import <objc/runtime.h>

@interface KKNavigationController ()

@property (nonatomic) Class navigationBarClass;

@end

@implementation KKNavigationController

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass
{
    self = [super init];
    if (self) {
        self.navigationBarClass = navigationBarClass;
    }
    return self;
}

- (instancetype)initWithRootViewController:(NSViewController *)rootViewController
{
    self = [super init];
    if (self) {
        self.rootViewController = rootViewController;
    }
    return self;
}

- (NSView *)view
{
    if (self.isViewLoaded || self.nibName || [[NSBundle mainBundle] pathForResource:[self className] ofType:@"nib"]) {
        // 已加载、storyboard、nib
        return [super view];
    }
    NSView *view = [NSView new];
    [super setView:view];
    [self viewDidLoad];
    return view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.animationDuration = 0.35;
}

- (void)setRootViewController:(NSViewController *)rootViewController
{
    NSInteger count = self.childViewControllers.count;
    for (NSInteger i = 0; i < count; i++) {
        [self removeChildViewControllerAtIndex:0];
    }
    [self addChildViewController:rootViewController];
    
    KKNavigationBar *navigationBar  = rootViewController.navigationBar;
    if (navigationBar) {
        navigationBar.backButton.hidden     = YES;
        navigationBar.separator.hidden      = YES;
        navigationBar.backgroundView.hidden = YES;
        [self layoutNavigationBar:navigationBar];
        [self noteNavigationBarDidLoad:rootViewController];
    }
    
    if (rootViewController.isViewLoaded ||
        rootViewController.nibName ||
        [[NSBundle mainBundle] pathForResource:[rootViewController className] ofType:@"nib"]) {
        rootViewController.view.frame = [self contentViewFrame];
        [self.view addSubview:rootViewController.view];
        [self.view addSubview:navigationBar];
    } else {
        NSView *view = [[NSView alloc] initWithFrame:[self contentViewFrame]];
        [rootViewController setView:view];
        [rootViewController viewDidLoad];
        [self.view addSubview:view];
        [self.view addSubview:navigationBar];
    }
}

- (NSViewController *)rootViewController
{
    return self.childViewControllers.firstObject;
}

- (void)pushViewController:(NSViewController *)viewController animated:(BOOL)animated
{
    NSViewController *previous      = self.childViewControllers.lastObject;
    NSView *previousView            = previous.view;
    KKNavigationBar *previousBar    = previous.navigationBar;
    [self addChildViewController:viewController];
    
    KKNavigationBar *pushingBar     = viewController.navigationBar;
    if (pushingBar) {
        pushingBar.backButton.target = self;
        pushingBar.backButton.action = @selector(backButtonClicked:);
        [self layoutNavigationBar:pushingBar];
        [self noteNavigationBarDidLoad:viewController];
    }
    
    NSView *pushingView     = nil;
    if (viewController.isViewLoaded ||
        viewController.nibName ||
        [[NSBundle mainBundle] pathForResource:[viewController className] ofType:@"nib"]) {
        pushingView         = viewController.view;
        pushingView.frame   = [self contentViewFrame];
        [self.view addSubview:pushingView];
        [self.view addSubview:pushingBar];
    } else {
        pushingView         = [[NSView alloc] initWithFrame:[self contentViewFrame]];
        [viewController setView:pushingView];
        [viewController viewDidLoad];
        [self.view addSubview:pushingView];
        [self.view addSubview:pushingBar];
    }
    
    if (animated) {
        
        // 自右向左进入动画
        CGRect pushingViewToFrame       = [self contentViewFrame];
        CGRect pushingViewFromFrame     = pushingViewToFrame;
        pushingViewFromFrame.origin.x   = self.view.bounds.size.width;
        
        CGRect pushingBarToFrame        = [self frameForNavigationBar:pushingBar];
        CGRect pushingBarFromFrame      = pushingBarToFrame;
        pushingBarFromFrame.origin.x    = pushingViewFromFrame.origin.x;
        
        // 自右向左渐变消失动画
        CGRect previousViewFromFrame    = [self contentViewFrame];
        CGRect previousViewToFrame      = previousViewFromFrame;
        previousViewToFrame.origin.x    = -(self.view.bounds.size.width * 0.3);
        
        CGRect previousBarFromFrame     = [self frameForNavigationBar:previousBar];
        CGRect previousBarToFrame       = previousBarFromFrame;
        previousBarToFrame.origin.x     = previousViewToFrame.origin.x;
        
        pushingView.frame               = pushingViewFromFrame;
        pushingBar.frame                = pushingBarFromFrame;
        previousView.alphaValue         = 1;
        previousBar.alphaValue          = 1;
        previousView.frame              = previousViewFromFrame;
        previousBar.frame               = previousBarFromFrame;
        
        [NSAnimationContext beginGrouping];

        NSAnimationContext *context = [NSAnimationContext currentContext];
        context.duration            = self.animationDuration;
        context.timingFunction      =
        //[CAMediaTimingFunction functionWithControlPoints:0 :0 :0 :1]; // EaseOut
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];

        pushingView.animator.frame  = pushingViewToFrame;
        pushingBar.animator.frame   = pushingBarToFrame;
        
        previousView.animator.frame = previousViewToFrame;
        previousBar.animator.frame  = previousBarToFrame;
        previousView.animator.alphaValue    = 0;
        previousBar.animator.alphaValue     = 0;
        
        __weak typeof(previousView) weakPreviousView    = previousView;
        __weak typeof(previousBar) weakPreviousBar      = previousBar;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakPreviousView.hidden = YES;
            weakPreviousBar.hidden = YES;
        });
        
        [NSAnimationContext endGrouping];
        
    } else {
        previousView.hidden         = YES;
        previousBar.hidden          = YES;
    }
}

- (NSArray<__kindof NSViewController *> *)popToViewController:(NSViewController *)viewController animated:(BOOL)animated
{
    if (self.childViewControllers.count <= 1) {
        return nil;
    }
    if ([self.childViewControllers containsObject:viewController] == NO) {
        return nil;
    }
    NSInteger index = [self.childViewControllers indexOfObject:viewController] + 1;
    NSMutableArray *removeControllers = [NSMutableArray array];
    for (NSInteger i = index; i < self.childViewControllers.count; i++) {
        [removeControllers addObject:[self.childViewControllers objectAtIndex:i]];
    }
    
    NSViewController *topViewControler  = removeControllers.lastObject;
    NSView *topView                     = topViewControler.view;
    KKNavigationBar *topBar             = topViewControler.navigationBar;
    
    NSView *toViewControlerView         = viewController.view;
    KKNavigationBar *toViewControlerBar = viewController.navigationBar;
    toViewControlerView.hidden          = NO;
    toViewControlerBar.hidden           = NO;
    
    if (animated) {
        // 自左向右消失动画
        CGRect topViewFromFrame         = topView.frame;
        CGRect topViewToFrame           = topViewFromFrame;
        topViewToFrame.origin.x         = self.view.bounds.size.width;
        
        CGRect topBarFromFrame          = topBar.frame;
        CGRect topBarToFrame            = topBarFromFrame;
        topBarToFrame.origin.x          = topViewToFrame.origin.x;
        
        CGRect toViewControlerViewToFrame     = [self contentViewFrame];
        CGRect toViewControlerViewFromFrame   = toViewControlerViewToFrame;
        toViewControlerViewFromFrame.origin.x = -(self.view.bounds.size.width * 0.3);
        
        CGRect toViewControlerBarToFrame      = [self frameForNavigationBar:toViewControlerBar];
        CGRect toViewControlerBarFromFrame    = toViewControlerBarToFrame;
        toViewControlerBarFromFrame.origin.x  = toViewControlerViewFromFrame.origin.x;
        
        topView.frame   = topViewFromFrame;
        topBar.frame    = topBarFromFrame;
        
        toViewControlerView.frame       = toViewControlerViewFromFrame;
        toViewControlerBar.frame        = toViewControlerBarFromFrame;
        toViewControlerView.alphaValue  = 0;
        toViewControlerBar.alphaValue   = 0;
        
        [NSAnimationContext beginGrouping];

        NSAnimationContext *context = [NSAnimationContext currentContext];
        context.duration            = self.animationDuration;
        context.timingFunction      =
        //[CAMediaTimingFunction functionWithControlPoints:0 :0 :0 :1]; // EaseOut
        [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        
        topView.animator.frame      = topViewToFrame;
        topBar.animator.frame       = topBarToFrame;
        topView.animator.alphaValue = 0;
        topBar.animator.alphaValue  = 0;
        
        toViewControlerView.animator.frame      = toViewControlerViewToFrame;
        toViewControlerBar.animator.frame       = toViewControlerBarToFrame;
        toViewControlerView.animator.alphaValue = 1;
        toViewControlerBar.animator.alphaValue  = 1;
        
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            for (NSViewController *viewController in removeControllers) {
                [viewController.view removeFromSuperview];
                [viewController.navigationBar removeFromSuperview];
                NSInteger index = [weakSelf.childViewControllers indexOfObject:viewController];
                [weakSelf removeChildViewControllerAtIndex:index];
            }
        });
        [NSAnimationContext endGrouping];
        
    } else {
        for (NSViewController *viewController in removeControllers) {
            [viewController.view removeFromSuperview];
            [viewController.navigationBar removeFromSuperview];
            NSInteger index = [self.childViewControllers indexOfObject:viewController];
            [self removeChildViewControllerAtIndex:index];
        }
    }
    return removeControllers;
}

- (NSViewController *)popViewControllerAnimated:(BOOL)animated
{
    if (self.childViewControllers.count <= 1) {
        return nil;
    }
    NSViewController *viewController    =
    [self.childViewControllers objectAtIndex:self.childViewControllers.count - 2];
    
    return [self popToViewController:viewController animated:animated].firstObject;
}

- (NSArray<__kindof NSViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
{
    return [self popToViewController:self.childViewControllers.firstObject animated:animated];
}

- (void)backButtonClicked:(NSButton *)sender
{
    [self popViewControllerAnimated:YES];
}

- (void)noteNavigationBarDidLoad:(NSViewController *)viewController
{
    if (viewController.navigationBar && [viewController respondsToSelector:@selector(navigationBarDidLoad)]) {
        [viewController navigationBarDidLoad];
    }
}

- (void)viewDidLayout
{
    [super viewDidLayout];
    
    NSViewController *visibleViewController = self.childViewControllers.lastObject;
    visibleViewController.view.frame = [self contentViewFrame];
    [self layoutNavigationBar:visibleViewController.navigationBar];
}

- (CGRect)contentViewFrame
{
    return self.view.bounds;
}

- (CGRect)frameForNavigationBar:(KKNavigationBar *)navigationBar
{
    if (navigationBar == nil) {
        return CGRectZero;
    }
    CGSize size         =
    [navigationBar intrinsicContentSizeWithNavigationControllerView:self.view];
    CGFloat barY        =
    self.view.isFlipped ? 0 : self.view.bounds.size.height - size.height;
    return CGRectMake(0, barY, size.width, size.height);
}

- (void)layoutNavigationBar:(KKNavigationBar *)navigationBar
{
    if (navigationBar == nil) {
        return;
    }
    navigationBar.frame = [self frameForNavigationBar:navigationBar];
}

- (NSViewController *)topViewController
{
    return self.viewControllers.lastObject;
}

- (NSArray<__kindof NSViewController *> *)viewControllers
{
    return self.childViewControllers;
}

@end


@implementation NSViewController (KKNavigationController)

- (KKNavigationController *)navigationController
{
    return (KKNavigationController *)self.parentViewController;
}

- (void)setNavigationBar:(KKNavigationBar *)navigationBar
{
    objc_setAssociatedObject(self, @selector(navigationBar), navigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (KKNavigationBar *)navigationBar
{
    if ([self respondsToSelector:@selector(hasNavigationBar)] == NO || self.hasNavigationBar == NO) {
        return nil;
    }
    KKNavigationBar *navigationBar = objc_getAssociatedObject(self, @selector(navigationBar));
    
    if (navigationBar == nil) {
        if ([self respondsToSelector:@selector(navigationBarClass)]) {
            navigationBar = [[self navigationBarClass] new];
        } else if (self.navigationController.navigationBarClass) {
            navigationBar = [self.navigationController.navigationBarClass new];
        } else {
            navigationBar = [KKNavigationBar new];
        }
        [self setNavigationBar:navigationBar];
    }
    return navigationBar;
}

@end

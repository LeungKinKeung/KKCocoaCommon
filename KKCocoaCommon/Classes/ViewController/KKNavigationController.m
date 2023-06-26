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

@implementation KKNavigationContentView

- (void)scrollWheel:(NSEvent *)event {
    [[self nextResponder] scrollWheel:event];
}

@end

@interface KKNavigationController ()

/// 初始化视图的frame
@property (nonatomic, assign) CGRect initialViewFrame;
/// 滑动的距离
@property (nonatomic, assign) CGPoint scrollingOffset;
/// 视图的位置开始变动
@property (nonatomic, assign) BOOL isScrolling;
/// 两个手指放在触摸板上
@property (nonatomic, assign) NSTimeInterval scrollingMayBeginTime;
/// 开始滑动
@property (nonatomic, assign) NSTimeInterval scrollingBeginTime;
/// 导航栏类
@property (nonatomic) Class navigationBarClass;
/// 动画进行中
@property (nonatomic, assign, getter=isAnimationPlaying) BOOL animationPlaying;

@end

@implementation KKNavigationController

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass
{
    return [self initWithRootViewController:nil
                         navigationBarClass:navigationBarClass
                                  viewFrame:CGRectZero];
}

- (instancetype)initWithRootViewController:(NSViewController *)rootViewController
{
    return [self initWithRootViewController:rootViewController
                         navigationBarClass:nil
                                  viewFrame:CGRectZero];
}

- (instancetype)initWithRootViewController:(NSViewController *)rootViewController
                        navigationBarClass:(Class)navigationBarClass
                                 viewFrame:(CGRect)viewFrame {
    self = [self init];
    if (self) {
        self.initialViewFrame = viewFrame;
        self.navigationBarClass = navigationBarClass;
        self.rootViewController = rootViewController;
    }
    return self;
}

- (void)loadView {
    // 如果是从storyboard初始化，则nibName有值
    // 如果是从nib初始化，则[[NSBundle mainBundle] pathForResource:[self className] ofType:@"nib"]有值
    if (self.isViewLoaded ||
        self.nibName ||
        [[NSBundle mainBundle] pathForResource:[self className] ofType:@"nib"]) {
        [super loadView];
        return;
    }
    NSView *view = [[KKNavigationContentView alloc] initWithFrame:self.initialViewFrame];
    [view setWantsLayer:YES];
    [self setView:view];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.appearBeginOpacityWhenPush     = 1;
    self.disappearEndOpacityWhenPush    = 1;
    self.appearBeginOpacityWhenPop      = 1;
    self.disappearEndOpacityWhenPop     = 1;
    self.disappearDistance  = 0.3;
    self.animationDuration  = 0.3;
    self.timingFunction     =
    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    //[CAMediaTimingFunction functionWithControlPoints:0 :0 :0 :1]; // EaseOut
}

- (void)setRootViewController:(NSViewController *)rootViewController
{
    NSArray *childViewControllers = self.childViewControllers.copy;
    for (NSViewController *viewController in childViewControllers) {
        [viewController.view removeFromSuperview];
        [viewController.navigationBar removeFromSuperview];
        [viewController removeFromParentViewController];
    }
    [self addChildViewController:rootViewController isRoot:YES];
}

- (void)addChildViewController:(NSViewController *)viewController isRoot:(BOOL)isRoot {
    [self addChildViewController:viewController];
    
    KKNavigationBar *navigationBar = viewController.navigationBar;
    if (navigationBar) {
        if (isRoot) {
            navigationBar.backButton.hidden     = YES;
            navigationBar.separator.hidden      = YES;
        } else {
            navigationBar.backButton.target = self;
            navigationBar.backButton.action = @selector(backButtonClicked:);
        }
        [self layoutNavigationBar:navigationBar];
        [self noteNavigationBarDidLoad:viewController];
    }
    
    NSView *childView   = viewController.view;
    childView.frame     = [self contentViewFrame];
    [self.view addSubview:childView];
    [self.view addSubview:navigationBar];
}

- (NSViewController *)rootViewController
{
    return self.childViewControllers.firstObject;
}

- (void)pushViewController:(NSViewController *)viewController animated:(BOOL)animated
{
    NSViewController *willDisappearController   = self.childViewControllers.lastObject;
    NSView *willDisappearView                   = willDisappearController.view;
    KKNavigationBar *willDisappearBar           = willDisappearController.navigationBar;
    [self addChildViewController:viewController isRoot:NO];
    KKNavigationBar *willAppearBar              = viewController.navigationBar;
    NSView *willAppearView                      = viewController.view;
    
    if (animated) {
        
        self.animationPlaying           = YES;
        // 自右向左进入动画
        CGRect willAppearViewToFrame        = [self contentViewFrame];
        CGRect willAppearViewFromFrame      = willAppearViewToFrame;
        willAppearViewFromFrame.origin.x    = self.view.bounds.size.width;
        
        CGRect willAppearBarToFrame         = [self frameForNavigationBar:willAppearBar];
        CGRect willAppearBarFromFrame       = willAppearBarToFrame;
        willAppearBarFromFrame.origin.x     = willAppearViewFromFrame.origin.x;
        
        // 自右向左渐变消失动画
        CGRect willDisappearViewFromFrame   = [self contentViewFrame];
        CGRect willDisappearViewToFrame     = willDisappearViewFromFrame;
        willDisappearViewToFrame.origin.x   = -(self.view.bounds.size.width * self.disappearDistance);
        
        CGRect willDisappearBarFromFrame    = [self frameForNavigationBar:willDisappearBar];
        CGRect willDisappearBarToFrame      = willDisappearBarFromFrame;
        willDisappearBarToFrame.origin.x    = willDisappearViewToFrame.origin.x;
        
        willAppearView.frame                = willAppearViewFromFrame;
        willAppearBar.frame                 = willAppearBarFromFrame;
        willAppearView.alphaValue           = self.appearBeginOpacityWhenPush;
        willAppearBar.alphaValue            = self.appearBeginOpacityWhenPush;
        willDisappearView.alphaValue        = 1;
        willDisappearBar.alphaValue         = 1;
        willDisappearView.frame             = willDisappearViewFromFrame;
        willDisappearBar.frame              = willDisappearBarFromFrame;
        
        [NSAnimationContext beginGrouping];

        NSAnimationContext *context     = [NSAnimationContext currentContext];
        context.duration                = self.animationDuration;
        context.timingFunction          = self.timingFunction;

        willAppearView.animator.frame   = willAppearViewToFrame;
        willAppearBar.animator.frame    = willAppearBarToFrame;
        willAppearView.animator.alphaValue  = 1;
        willAppearBar.animator.alphaValue   = 1;
        
        willDisappearView.animator.frame = willDisappearViewToFrame;
        willDisappearBar.animator.frame  = willDisappearBarToFrame;
        willDisappearView.animator.alphaValue    = self.disappearEndOpacityWhenPush;
        willDisappearBar.animator.alphaValue     = self.disappearEndOpacityWhenPush;
        
        __weak typeof(willDisappearView) weakPreviousView    = willDisappearView;
        __weak typeof(willDisappearBar) weakPreviousBar      = willDisappearBar;
        __weak typeof(self) weakSelf                    = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            weakPreviousView.hidden     = YES;
            weakPreviousBar.hidden      = YES;
            weakSelf.animationPlaying   = NO;
        });
        
        [NSAnimationContext endGrouping];
        
    } else {
        willDisappearView.hidden         = YES;
        willDisappearBar.hidden          = YES;
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
    
    NSViewController *willDisappearController   = removeControllers.lastObject;
    NSView *willDisappearView                   = willDisappearController.view;
    KKNavigationBar *willDisappearBar           = willDisappearController.navigationBar;
    
    NSView *willAppearView          = viewController.view;
    KKNavigationBar *willAppearBar  = viewController.navigationBar;
    willAppearView.hidden           = NO;
    willAppearBar.hidden            = NO;
    
    if (animated) {
        
        self.animationPlaying           = YES;
        // 自左向右消失动画
        CGRect willHideViewFromFrame        = willDisappearView.frame;
        CGRect willHideViewToFrame          = willHideViewFromFrame;
        willHideViewToFrame.origin.x        = self.view.bounds.size.width;
        
        CGRect willHideBarFromFrame         = willDisappearBar.frame;
        CGRect willHideBarToFrame           = willHideBarFromFrame;
        willHideBarToFrame.origin.x         = willHideViewToFrame.origin.x;
        
        CGRect willDisplayViewToFrame       = [self contentViewFrame];
        CGRect willDisplayViewFromFrame     = willDisplayViewToFrame;
        willDisplayViewFromFrame.origin.x   = -(self.view.bounds.size.width * self.disappearDistance);
        
        CGRect willDisplayBarToFrame        = [self frameForNavigationBar:willAppearBar];
        CGRect willDisplayBarFromFrame      = willDisplayBarToFrame;
        willDisplayBarFromFrame.origin.x    = willDisplayViewFromFrame.origin.x;
        
        willDisappearView.frame     = willHideViewFromFrame;
        willDisappearBar.frame      = willHideBarFromFrame;
        
        willAppearView.frame        = willDisplayViewFromFrame;
        willAppearBar.frame         = willDisplayBarFromFrame;
        willAppearView.alphaValue   = self.appearBeginOpacityWhenPop;
        willAppearBar.alphaValue    = self.appearBeginOpacityWhenPop;
        
        [NSAnimationContext beginGrouping];

        NSAnimationContext *context = [NSAnimationContext currentContext];
        context.duration            = self.animationDuration;
        context.timingFunction      = self.timingFunction;
        
        willDisappearView.animator.frame        = willHideViewToFrame;
        willDisappearBar.animator.frame         = willHideBarToFrame;
        willDisappearView.animator.alphaValue   = self.disappearEndOpacityWhenPop;
        willDisappearBar.animator.alphaValue    = self.disappearEndOpacityWhenPop;
        
        willAppearView.animator.frame           = willDisplayViewToFrame;
        willAppearBar.animator.frame            = willDisplayBarToFrame;
        willAppearView.animator.alphaValue      = 1;
        willAppearBar.animator.alphaValue       = 1;
        
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.animationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            for (NSViewController *viewController in removeControllers) {
                [viewController.view removeFromSuperview];
                [viewController.navigationBar removeFromSuperview];
                [viewController removeFromParentViewController];
            }
            weakSelf.animationPlaying   = NO;
        });
        [NSAnimationContext endGrouping];
        
    } else {
        for (NSViewController *viewController in removeControllers) {
            [viewController.view removeFromSuperview];
            [viewController.navigationBar removeFromSuperview];
            [viewController removeFromParentViewController];
        }
    }
    return removeControllers;
}

- (void)updateSubviewsWithTopViewFrameX:(CGFloat)x {
    CGRect contentViewFrame = [self contentViewFrame];
    if (contentViewFrame.size.width == 0) {
        return;
    }
    if (x > self.view.frame.size.width) {
        x = self.view.frame.size.width;
    }
    if (x < 0) {
        x = 0;
    }
    {
        NSView *view    = self.topViewController.view;
        CGRect frame    = contentViewFrame;
        frame.origin.x  = x;
        view.frame      = frame;
        //view.alphaValue = 1.0 - frame.origin.x / frame.size.width;
    }
    {
        KKNavigationBar *view = self.topViewController.navigationBar;
        CGRect frame    = [self frameForNavigationBar:view];
        frame.origin.x  = x;
        view.frame      = frame;
        //view.alphaValue = 1.0 - frame.origin.x / frame.size.width;
    }
    NSInteger willAppearIndex = self.viewControllers.count - 2;
    if (willAppearIndex >= 0) {
        NSView *view    = [self.viewControllers objectAtIndex:willAppearIndex].view;
        CGRect frame    = contentViewFrame;
        frame.origin.x  = (x - frame.size.width) * self.disappearDistance;
        view.frame      = frame;
        //view.alphaValue = 1 - fabs(frame.origin.x) / (frame.size.width * self.hiddenDistance);
        if (x <= 0 && view.isHidden == NO) {
            view.hidden     = YES;
            view.alphaValue = 0;
        } else if (x > 0 && view.isHidden) {
            view.hidden     = NO;
            view.alphaValue = 1;
        }
    }
    if (willAppearIndex >= 0) {
        KKNavigationBar *view = [self.viewControllers objectAtIndex:willAppearIndex].navigationBar;
        CGRect frame    = [self frameForNavigationBar:view];
        frame.origin.x  = (x - frame.size.width) * self.disappearDistance;
        view.frame      = frame;
        //view.alphaValue = 1 - fabs(frame.origin.x) / (frame.size.width * self.hiddenDistance);
        if (x <= 0 && view.isHidden == NO) {
            view.hidden     = YES;
            view.alphaValue = 0;
        } else if (x > 0 && view.isHidden) {
            view.hidden     = NO;
            view.alphaValue = 1;
        }
    }
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
    
    if (self.isAnimationPlaying || self.isScrolling) {
        return;
    }
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

- (void)scrollWheel:(NSEvent *)event {
    [super scrollWheel:event];
    
    if (self.viewControllers.count <= 1) {
        return;
    }
    
    CGFloat viewMaxX    = self.view.bounds.size.width;
    
    // scrollingDeltaX：向右滑动为正，向左滑动为负
    // scrollingDeltaY：向上滑动为负，向下滑动为正
    switch (event.phase) {
        case NSEventPhaseMayBegin: {
            self.scrollingMayBeginTime  = [[NSDate date] timeIntervalSince1970];
            self.scrollingBeginTime     = 0;
            self.isScrolling            = NO;
            self.scrollingOffset        = CGPointZero;
            break;
        }
        case NSEventPhaseBegan: {
            self.scrollingBeginTime     = [[NSDate date] timeIntervalSince1970];
            break;
        }
        case NSEventPhaseChanged: {
            CGPoint point = self.scrollingOffset;
            point.x += event.scrollingDeltaX;
            point.y += event.scrollingDeltaY;
            self.scrollingOffset = point;
            
            do {
                if (self.isScrolling) {
                    break;
                }
                if (fabs(self.scrollingOffset.y) > 5 &&
                    fabs(self.scrollingOffset.y) > self.scrollingOffset.x * 0.2) {
                    break;
                }
                if (self.scrollingOffset.x <= 0) {
                    break;
                }
                if (self.scrollingOffset.x > 30) {
                    self.isScrolling = YES;
                    break;
                }
                // 长按了
                if ([[NSDate date] timeIntervalSince1970] - self.scrollingMayBeginTime > 1) {
                    if (self.scrollingOffset.x >= 5) {
                        self.isScrolling = YES;
                        break;
                    }
                }
            } while (NO);
            
            if (self.isScrolling) {
                [self updateSubviewsWithTopViewFrameX:self.scrollingOffset.x];
            }
            break;
        }
        case NSEventPhaseEnded: {
            CGPoint point = self.scrollingOffset;
            point.x += event.scrollingDeltaX;
            point.y += event.scrollingDeltaY;
            self.scrollingOffset = point;
            
            if (self.isScrolling) {
                NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
                NSTimeInterval begin = self.scrollingBeginTime;
                if (now - begin < 0.3 && self.scrollingOffset.x > 60) {
                    // 轻扫
                    [self popViewControllerAnimated:YES];
                } else if (self.scrollingOffset.x > viewMaxX * 0.45) {
                    // 滑过去
                    [self popViewControllerAnimated:YES];
                } else {
                    // 恢复（不做动画了）
                    [self updateSubviewsWithTopViewFrameX:0];
                }
            }
            self.scrollingMayBeginTime  = 0;
            self.scrollingBeginTime     = 0;
            self.scrollingOffset        = CGPointZero;
            self.isScrolling            = NO;
            break;
        }
        case NSEventPhaseCancelled: {
            self.scrollingMayBeginTime  = 0;
            self.scrollingBeginTime     = 0;
            self.scrollingOffset        = CGPointZero;
            self.isScrolling            = NO;
            break;
        }
        default: {
            break;
        }
    }
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

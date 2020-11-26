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
    if (rootViewController.isViewLoaded) {
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
            bar.autoresizingMask    = NSViewWidthSizable | NSViewMinYMargin;
            bar.backButton.hidden   = YES;
            bar.separator.hidden    = YES;
            bar.backgroundView.hidden   = YES;
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

@interface KKNavigationBarBackButton : NSButton

@end

@implementation KKNavigationBarBackButton

- (NSSize)intrinsicContentSize
{
    NSSize size = [super intrinsicContentSize];
    if (self.bezelStyle == NSBezelStyleTexturedRounded && self.isBordered && size.height > size.width) {
        size.width = size.height;
    }
    return size;
}

@end

@implementation KKNavigationBar

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    [self blurView];
    [self solidColorView];
    [self imageView];
    [self containerView];
    [self separator];
    [self titleLabel];
    [self setTitleView:[self titleLabel]];
    _margin             = NSEdgeInsetsMake(22, 16, 0, 16);
    _barHeight          = 37.0;
    _interitemSpacing   = 15.0;
    self.barStyle       = KKNavigationBarStyleSolidColor;
    
    for (NSString *keypath in [self observableKeypaths]) {
        [self addObserver:self forKeyPath:keypath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
}

- (NSArray *)observableKeypaths
{
    static NSArray *observableKeypaths = nil;
    if (observableKeypaths == nil) {
        observableKeypaths = @[@"backButton.title", @"backButton.hidden", @"backButton.attributedTitle", @"backButton.image", @"titleLabel.stringValue", @"titleLabel.attributedStringValue", @"titleLabel.font"];
    }
    return observableKeypaths;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    [self setNeedsLayout:YES];
}

- (NSVisualEffectView *)blurView
{
    if (_blurView == nil) {
        _blurView               = [NSVisualEffectView new];
        _blurView.state         = NSVisualEffectStateActive;
        _blurView.blendingMode  = NSVisualEffectBlendingModeWithinWindow;
        _blurView.hidden        = YES;
        [self addSubview:_blurView];
    }
    return _blurView;
}

- (NSView *)solidColorView
{
    if (_solidColorView == nil) {
        _solidColorView             = [NSView new];
        _solidColorView.wantsLayer  = YES;
        _solidColorView.layer.backgroundColor = NSColor.clearColor.CGColor;
        _solidColorView.hidden      = YES;
        [self addSubview:_solidColorView];
    }
    return _solidColorView;
}

- (NSImageView *)imageView
{
    if (_imageView == nil) {
        _imageView                  = [NSImageView new];
        _imageView.imageScaling     = NSImageScaleAxesIndependently;
        _imageView.imageFrameStyle  = NSImageFrameNone;
        _imageView.hidden           = YES;
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (NSView *)backgroundView
{
    switch (self.barStyle) {
        case KKNavigationBarStyleBlur: {
            return self.blurView;
        }
        case KKNavigationBarStyleSolidColor: {
            return self.solidColorView;
        }
        case KKNavigationBarStyleImage: {
            return self.imageView;
        }
        default: {
            return nil;
        }
    }
    return nil;
}

- (NSView *)containerView
{
    if (_containerView == nil) {
        _containerView              = [NSView new];
        _containerView.wantsLayer   = YES;
        _containerView.layer.backgroundColor    = NSColor.clearColor.CGColor;
        [self addSubview:_containerView];
    }
    return _containerView;
}

- (NSButton *)backButton
{
    if (_backButton == nil) {
        _backButton                     = [KKNavigationBarBackButton new];
        [_backButton setButtonType:NSButtonTypeMomentaryPushIn];
        _backButton.title               = @"";
        _backButton.bezelStyle          = NSBezelStyleRegularSquare;
        _backButton.bordered            = NO;
        _backButton.wantsLayer          = YES;
        _backButton.imagePosition       = NSImageOnly;
        _backButton.imageScaling        = NSImageScaleNone;
        _backButton.image               = [NSImage imageNamed:NSImageNameGoLeftTemplate];
        _backButton.ignoresMultiClick   = YES;
        _backButton.target              = self;
        _backButton.action              = @selector(backButtonClick:);
        [self.containerView addSubview:_backButton];
    }
    return _backButton;
}

- (void)setBackButtonTitle:(NSString *)backButtonTitle
{
    self.backButton.title = backButtonTitle;
    self.backButton.imagePosition = backButtonTitle.length > 0 ? NSImageLeft : NSImageOnly;
}

- (NSString *)backButtonTitle
{
    return self.backButton.title;
}

- (void)backButtonClick:(NSButton *)sender
{
    [self.superview popViewControllerAnimated:YES];
}

- (NSTextField *)titleLabel
{
    if (_titleLabel == nil) {
        _titleLabel                     = [NSTextField new];
        _titleLabel.font                = [NSFont systemFontOfSize:14];
        _titleLabel.editable            = NO;
        _titleLabel.selectable          = NO;
        _titleLabel.bordered            = NO;
        _titleLabel.drawsBackground     = NO;
        _titleLabel.backgroundColor     = [NSColor clearColor];
        _titleLabel.focusRingType       = NSFocusRingTypeNone;
        _titleLabel.bezelStyle          = NSTextFieldSquareBezel;
        _titleLabel.lineBreakMode       = NSLineBreakByTruncatingTail;
        _titleLabel.cell.scrollable     = NO;
        _titleLabel.wantsLayer          = YES;
        _titleLabel.layer.backgroundColor = [NSColor clearColor].CGColor;
    }
    return _titleLabel;
}

- (void)setTitleView:(NSView *)titleView
{
    if (_titleView) {
        [_titleView removeFromSuperview];
    }
    _titleView = titleView;
    [self.containerView addSubview:titleView];
    [self setNeedsLayout:YES];
}

- (NSView *)separator
{
    if (_separator == nil) {
        _separator              = [NSView new];
        _separator.wantsLayer   = YES;
        _separator.hidden       = YES;
        _separator.layer.backgroundColor = [NSColor colorWithWhite:0 alpha:0.1].CGColor;
        [self addSubview:_separator];
    }
    return _separator;
}

- (void)setLeftBarButtonItems:(NSArray *)leftBarButtonItems
{
    if (_leftBarButtonItems.count > 0) {
        for (NSView *view in _leftBarButtonItems) {
            [view removeFromSuperview];
        }
    }
    _leftBarButtonItems = leftBarButtonItems.copy;
    for (NSView *view in leftBarButtonItems) {
        [self.containerView addSubview:view];
    }
    [self setNeedsLayout:YES];
}

- (void)setRightBarButtonItems:(NSArray *)rightBarButtonItems
{
    if (_rightBarButtonItems.count > 0) {
        for (NSView *view in _rightBarButtonItems) {
            [view removeFromSuperview];
        }
    }
    _rightBarButtonItems = rightBarButtonItems.copy;
    for (NSView *view in rightBarButtonItems) {
        [self.containerView addSubview:view];
    }
    [self setNeedsLayout:YES];
}

- (void)setLeftBarButtonItem:(NSView *)leftBarButtonItem
{
    self.leftBarButtonItems = nil;
    if (leftBarButtonItem) {
        self.leftBarButtonItems = @[leftBarButtonItem];
    }
}

- (NSView *)leftBarButtonItem
{
    return self.leftBarButtonItems.firstObject;
}

- (void)setRightBarButtonItem:(NSView *)rightBarButtonItem
{
    self.rightBarButtonItems = nil;
    if (rightBarButtonItem) {
        self.rightBarButtonItems = @[rightBarButtonItem];
    }
}

- (void)setBarStyle:(KKNavigationBarStyle)barStyle
{
    _barStyle = barStyle;
    self.blurView.hidden        = barStyle != KKNavigationBarStyleBlur;
    self.solidColorView.hidden  = barStyle != KKNavigationBarStyleSolidColor;
    self.imageView.hidden       = barStyle != KKNavigationBarStyleImage;
}

- (void)setMargin:(NSEdgeInsets)margin
{
    _margin = margin;
    [self setNeedsLayout:YES];
}

- (void)setBarHeight:(CGFloat)barHeight
{
    _barHeight = barHeight;
    [self setNeedsLayout:YES];
}

- (void)setInteritemSpacing:(CGFloat)interitemSpacing
{
    _interitemSpacing = interitemSpacing;
    [self setNeedsLayout:YES];
}

- (void)setMellowBackButton:(BOOL)mellowBackButton
{
    self.backButton.bezelStyle  = mellowBackButton ? NSBezelStyleTexturedRounded : NSBezelStyleRegularSquare;
    self.backButton.bordered    = mellowBackButton ? YES : NO;
}

- (BOOL)mellowBackButton
{
    return self.backButton.bezelStyle == NSBezelStyleTexturedRounded && self.backButton.isBordered;
}

- (NSSize)intrinsicContentSize
{
    return CGSizeMake(self.superview.frame.size.width, self.margin.top + self.margin.bottom + self.barHeight);
}

- (void)layout
{
    [super layout];
    [self layoutBarSubviews];
}

- (void)layoutBarSubviews
{
    self.solidColorView.frame   =
    self.blurView.frame         =
    self.imageView.frame        = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    
    self.containerView.frame    =
    CGRectMake(0, self.isFlipped ? self.margin.top : self.margin.bottom, self.frame.size.width, self.frame.size.height - self.margin.top - self.margin.bottom);
    
    CGSize containerSize        = self.containerView.frame.size;
    
    NSMutableArray *leftButtons = NSMutableArray.new;
    if (self.backButton.isHidden == NO && self.backButton.superview == self.containerView) {
        [leftButtons addObject:self.backButton];
    }
    [leftButtons addObjectsFromArray:self.leftBarButtonItems];
    CGFloat leftButtonX = self.margin.left;
    for (NSControl *button in leftButtons) {
        if (button.isHidden || button.superview != self.containerView) {
            continue;;
        }
        CGSize size     = [button intrinsicContentSize];
        if (CGSizeEqualToSize(size, CGSizeZero)) {
            size        = CGSizeMake(containerSize.height, containerSize.height);
        }
        button.frame    = CGRectMake(leftButtonX, (containerSize.height - size.height) * 0.5, size.width, size.height);
        leftButtonX     = CGRectGetMaxX(button.frame) + self.interitemSpacing;
    }
    
    CGFloat rightButtonMaxX = containerSize.width - self.margin.right;
    for (NSControl *button in self.rightBarButtonItems) {
        if (button.isHidden || button.superview != self.containerView) {
            continue;;
        }
        CGSize size     = button.frame.size;
        if ([button isKindOfClass:[NSControl class]]) {
            size        = [button intrinsicContentSize];
        } else if (CGSizeEqualToSize(size, CGSizeZero)) {
            size        = CGSizeMake(containerSize.height, containerSize.height);
        }
        button.frame    = CGRectMake(rightButtonMaxX - size.width, (containerSize.height - size.height) * 0.5, size.width, size.height);
        rightButtonMaxX = CGRectGetMinX(button.frame) - self.interitemSpacing;
    }
    
    NSTextField *titleView  = (NSTextField *)self.titleView;
    CGSize titleViewSize    = titleView.frame.size;
    if ([titleView isKindOfClass:[NSTextField class]]) {
        titleViewSize       = [titleView sizeThatFits:CGSizeMake(FLT_MAX, FLT_MAX)];
    } else {
        titleViewSize       = [titleView intrinsicContentSize];
    }
    CGFloat maxTitleViewWidth = rightButtonMaxX - self.interitemSpacing * 2 - leftButtonX;
    if (titleViewSize.width == 0 || titleViewSize.width > maxTitleViewWidth) {
        titleViewSize       = CGSizeMake(maxTitleViewWidth, titleViewSize.height);
    }
    if (titleViewSize.height == 0 || titleViewSize.height > containerSize.height) {
        titleViewSize       = CGSizeMake(titleViewSize.width, containerSize.height);
    }
    self.titleView.frame    = CGRectMake((containerSize.width - titleViewSize.width) * 0.5, (containerSize.height - titleViewSize.height) * 0.5, titleViewSize.width, titleViewSize.height);
    
    self.separator.frame    = CGRectMake(0, self.containerView.isFlipped ? self.frame.size.height - 1 : 0, containerSize.width, 1);
}

- (void)dealloc
{
    for (NSString *keypath in [self observableKeypaths]) {
        [self removeObserver:self forKeyPath:keypath];
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

- (void)setNavigationBar:(KKNavigationBar *)navigationBar
{
    objc_setAssociatedObject(self, @selector(navigationBar), navigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (KKNavigationBar *)navigationBar
{
    if ([self respondsToSelector:@selector(hasNavigationBar)] && self.hasNavigationBar == NO) {
        return nil;
    }
    KKNavigationBar *navigationBar = objc_getAssociatedObject(self, @selector(navigationBar));
    if (navigationBar == nil) {
        if ([self respondsToSelector:@selector(navigationBarClass)]) {
            navigationBar = [[self navigationBarClass] new];
        } else {
            navigationBar = [KKNavigationBar new];
        }
        [self setNavigationBar:navigationBar];
    }
    return navigationBar;
}

@end

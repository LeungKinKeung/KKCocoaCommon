//
//  KKNavigationBar.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/12/4.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKNavigationBar.h"

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
{
    CGFloat _barHeight;
}

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
    _padding            = NSEdgeInsetsMake(0, 16, 0, 16);
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

- (void)setBarPosition:(KKNavigationBarPosition)barPosition
{
    _barPosition = barPosition;
    [self.superview setNeedsLayout:YES];
}

- (void)setPadding:(NSEdgeInsets)padding
{
    _padding = padding;
    [self setNeedsLayout:YES];
}

- (void)setBarHeight:(CGFloat)barHeight
{
    _barHeight = barHeight;
    [self.superview setNeedsLayout:YES];
}

- (CGFloat)barHeight
{
    if (self.barPosition == KKNavigationBarPositionOverlaps) {
        return self.frame.size.height;
    }
    return _barHeight;
}

- (void)setInteritemSpacing:(CGFloat)interitemSpacing
{
    _interitemSpacing = interitemSpacing;
    [self setNeedsLayout:YES];
}

- (void)setMellowStyleButtons:(BOOL)mellowStyleButtons
{
    _mellowStyleButtons = mellowStyleButtons;
    
    NSMutableArray *buttons = [NSMutableArray array];
    if (self.backButton) {
        [buttons addObject:self.backButton];
    }
    if (self.leftBarButtonItems.count) {
        [buttons addObjectsFromArray:self.leftBarButtonItems];
    }
    if (self.rightBarButtonItems.count) {
        [buttons addObjectsFromArray:self.rightBarButtonItems];
    }
    for (NSButton *button in buttons) {
        if ([button isKindOfClass:[NSButton class]]) {
            button.bezelStyle  = mellowStyleButtons ? NSBezelStyleTexturedRounded : NSBezelStyleRegularSquare;
            button.bordered    = mellowStyleButtons ? YES : NO;
            [button sizeToFit];
        }
    }
    [self layoutBarSubviews];
}

- (NSSize)intrinsicContentSize
{
    return [self intrinsicContentSizeWithNavigationControllerView:self.superview];
}

- (CGSize)intrinsicContentSizeWithNavigationControllerView:(NSView *)navigationControllerView
{
    CGFloat navigationBarHeight = 0;
    switch (self.barPosition) {
        case KKNavigationBarPositionOverlaps: {
            navigationBarHeight =
            navigationControllerView.window.contentView.bounds.size.height - navigationControllerView.window.contentLayoutRect.size.height;
            break;
        }
        case KKNavigationBarPositionBelow: {
            CGFloat paddingTop = navigationControllerView.window.contentView.bounds.size.height - navigationControllerView.window.contentLayoutRect.size.height;
            navigationBarHeight = paddingTop + self.padding.bottom + self.barHeight;
            break;
        }
        default: {
            navigationBarHeight = self.padding.top + self.padding.bottom + self.barHeight;
            break;
        }
    }
    NSCellImagePosition x =0;
    return CGSizeMake(navigationControllerView.frame.size.width, navigationBarHeight);
}

- (void)setFrame:(NSRect)frame
{
    [super setFrame:frame];
    
    [self layoutBarSubviews];
}

- (void)layout
{
    [super layout];
    [self layoutBarSubviews];
}

- (void)viewDidMoveToWindow
{
    [super viewDidMoveToWindow];
    [self layoutBarSubviews];
}

- (void)setFrameOrigin:(NSPoint)newOrigin
{
    [super setFrameOrigin:newOrigin];
    [self layoutBarSubviews];
}

- (void)layoutBarSubviews
{
    self.separator.frame    =
    CGRectMake(0, self.isFlipped ? self.frame.size.height : 0, self.frame.size.width, 1);
    
    NSButton *windowButton      = [self.window standardWindowButton:NSWindowZoomButton];
    if (windowButton == nil) {
        windowButton = [self.window standardWindowButton:NSWindowMiniaturizeButton];
    }
    if (windowButton == nil) {
        windowButton = [self.window standardWindowButton:NSWindowCloseButton];
    }
    CGRect windowButtonFrame    = [windowButton convertRect:windowButton.bounds toView:nil];
    CGRect navigationBarFrame   = [self convertRect:self.bounds toView:nil];
    BOOL directionLeftToRight   = YES;
    if (@available(macOS 10.12, *)) {
        directionLeftToRight    = [self.window windowTitlebarLayoutDirection] == NSUserInterfaceLayoutDirectionLeftToRight;
    }
    BOOL isOverlaps             = self.barPosition == KKNavigationBarPositionOverlaps;
    BOOL isBelow                = self.barPosition == KKNavigationBarPositionBelow;
    NSEdgeInsets padding        = NSEdgeInsetsMake(0, 0, 0, 0);
    if (isOverlaps) {
        padding.top             = 0;
    } else if (isBelow) {
        padding.top             = self.window.contentView.bounds.size.height - self.window.contentLayoutRect.size.height;
    } else {
        padding.top             = self.padding.top;
    }
    CGFloat containerViewY      = isOverlaps ? 0 : (self.isFlipped ? padding.top : self.padding.bottom);
    CGFloat containerViewHeight = isOverlaps ? self.frame.size.height : (self.frame.size.height - padding.top - self.padding.bottom);
    if (directionLeftToRight) {
        CGFloat windowButtonMaxX    = CGRectGetMaxX(windowButtonFrame);
        CGFloat navigationBarMinX   = CGRectGetMinX(navigationBarFrame);
        padding.left                = self.padding.left + (windowButtonMaxX > navigationBarMinX ? (windowButtonMaxX - navigationBarMinX) : 0);
        padding.right               = self.padding.right;
    } else {
        CGFloat windowButtonMinX    = CGRectGetMinX(windowButtonFrame);
        CGFloat navigationBarMaxX   = CGRectGetMaxX(navigationBarFrame);
        padding.left                = self.padding.left;
        padding.right               = self.padding.right + (windowButtonMinX < navigationBarMaxX ? (navigationBarMaxX - windowButtonMinX) : 0);
    }
    CGFloat containerViewWidth  = self.frame.size.width - padding.left - padding.right;
    
    if (containerViewWidth <= 0) {
        return;
    }
    
    CGRect barFrame             = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.solidColorView.frame   = barFrame;
    self.blurView.frame         = barFrame;
    self.imageView.frame        = barFrame;
    self.containerView.frame    = CGRectMake(padding.left, containerViewY, containerViewWidth, containerViewHeight);
    CGSize containerSize        = self.containerView.frame.size;
    NSMutableArray *leftButtons = NSMutableArray.new;
    if (self.backButton.isHidden == NO && self.backButton.superview == self.containerView) {
        [leftButtons addObject:self.backButton];
    }
    [leftButtons addObjectsFromArray:self.leftBarButtonItems];
    CGFloat nextLeftButtonX = 0;
    for (NSControl *button in leftButtons) {
        if (button.isHidden || button.superview != self.containerView) {
            continue;;
        }
        CGSize size     = [button intrinsicContentSize];
        if (CGSizeEqualToSize(size, CGSizeZero)) {
            size        = CGSizeMake(containerSize.height, containerSize.height);
        }
        button.frame    = CGRectMake(nextLeftButtonX, (containerSize.height - size.height) * 0.5, size.width, size.height);
        nextLeftButtonX = CGRectGetMaxX(button.frame) + self.interitemSpacing;
    }
    
    CGFloat nextRightButtonMaxX = containerSize.width;
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
        button.frame    = CGRectMake(nextRightButtonMaxX - size.width, (containerSize.height - size.height) * 0.5, size.width, size.height);
        nextRightButtonMaxX = CGRectGetMinX(button.frame) - self.interitemSpacing;
    }
    
    NSTextField *titleView  = (NSTextField *)self.titleView;
    CGSize titleViewSize    = titleView.frame.size;
    if ([titleView isKindOfClass:[NSTextField class]]) {
        // 不准确
        titleViewSize = [titleView sizeThatFits:CGSizeMake(FLT_MAX, FLT_MAX)];
    } else {
        titleViewSize       = [titleView intrinsicContentSize];
    }
    
    CGFloat titleViewMaxX       = nextRightButtonMaxX;
    CGFloat titleViewMinX       = nextLeftButtonX;
    CGFloat maxTitleViewWidth   = titleViewMaxX - titleViewMinX;
    if (titleViewSize.width == 0 || titleViewSize.width > maxTitleViewWidth) {
        titleViewSize       = CGSizeMake(maxTitleViewWidth, titleViewSize.height);
    }
    if (titleViewSize.height == 0 || titleViewSize.height > containerSize.height) {
        titleViewSize       = CGSizeMake(titleViewSize.width, containerSize.height);
    }
    CGFloat titleViewX      = (self.frame.size.width - titleViewSize.width) * 0.5 - padding.left;
    CGFloat titleViewY      = (containerSize.height - titleViewSize.height) * 0.5;
    CGRect titleViewFrame   = CGRectMake(titleViewX, titleViewY, titleViewSize.width, titleViewSize.height);
    if (titleViewMaxX - CGRectGetMaxX(titleViewFrame) < 0) {
        titleViewFrame.origin.x     =
        titleViewX - (CGRectGetMaxX(titleViewFrame) - titleViewMaxX);
    }
    if (CGRectGetMinX(titleViewFrame) - titleViewMinX < 0) {
        titleViewFrame.size.width   =
        titleViewFrame.size.width - (titleViewMinX - CGRectGetMinX(titleViewFrame));
        titleViewFrame.origin.x     = titleViewMinX;
    }
    
    self.titleView.frame    = titleViewFrame;
}

- (void)dealloc
{
    for (NSString *keypath in [self observableKeypaths]) {
        [self removeObserver:self forKeyPath:keypath];
    }
}

@end


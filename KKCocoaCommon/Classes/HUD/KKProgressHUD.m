//
//  KKProgressHUD.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKProgressHUD.h"
#import "NSView+KKAnimation.h"

static NSString *kStringValueKey = @"stringValue";
static NSString *kAttributedStringValueKey = @"attributedStringValue";

@interface KKHUDFlippedVisualEffectView : NSVisualEffectView

@end

@implementation KKHUDFlippedVisualEffectView

- (BOOL)isFlipped
{
    return YES;
}

@end

@interface KKHUDFlippedBackgroundView : NSView

@end

@implementation KKHUDFlippedBackgroundView

- (BOOL)isFlipped
{
    return YES;
}

@end

@interface KKProgressIndicator : NSProgressIndicator

@end

@implementation KKProgressIndicator

- (NSSize)intrinsicContentSize
{
    NSSize size     = [super intrinsicContentSize];
    if (self.style == NSProgressIndicatorStyleBar) {
        size.width  = 200;
    }
    return size;
}

@end

@interface KKProgressHUD ()

@property (nonatomic, weak) NSScreen *currentScreen;
@property (nonatomic, strong) NSWindowController *windowController;
@property (nonatomic, strong) NSView *solidColorView;
@property (nonatomic, readonly) NSView *containerView;

@end

@implementation KKProgressHUD

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
    self.layerBackgroundColor   = NSColor.clearColor;
    _margin         = 24;
    _lineSpacing    = 10;
    _maxLayoutWidth = 296;
    _square         = YES;
    self.mode       = KKProgressHUDModeIndeterminate;
}

+ (instancetype)showHUDAddedTo:(id)target mode:(KKProgressHUDMode)mode title:(NSString *)title animated:(BOOL)animated
{
    KKProgressHUD *hud = [KKProgressHUD hud];
    hud.mode            = mode;
    if (title != nil) {
        hud.label.text  = title;
    }
    [hud addedTo:target animated:animated];
    return hud;
}

+ (instancetype)showTextHUDAddedTo:(_Nullable id)target title:(NSString *)title hideAfterDelay:(NSTimeInterval)delay animated:(BOOL)animated
{
    KKProgressHUD *hud = [self showHUDAddedTo:target mode:KKProgressHUDModeText title:title animated:animated];
    [hud hideAnimated:delay afterDelay:delay];
    return hud;
}

+ (instancetype)showHUDAddedTo:(id)target animated:(BOOL)animated
{
    return [self showHUDAddedTo:target mode:KKProgressHUDModeIndeterminate title:nil animated:animated];
}

+ (instancetype)hud
{
    return [[self alloc] initWithFrame:CGRectMake(0, 0, 296, 40)];
}

- (void)addedTo:(id)target animated:(BOOL)animated
{
    if (self.superview != nil) {
        [self removeFromSuperview];
    }
    if (target == nil) {
        target = [NSScreen mainScreen];
    }
    if ([target isKindOfClass:[NSScreen class]]) {
        [self addedToScreen:target animated:animated];
    } else {
        NSView *superview   = nil;
        if ([target isKindOfClass:[NSView class]]) {
            superview       = target;
        } else if ([target isKindOfClass:[NSWindow class]]) {
            superview       = ((NSWindow *)target).contentView;
        } else if ([target isKindOfClass:[NSWindowController class]]) {
            superview       = ((NSWindowController *)target).window.contentView;
        } else if ([target isKindOfClass:[NSViewController class]]) {
            superview       = ((NSViewController *)target).view;
        }
        [self addedToView:superview animated:animated];
    }
}

- (void)addedToScreen:(NSScreen *)screen animated:(BOOL)animated
{
    NSWindow *window        = [[NSWindow alloc] initWithContentRect:CGRectZero styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:YES screen:screen];
    self.windowController   = [[NSWindowController alloc] initWithWindow:window];
    window.opaque           = YES;
    window.backgroundColor  = NSColor.clearColor;
    window.level            = NSFloatingWindowLevel;
    window.contentView      = self;
    
    [self layoutContainerViewSubviews];
    [self setFrame:self.containerView.bounds];
    
    self.wantsLayer             = YES;
    self.layer.cornerRadius     = 6.0;
    self.layer.masksToBounds    = YES;
    //self.containerView.blendingMode  = NSVisualEffectBlendingModeBehindWindow;
    self.currentScreen          = screen;
    [self.windowController showWindow:nil];
}

- (void)viewWillDraw
{
    [super viewWillDraw];
    if (self.windowController) {
        [self updateWindowFrame];
    } else {
        [self setNeedsLayout:YES];
    }
}

- (void)updateWindowFrame
{
    [self layoutContainerViewSubviews];
    CGSize containerViewSize = self.containerView.frame.size;
    if (CGSizeEqualToSize(self.windowController.window.frame.size, containerViewSize)) {
        return;
    }
    NSScreen *screen    = self.currentScreen;
    CGRect windowFrame  = CGRectMake((screen.frame.size.width - containerViewSize.width) * 0.5, (screen.frame.size.height - containerViewSize.height) * 0.5 - screen.frame.size.height * 0.2, containerViewSize.width, containerViewSize.height);
    [self.windowController.window setFrame:windowFrame display:YES];
    [self layoutContainerView];
}

- (void)addedToView:(NSView *)view animated:(BOOL)animated
{
    [view addSubview:self];
    // 停止所有的编辑（editing）和聚焦（focus）
    [view.window makeFirstResponder:nil];
    
    self.containerView.wantsLayer            = YES;
    self.containerView.layer.cornerRadius    = 6.0;
    self.containerView.layer.masksToBounds   = YES;
    //self.containerView.blendingMode          = NSVisualEffectBlendingModeWithinWindow;
    //self.containerView.state         = NSVisualEffectStateFollowsWindowActiveState;
    
    NSShadow *shadow        = [[NSShadow alloc] init];
    shadow.shadowColor      = [NSColor colorWithWhite:0.5 alpha:0.5];
    shadow.shadowOffset     = NSMakeSize(0, 0);
    shadow.shadowBlurRadius = 5;
    self.shadow             = shadow;
    
    self.frame              = view.bounds;
    self.autoresizingMask   = NSViewWidthSizable | NSViewHeightSizable;
    
    if (animated) {
        self.alphaValue = 0;
        [NSView animateWithDuration:0.2 animations:^{
            self.alphaValue = 1;
        } completion:nil];
    }
}

- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay
{
    if (delay) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hideAnimated:animated];
        });
    } else {
        [self hideAnimated:animated];
    }
}

- (void)hideAnimated:(BOOL)animated
{
    if (animated) {
        [NSView animateWithDuration:0.2 animations:^{
            self.alphaValue = 0;
        } completion:^{
            [self remove];
        }];
    } else {
        [self remove];
    }
}

- (void)remove
{
    [self removeFromSuperview];
    
    if (self.windowController) {
        [self.windowController.window close];
    }
}

+ (void)hideHUDForView:(NSView *)view animated:(BOOL)animated
{
    [[self HUDForView:view] hideAnimated:animated];
}

+ (nullable KKProgressHUD *)HUDForView:(NSView *)view
{
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (NSView *subview in subviewsEnum) {
        if ([subview isKindOfClass:self]) {
            return (KKProgressHUD *)subview;
        }
    }
    return nil;
}

- (NSVisualEffectView *)blurView
{
    if (_blurView == nil) {
        _blurView = [KKHUDFlippedVisualEffectView new];
        _blurView.state = NSVisualEffectStateActive;
        [self addSubview:_blurView];
    }
    return _blurView;
}

- (NSView *)solidColorView
{
    if (_solidColorView == nil) {
        _solidColorView = [KKHUDFlippedBackgroundView new];
        _solidColorView.wantsLayer = YES;
        _solidColorView.layer.backgroundColor = [NSColor colorWithWhite:1 alpha:0.9].CGColor;
        [self addSubview:_solidColorView];
    }
    return _solidColorView;
}

- (NSView *)containerView
{
    return self.solidColorView;
}

- (NSProgressIndicator *)progressIndicator
{
    if (_progressIndicator == nil) {
        _progressIndicator = [KKProgressIndicator new];
        _progressIndicator.controlSize  = NSControlSizeRegular;
        _progressIndicator.minValue     = 0.0;
        _progressIndicator.maxValue     = 1.0;
        [self.containerView addSubview:_progressIndicator];
    }
    return _progressIndicator;
}

- (NSTextField *)label
{
    if (_label == nil) {
        _label              = [NSTextField label];
        _label.alignment    = NSTextAlignmentCenter;
        _label.font         = [NSFont systemFontOfSize:18];
        _label.lineBreakMode= NSLineBreakByWordWrapping;
        [self.containerView addSubview:_label];
        [_label addObserver:self forKeyPath:kStringValueKey options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_label addObserver:self forKeyPath:kAttributedStringValueKey options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return _label;
}

- (NSTextField *)detailsLabel
{
    if (_detailsLabel == nil) {
        _detailsLabel           = [NSTextField label];
        _detailsLabel.alignment = NSTextAlignmentCenter;
        _detailsLabel.font      = [NSFont systemFontOfSize:14];
        _detailsLabel.alphaValue= 0.8;
        _detailsLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [_detailsLabel addObserver:self forKeyPath:kStringValueKey options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [_detailsLabel addObserver:self forKeyPath:kAttributedStringValueKey options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [self.containerView addSubview:_detailsLabel];
    }
    return _detailsLabel;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (self.windowController != nil) {
        [self updateWindowFrame];
    } else {
        [self layoutContainerViewSubviews];
        [self layoutContainerView];
    }
}

- (void)setCustomView:(NSView *)customView
{
    if (customView != nil) {
        [customView removeFromSuperview];
    }
    _customView = customView;
    if (customView != nil)
    {
        [self.containerView addSubview:customView];
    }
    if (self.windowController != nil) {
        [self updateWindowFrame];
    } else {
        [self setNeedsLayout:YES];
    }
}

- (void)layoutContainerViewSubviews
{
    CGFloat maxLayoutWidth  = self.maxLayoutWidth;
    CGFloat maxSubviewWidth = 0;
    CGFloat margin          = self.margin;
    CGFloat lineSpacing     = self.lineSpacing;
    CGFloat topSpacing      = margin - lineSpacing;
    BOOL isSquare           = self.isSquare;
    if (self.windowController == nil && self.superview && self.superview.frame.size.width < maxLayoutWidth) {
        maxLayoutWidth      = self.superview.frame.size.width;
    }
    
    CGRect progressIndicatorFrame   = CGRectZero;
    CGRect customViewFrame          = CGRectZero;
    CGRect labelFrame               = CGRectZero;
    CGRect detailsLabelFrame        = CGRectZero;
    
    if (self.mode == KKProgressHUDModeDeterminate ||
        self.mode == KKProgressHUDModeIndeterminate ||
        self.mode == KKProgressHUDModeDeterminateHorizontalBar) {
        if (self.progressIndicator.superview == nil) {
            [self.containerView addSubview:self.progressIndicator];
        }
        self.progressIndicator.style            =
        self.mode == KKProgressHUDModeDeterminateHorizontalBar ?
        NSProgressIndicatorStyleBar :
        NSProgressIndicatorStyleSpinning;
        
        self.progressIndicator.indeterminate    = self.mode == KKProgressHUDModeIndeterminate;
        
        if (self.mode == KKProgressHUDModeIndeterminate) {
            [self.progressIndicator startAnimation:nil];
        } else {
            [self.progressIndicator stopAnimation:nil];
        }
        CGSize size             = [self.progressIndicator intrinsicContentSize];
        progressIndicatorFrame  = CGRectMake(0, topSpacing + lineSpacing, size.width, size.height);
        topSpacing              = CGRectGetMaxY(progressIndicatorFrame);
        maxSubviewWidth         = MAX(maxSubviewWidth, size.width);
    } else {
        if (self.progressIndicator.superview != nil) {
            [self.progressIndicator removeFromSuperview];
        }
        if (self.mode == KKProgressHUDModeText &&
            self.customView != nil &&
            self.customView.superview != nil) {
            [self.customView removeFromSuperview];
        }
    }
    if (self.customView != nil && self.customView.superview != nil) {
        CGSize size = self.customView.frame.size;
        if ([self.customView isKindOfClass:[NSControl class]]) {
            NSControl *control  = (NSControl *)self.customView;
            size = [control intrinsicContentSize];
        } else if (size.width == 0 || size.height == 0) {
            size = CGSizeMake(37, 37);
        }
        customViewFrame         = CGRectMake(0, topSpacing + lineSpacing, size.width, size.height);
        topSpacing              = CGRectGetMaxY(customViewFrame);
        maxSubviewWidth         = MAX(maxSubviewWidth, size.width);
    }
    if (_label != nil && _label.superview != nil && _label.isHidden == NO) {
        CGSize size             = [_label sizeThatFits:CGSizeMake(maxLayoutWidth - margin * 2, FLT_MAX)];
        labelFrame              = CGRectMake(0, topSpacing + lineSpacing, size.width, size.height);
        topSpacing              = CGRectGetMaxY(labelFrame);
        maxSubviewWidth         = MAX(maxSubviewWidth, size.width);
    }
    if (_detailsLabel != nil && _detailsLabel.superview != nil && _detailsLabel.isHidden == NO) {
        CGSize size             = [_detailsLabel sizeThatFits:CGSizeMake(maxLayoutWidth - margin * 2, FLT_MAX)];
        detailsLabelFrame       = CGRectMake(0, topSpacing + lineSpacing, size.width, size.height);
        topSpacing              = CGRectGetMaxY(detailsLabelFrame);
        maxSubviewWidth         = MAX(maxSubviewWidth, size.width);
    }
    CGFloat containerViewWidth       = MIN(maxLayoutWidth, maxSubviewWidth) + margin * 2;
    CGFloat containerViewHeigth      = topSpacing + margin;
    if (isSquare && containerViewWidth < containerViewHeigth) {
        containerViewWidth           = containerViewHeigth;
    }
    self.containerView.frame         = CGRectMake(0, 0, containerViewWidth, containerViewHeigth);
    CGFloat containerWidth      = self.containerView.frame.size.width;
    
    if (CGRectIsEmpty(progressIndicatorFrame) == NO) {
        progressIndicatorFrame.origin.x = (containerWidth - progressIndicatorFrame.size.width) * 0.5;
        self.progressIndicator.frame    = progressIndicatorFrame;
    }
    if (CGRectIsEmpty(customViewFrame) == NO) {
        customViewFrame.origin.x    = (containerWidth - customViewFrame.size.width) * 0.5;
        self.customView.frame       = customViewFrame;
    }
    if (CGRectIsEmpty(labelFrame) == NO) {
        labelFrame.origin.x         = (containerWidth - labelFrame.size.width) * 0.5;
        self.label.frame            = labelFrame;
    }
    if (CGRectIsEmpty(detailsLabelFrame) == NO) {
        detailsLabelFrame.origin.x  = (containerWidth - detailsLabelFrame.size.width) * 0.5;
        self.detailsLabel.frame     = detailsLabelFrame;
    }
}

- (void)layoutContainerView
{
    CGSize selfSize     = self.frame.size;
    CGSize containerViewSize = self.containerView.frame.size;
    self.containerView.frame = CGRectMake((selfSize.width - containerViewSize.width) * 0.5 + self.centerOffset.x,
                                     (selfSize.height - containerViewSize.height) * 0.5 + self.centerOffset.y,
                                     containerViewSize.width,
                                     containerViewSize.height);
}

- (void)layout
{
    [super layout];
    [self layoutContainerViewSubviews];
    [self layoutContainerView];
}

- (void)setProgress:(double)progress
{
    self.progressIndicator.doubleValue = progress;
}

- (double)progress
{
    return self.progressIndicator.doubleValue;
}

#pragma mark - 拦截鼠标事件
- (void)updateTrackingAreas
{
    [super updateTrackingAreas];
    
    NSTrackingAreaOptions options =
    NSTrackingMouseEnteredAndExited |
    NSTrackingMouseMoved |
    NSTrackingActiveAlways;
    
    [self updateTrackingAreasWithOptions:options];
}

- (void)mouseExited:(NSEvent *)event
{
    
}
- (void)mouseEntered:(NSEvent *)event
{
    
}
- (void)mouseUp:(NSEvent *)event
{
    
}
- (void)mouseDown:(NSEvent *)event
{
    
}

- (void)dealloc
{
    if (_label) {
        [_label removeObserver:self forKeyPath:kStringValueKey];
        [_label removeObserver:self forKeyPath:kAttributedStringValueKey];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

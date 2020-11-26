//
//  KKProgressHUD.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKProgressHUD.h"
#import "NSView+KKAnimation.h"

static NSString *const kEffectiveAppearanceKey      = @"effectiveAppearance";
static KKProgressHUDBackgroundStyle gDefaultStyle   = KKProgressHUDBackgroundStyleBlur;
static CGFloat gShowAnimationDuration       = 0.2;
static CGFloat gScaleAnimationDuration      = 0.1;
static NSColor *gDefaultBackgroundColor     = nil;
static NSFont *gDefaultLabelFont            = nil;
static NSFont *gDefaultDetailLabelFont      = nil;

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
@property (nonatomic, strong) NSVisualEffectView *blurView;
@property (nonatomic, strong) NSView *solidColorView;
@property (nonatomic, readonly) NSView *containerView;
@property (nonatomic, assign, getter=isViewAppeared) BOOL viewAppeared;

@end

@implementation KKProgressHUD

+ (void)initialize
{
    gDefaultLabelFont       = [NSFont systemFontOfSize:16];
    gDefaultDetailLabelFont = [NSFont systemFontOfSize:14];;
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
    self.layerBackgroundColor   = NSColor.clearColor;
    _margin             = 24;
    _interitemSpacing   = 10;
    _maxLayoutWidth     = 296;
    _square             = YES;
    _mode               = KKProgressHUDModeIndeterminate;
    
    for (NSString *keypath in [self observableKeypaths]) {
        [self addObserver:self forKeyPath:keypath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
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

+ (instancetype)showLoadingTextHUDAddedTo:(_Nullable id)target title:(NSString *)title animated:(BOOL)animated
{
    KKProgressHUD *hud      = [self showHUDAddedTo:target mode:KKProgressHUDModeLoadingText title:title animated:animated];
    hud.margin              = 10;
    hud.interitemSpacing    = 5;
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
    self.blurView.blendingMode  = NSVisualEffectBlendingModeBehindWindow;
    self.currentScreen          = screen;
    self.style                  = gDefaultStyle;
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
    self.viewAppeared = YES;
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
    
    CGPoint winOrigin   = self.windowController.window.frame.origin;
    CGFloat duration    =
    CGPointEqualToPoint(winOrigin, CGPointZero) ? 0 : gScaleAnimationDuration;
    
    [NSView animateWithDuration:duration animations:^{
        [self.windowController.window setFrame:windowFrame display:YES];
        [self layoutContainerView];
    } completion:nil];
}

- (void)addedToView:(NSView *)view animated:(BOOL)animated
{
    [view addSubview:self];
    // 停止所有的编辑（editing）和聚焦（focus）
    [view.window makeFirstResponder:nil];
    
    self.blurView.blendingMode  = NSVisualEffectBlendingModeWithinWindow;
    self.style              = gDefaultStyle;
    
    NSShadow *shadow        = [[NSShadow alloc] init];
    shadow.shadowColor      = [NSColor colorWithWhite:0 alpha:0.3];
    shadow.shadowOffset     = NSMakeSize(0, 0);
    shadow.shadowBlurRadius = 5;
    self.shadow             = shadow;
    
    self.frame              = view.bounds;
    self.autoresizingMask   = NSViewWidthSizable | NSViewHeightSizable;
    
    if (animated) {
        self.alphaValue = 0;
        [NSView animateWithDuration:gShowAnimationDuration animations:^{
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
        [NSView animateWithDuration:gShowAnimationDuration animations:^{
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
        _solidColorView.layer.backgroundColor = NSColor.clearColor.CGColor;
        [self addSubview:_solidColorView];
    }
    return _solidColorView;
}

- (NSView *)containerView
{
    return self.style == KKProgressHUDBackgroundStyleBlur ? self.blurView : self.solidColorView;
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
        _label.font         = gDefaultLabelFont;
        _label.lineBreakMode= NSLineBreakByWordWrapping;
        [self.containerView addSubview:_label];
    }
    return _label;
}

- (NSTextField *)detailsLabel
{
    if (_detailsLabel == nil) {
        _detailsLabel           = [NSTextField label];
        _detailsLabel.alignment = NSTextAlignmentCenter;
        _detailsLabel.font      = gDefaultDetailLabelFont;
        _detailsLabel.alphaValue= 0.8;
        _detailsLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.containerView addSubview:_detailsLabel];
    }
    return _detailsLabel;
}

- (NSArray *)observableKeypaths
{
    static NSArray *observableKeypaths = nil;
    if (observableKeypaths == nil) {
        observableKeypaths = @[@"label.stringValue", @"label.attributedStringValue", @"label.font", @"detailsLabel.stringValue", @"detailsLabel.attributedStringValue", @"detailsLabel.font", kEffectiveAppearanceKey];
    }
    return observableKeypaths;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:kEffectiveAppearanceKey]) {
        if (self.style == KKProgressHUDBackgroundStyleSolidColor) {
            self.containerView.layerBackgroundColor = [self getBackgroundColor];
        }
    } else {
        if (self.windowController != nil) {
            [self updateWindowFrame];
        } else {
            CGFloat duration = self.isViewAppeared ? gScaleAnimationDuration : 0;
            [NSView animateWithDuration:duration animations:^{
                [self layoutContainerViewSubviews];
                [self layoutContainerView];
            } completion:nil];
        }
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
    CGFloat subviewsSpacing = self.interitemSpacing;
    CGFloat topSpacing      = margin - subviewsSpacing;
    BOOL isSquare           = self.isSquare;
    if (self.windowController == nil && self.superview && self.superview.frame.size.width < maxLayoutWidth) {
        maxLayoutWidth      = self.superview.frame.size.width - 10;
    }
    
    CGRect progressIndicatorFrame   = CGRectZero;
    CGRect customViewFrame          = CGRectZero;
    CGRect labelFrame               = CGRectZero;
    CGRect detailsLabelFrame        = CGRectZero;
    
    if (self.mode == KKProgressHUDModeDeterminate ||
        self.mode == KKProgressHUDModeIndeterminate ||
        self.mode == KKProgressHUDModeDeterminateHorizontalBar ||
        self.mode == KKProgressHUDModeLoadingText) {
        if (self.progressIndicator.superview == nil) {
            [self.containerView addSubview:self.progressIndicator];
        }
        self.progressIndicator.style            =
        self.mode == KKProgressHUDModeDeterminateHorizontalBar ?
        NSProgressIndicatorStyleBar :
        NSProgressIndicatorStyleSpinning;
        
        self.progressIndicator.indeterminate    =
        self.mode == KKProgressHUDModeIndeterminate ||
        self.mode == KKProgressHUDModeLoadingText;
        
        if (self.mode == KKProgressHUDModeIndeterminate ||
            self.mode == KKProgressHUDModeLoadingText) {
            [self.progressIndicator startAnimation:nil];
        } else {
            [self.progressIndicator stopAnimation:nil];
        }
        if (self.mode == KKProgressHUDModeLoadingText &&
            self.progressIndicator.controlSize != NSControlSizeSmall) {
            self.progressIndicator.controlSize = NSControlSizeSmall;
        }
        if (self.mode != KKProgressHUDModeLoadingText &&
            self.progressIndicator.controlSize != NSControlSizeRegular) {
            self.progressIndicator.controlSize = NSControlSizeRegular;
        }
        CGSize size             = [self.progressIndicator intrinsicContentSize];
        progressIndicatorFrame  = CGRectMake(0, topSpacing + subviewsSpacing, size.width, size.height);
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
    if (self.mode != KKProgressHUDModeLoadingText &&
        self.customView != nil &&
        self.customView.superview != nil) {
        CGSize size = self.customView.frame.size;
        if ([self.customView isKindOfClass:[NSControl class]]) {
            NSControl *control  = (NSControl *)self.customView;
            size = [control intrinsicContentSize];
        } else if (size.width == 0 || size.height == 0) {
            size = CGSizeMake(37, 37);
        }
        customViewFrame         = CGRectMake(0, topSpacing + subviewsSpacing, size.width, size.height);
        topSpacing              = CGRectGetMaxY(customViewFrame);
        maxSubviewWidth         = MAX(maxSubviewWidth, size.width);
    }
    if (_label != nil &&
        _label.superview != nil &&
        _label.stringValue.length > 0 &&
        _label.isHidden == NO) {
        
        if (self.mode == KKProgressHUDModeLoadingText) {
            CGFloat maxWidth    = maxLayoutWidth - margin * 2 - progressIndicatorFrame.size.width;
            CGSize size         = [_label sizeThatFits:CGSizeMake(maxWidth, FLT_MAX)];
            labelFrame          = CGRectMake(0, margin, size.width, size.height);
            topSpacing          = MAX(CGRectGetMaxY(labelFrame), CGRectGetMaxY(progressIndicatorFrame));
            maxSubviewWidth     = size.width + subviewsSpacing + progressIndicatorFrame.size.width;
        } else {
            CGSize size         = [_label sizeThatFits:CGSizeMake(maxLayoutWidth - margin * 2, FLT_MAX)];
            labelFrame          = CGRectMake(0, topSpacing + subviewsSpacing, size.width, size.height);
            topSpacing          = CGRectGetMaxY(labelFrame);
            maxSubviewWidth     = MAX(maxSubviewWidth, size.width);
        }
    }
    if (self.mode != KKProgressHUDModeLoadingText &&
        _detailsLabel != nil &&
        _detailsLabel.superview != nil &&
        _detailsLabel.stringValue.length > 0 &&
        _detailsLabel.isHidden == NO) {
        CGSize size             = [_detailsLabel sizeThatFits:CGSizeMake(maxLayoutWidth - margin * 2, FLT_MAX)];
        detailsLabelFrame       = CGRectMake(0, topSpacing + subviewsSpacing, size.width, size.height);
        topSpacing              = CGRectGetMaxY(detailsLabelFrame);
        maxSubviewWidth         = MAX(maxSubviewWidth, size.width);
    }
    CGFloat containerWidth      = MIN(maxLayoutWidth, maxSubviewWidth) + margin * 2;
    CGFloat containerHeigth     = topSpacing + margin;
    if (isSquare && containerWidth < containerHeigth) {
        containerWidth          = containerHeigth;
    }
    self.containerView.frame    = CGRectMake(0, 0, containerWidth, containerHeigth);
    
    if (CGRectIsEmpty(progressIndicatorFrame) == NO) {
        if (self.mode == KKProgressHUDModeLoadingText) {
            progressIndicatorFrame.origin.x = margin;
            progressIndicatorFrame.origin.y = (containerHeigth - progressIndicatorFrame.size.height) * 0.5;
        } else {
            progressIndicatorFrame.origin.x = (containerWidth - progressIndicatorFrame.size.width) * 0.5;
        }
        _progressIndicator.frame    = progressIndicatorFrame;
    }
    if (CGRectIsEmpty(customViewFrame) == NO) {
        customViewFrame.origin.x    = (containerWidth - customViewFrame.size.width) * 0.5;
        _customView.frame           = customViewFrame;
    }
    if (CGRectIsEmpty(labelFrame) == NO) {
        if (self.mode == KKProgressHUDModeLoadingText) {
            labelFrame.origin.x     = CGRectGetMaxX(progressIndicatorFrame) + subviewsSpacing;
            labelFrame.origin.y     = (containerHeigth - labelFrame.size.height) * 0.5;
        } else {
            labelFrame.origin.x     = (containerWidth - labelFrame.size.width) * 0.5;
        }
        _label.frame                = labelFrame;
    }
    if (CGRectIsEmpty(detailsLabelFrame) == NO) {
        detailsLabelFrame.origin.x  = (containerWidth - detailsLabelFrame.size.width) * 0.5;
        _detailsLabel.frame         = detailsLabelFrame;
    }
}

- (void)layoutContainerView
{
    CGSize selfSize             = self.frame.size;
    CGSize containerViewSize    = self.containerView.frame.size;
    CGFloat containerViewX      =
    (selfSize.width - containerViewSize.width) * 0.5 + self.centerOffset.x;
    CGFloat containerViewY      =
    (selfSize.height - containerViewSize.height) * 0.5 + self.centerOffset.y;
    self.containerView.frame    =
    CGRectMake(containerViewX, containerViewY, containerViewSize.width, containerViewSize.height);
}

- (void)layout
{
    [super layout];
    [self layoutContainerViewSubviews];
    [self layoutContainerView];
}

- (void)setMode:(KKProgressHUDMode)mode
{
    _mode = mode;
    [self setNeedsLayout:YES];
}

- (void)setStyle:(KKProgressHUDBackgroundStyle)style
{
    _style = style;
    
    self.blurView.hidden =
    KKProgressHUDBackgroundStyleBlur != style;
    self.solidColorView.hidden =
    KKProgressHUDBackgroundStyleSolidColor != style;
    self.solidColorView.layerBackgroundColor = [self getBackgroundColor];
    
    if (self.windowController == nil) {
        self.containerView.wantsLayer            = YES;
        self.containerView.layer.cornerRadius    = 6.0;
        self.containerView.layer.masksToBounds   = YES;
    }
    
    if (_progressIndicator.superview != self.containerView) {
        [_progressIndicator removeFromSuperview];
        [self.containerView addSubview:_progressIndicator];
    }
    if (_label.superview != self.containerView) {
        [_label removeFromSuperview];
        [self.containerView addSubview:_label];
    }
    if (_detailsLabel.superview != self.containerView) {
        [_detailsLabel removeFromSuperview];
        [self.containerView addSubview:_detailsLabel];
    }
    if (_customView.superview != self.containerView) {
        [_customView removeFromSuperview];
        [self.containerView addSubview:_customView];
    }
    [self setNeedsLayout:YES];
}

- (void)setBackgroundColor:(NSColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    self.style = KKProgressHUDBackgroundStyleSolidColor;
}

- (void)setCenterOffset:(CGPoint)centerOffset
{
    _centerOffset = centerOffset;
    [self setNeedsLayout:YES];
}

- (void)setInteritemSpacing:(CGFloat)interitemSpacing
{
    _interitemSpacing = interitemSpacing;
    [self setNeedsLayout:YES];
}

- (void)setMaxLayoutWidth:(CGFloat)maxLayoutWidth
{
    _maxLayoutWidth = maxLayoutWidth;
    [self setNeedsLayout:YES];
}

- (void)setSquare:(BOOL)square
{
    _square = square;
    [self setNeedsLayout:YES];
}

- (void)setProgress:(double)progress
{
    self.progressIndicator.doubleValue = progress;
}

- (double)progress
{
    return self.progressIndicator.doubleValue;
}

+ (void)setShowAnimationDuration:(CGFloat)showAnimationDuration
{
    gShowAnimationDuration = showAnimationDuration;
}

+ (CGFloat)showAnimationDuration
{
    return gShowAnimationDuration;
}

+ (void)setScaleAnimationDuration:(CGFloat)scaleAnimationDuration
{
    gScaleAnimationDuration = scaleAnimationDuration;
}

+ (CGFloat)scaleAnimationDuration
{
    return gScaleAnimationDuration;
}

+ (void)setDefaultStyle:(KKProgressHUDBackgroundStyle)defaultStyle
{
    gDefaultStyle = defaultStyle;
}

+ (KKProgressHUDBackgroundStyle)defaultStyle
{
    return gDefaultStyle;
}

+ (void)setDefaultBackgroundColor:(NSColor *)defaultBackgroundColor
{
    gDefaultBackgroundColor = defaultBackgroundColor;
}

+ (NSColor *)defaultBackgroundColor
{
    return gDefaultBackgroundColor;
}

+ (void)setDefaultLabelFont:(NSFont *)defaultLabelFont
{
    gDefaultLabelFont = defaultLabelFont;
}

+ (NSFont *)defaultLabelFont
{
    return gDefaultLabelFont;
}

+ (void)setDefaultDetailLabelFont:(NSFont *)defaultDetailLabelFont
{
    gDefaultDetailLabelFont = defaultDetailLabelFont;
}

+ (NSFont *)defaultDetailLabelFont
{
    return gDefaultDetailLabelFont;
}

- (NSColor *)getBackgroundColor
{
    if (_backgroundColor) {
        return _backgroundColor;
    }
    if (gDefaultBackgroundColor) {
        return gDefaultBackgroundColor;
    }
    if ([self.effectiveAppearance.name isEqualToString:NSAppearanceNameAqua]) {
        return [NSColor colorWithWhite:1 alpha:0.95];
    } else {
        return [NSColor colorWithWhite:0 alpha:0.9];
    }
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
    for (NSString *keypath in [self observableKeypaths]) {
        [self removeObserver:self forKeyPath:keypath];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

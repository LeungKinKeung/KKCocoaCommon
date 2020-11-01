//
//  KKProgressHUD.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKProgressHUD.h"
#import "NSView+KKAnimation.h"

static NSString *kEffectiveAppearanceKey = @"effectiveAppearance";
static NSString *kStringValueKey = @"stringValue";
static NSString *kFontKey = @"font";
static NSString *kAttributedStringValueKey = @"attributedStringValue";

static CGFloat _showAnimationDuration = 0.2;
static CGFloat _scaleAnimationDuration = 0.1;
static KKProgressHUDBackgroundStyle _defaultStyle = KKProgressHUDBackgroundStyleBlur;
static NSColor *_defaultBackgroundColor = nil;

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
@property (nonatomic, strong) NSView *containerView;
@property (nonatomic, assign) BOOL viewDidDraw;

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
    _margin             = 24;
    _subviewsSpacing    = 10;
    _maxLayoutWidth     = 296;
    _square             = YES;
    _mode               = KKProgressHUDModeIndeterminate;
    [self addObserver:self forKeyPath:kEffectiveAppearanceKey options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
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
    KKProgressHUD *hud  = [self showHUDAddedTo:target mode:KKProgressHUDModeLoadingText title:title animated:animated];
    hud.margin          = 10;
    hud.subviewsSpacing = 5;
    hud.label.font      = [NSFont systemFontOfSize:16];
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
    self.style                  = _defaultStyle;
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
    self.viewDidDraw = YES;
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
    CGPointEqualToPoint(winOrigin, CGPointZero) ? 0 : _scaleAnimationDuration;
    
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
    
    self.containerView.wantsLayer            = YES;
    self.containerView.layer.cornerRadius    = 6.0;
    self.containerView.layer.masksToBounds   = YES;
    self.blurView.blendingMode  = NSVisualEffectBlendingModeWithinWindow;
    self.style              = _defaultStyle;
    
    NSShadow *shadow        = [[NSShadow alloc] init];
    shadow.shadowColor      = [NSColor colorWithWhite:0 alpha:0.3];
    shadow.shadowOffset     = NSMakeSize(0, 0);
    shadow.shadowBlurRadius = 5;
    self.shadow             = shadow;
    
    self.frame              = view.bounds;
    self.autoresizingMask   = NSViewWidthSizable | NSViewHeightSizable;
    
    if (animated) {
        self.alphaValue = 0;
        [NSView animateWithDuration:_showAnimationDuration animations:^{
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
        [NSView animateWithDuration:_showAnimationDuration animations:^{
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
    }
    return _blurView;
}

- (NSView *)containerView
{
    if (_containerView == nil) {
        _containerView = [KKHUDFlippedBackgroundView new];
        _containerView.wantsLayer = YES;
        _containerView.layer.backgroundColor = NSColor.clearColor.CGColor;
        [self addSubview:_containerView];
        [_containerView addSubview:self.blurView];
    }
    return _containerView;
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
        [_label addObserver:self forKeyPath:kFontKey options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
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
        [_detailsLabel addObserver:self forKeyPath:kFontKey options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
        [self.containerView addSubview:_detailsLabel];
    }
    return _detailsLabel;
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
            CGFloat duration = self.viewDidDraw ? _scaleAnimationDuration : 0;
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
    CGFloat subviewsSpacing = self.subviewsSpacing;
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
    self.blurView.frame         = self.containerView.bounds;
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
    
    self.containerView.layerBackgroundColor =
    KKProgressHUDBackgroundStyleBlur == style ?
    NSColor.clearColor :
    [self getBackgroundColor];
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

- (void)setSubviewsSpacing:(CGFloat)subviewsSpacing
{
    _subviewsSpacing = subviewsSpacing;
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
    _showAnimationDuration = showAnimationDuration;
}

+ (CGFloat)showAnimationDuration
{
    return _showAnimationDuration;
}

+ (void)setScaleAnimationDuration:(CGFloat)scaleAnimationDuration
{
    _scaleAnimationDuration = scaleAnimationDuration;
}

+ (CGFloat)scaleAnimationDuration
{
    return _scaleAnimationDuration;
}

+ (void)setDefaultStyle:(KKProgressHUDBackgroundStyle)defaultStyle
{
    _defaultStyle = defaultStyle;
}

+ (KKProgressHUDBackgroundStyle)defaultStyle
{
    return _defaultStyle;
}

+ (void)setDefaultBackgroundColor:(NSColor *)defaultBackgroundColor
{
    _defaultBackgroundColor = defaultBackgroundColor;
}

+ (NSColor *)defaultBackgroundColor
{
    return _defaultBackgroundColor;
}

- (NSColor *)getBackgroundColor
{
    if (_backgroundColor) {
        return _backgroundColor;
    }
    if (_defaultBackgroundColor) {
        return _defaultBackgroundColor;
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
    if (_label) {
        [_label removeObserver:self forKeyPath:kStringValueKey];
        [_label removeObserver:self forKeyPath:kAttributedStringValueKey];
        [_label removeObserver:self forKeyPath:kFontKey];
    }
    if (_detailsLabel) {
        [_detailsLabel removeObserver:self forKeyPath:kStringValueKey];
        [_detailsLabel removeObserver:self forKeyPath:kAttributedStringValueKey];
        [_detailsLabel removeObserver:self forKeyPath:kFontKey];
    }
    [self removeObserver:self forKeyPath:kEffectiveAppearanceKey];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

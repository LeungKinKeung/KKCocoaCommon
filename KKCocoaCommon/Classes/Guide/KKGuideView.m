//
//  KKGuideView.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKGuideView.h"
#import "NSView+KK.h"

#define KKGUIDE_VIEW_DEBUG NO

@interface KKGuideView ()

@property (nonatomic, assign, getter=isDragged) BOOL dragged;
@property (nonatomic, assign) CGRect targetViewFrame;
@property (nonatomic, assign) KKViewPosition viewPosition;
@property (nonatomic, strong) NSMutableArray <NSNumber *>*shakeValues;
@property (nonatomic, strong) NSMutableArray <NSNumber *>*arrowRadiiValues;
@property (nonatomic, assign) NSInteger shakeValueIndex;
@property (nonatomic, assign) BOOL shakeValuesDidLoad;
@property (nonatomic, assign) BOOL customedTipsViewCenterOffset;
@property (nonatomic, readonly) NSEdgeInsets targetViewMargin;

@end

@implementation KKGuideView

- (instancetype)initWithFrame:(NSRect)frame
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
    _leadingLineWidth           = 2.0;
    _borderLineWidth            = 2.0;
    _highlightShapeStyle        = KKGuideViewShapeStyleDefault;
    _tipsBorderShapeStyle       = KKGuideViewShapeStyleCasual;
    _tipsBorderLineFillStyle    = KKGuideViewLineFillStyleDotted;
    _leadingLineWidth           = KKGuideViewLineFillStyleNone;
    _leadingLineFillStyle       = KKGuideViewLineFillStyleSolid;
    _leadingLineCurveStyle      = KKGuideViewLineCurveStyleCasual;
    _backgroundColor            = [NSColor colorWithWhite:0 alpha:0.7];
    _tipsBorderPadding          = NSEdgeInsetsMake(8, 8, 8, 8);
    _tintColor                  = NSColor.whiteColor;
    _highlightMargin            = 2;
    _highlightBorderLineFillStyle   = KKGuideViewLineFillStyleDotted;
    
    for (NSString *keypath in [self observableKeypaths]) {
        [self addObserver:self forKeyPath:keypath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
}

- (NSArray *)observableKeypaths
{
    return @[@"tipsLabel.stringValue",
             @"tipsLabel.attributedStringValue",
             @"tipsLabel.font",
             @"highlightShapeStyle",
             @"highlightBorderLineFillStyle",
             @"highlightPadding",
             @"highlightMargin",
             @"highlightCornerRadius",
             @"tipsBorderShapeStyle",
             @"tipsBorderLineFillStyle",
             @"tipsBorderPadding",
             @"tipsBorderCornerRadius",
             @"leadingLineFillStyle",
             @"leadingLineWidth",
             @"borderLineWidth",
             @"padding"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    [self refresh];
}

+ (instancetype)showGuideViewAddedTo:(NSView *)superview
                          targetView:(NSView *)targetView
                                tips:(NSString *)tips
                          completion:(KKGuideViewCompletionBlock)completion
{
    KKGuideView *guide          = [self new];
    guide.tipsLabel.stringValue = tips ? tips : @"";
    guide.targetView            = targetView;
    guide.highlightCornerRadius = targetView.layer.cornerRadius;
    guide.completionBlock       = completion;
    [superview addSubview:guide];
    guide.frame                 = superview.bounds;
    guide.autoresizingMask      = NSViewWidthSizable | NSViewHeightSizable;
    return guide;
}

- (NSTextField *)tipsLabel
{
    if (_tipsLabel == nil) {
        NSTextField *label      = [NSTextField new];
        _tipsLabel              = label;
        label.font              = [NSFont systemFontOfSize:18];
        label.editable          = NO;
        label.selectable        = NO;
        label.bordered          = NO;
        label.drawsBackground   = NO;
        label.textColor         = NSColor.whiteColor;
        label.backgroundColor   = NSColor.clearColor;
        label.focusRingType     = NSFocusRingTypeNone;
        label.bezelStyle        = NSTextFieldSquareBezel;
        label.lineBreakMode     = NSLineBreakByWordWrapping;
        label.cell.scrollable   = NO;
        label.wantsLayer        = YES;
        label.layer.backgroundColor     = NSColor.clearColor.CGColor;
        self.customTipsView     = label;
    }
    return _tipsLabel;
}

#pragma mark - Setting
- (void)setTargetView:(NSView *)targetView
{
    _targetView = targetView;
    [self refresh];
}

- (void)setCustomTipsView:(NSView *)customTipsView
{
    if (_customTipsView) {
        [_customTipsView removeFromSuperview];
    }
    _customTipsView = customTipsView;
    [self addSubview:customTipsView];
}

- (void)setTipsViewCenterOffset:(CGPoint)tipsViewCenterOffset
{
    _tipsViewCenterOffset = tipsViewCenterOffset;
    self.customedTipsViewCenterOffset = YES;
    [self refresh];
}

- (void)setBackgroundColor:(NSColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    [self setNeedsDisplay:YES];
}

- (void)setTintColor:(NSColor *)tintColor
{
    _tintColor = tintColor;
    _tipsLabel.textColor = tintColor;
    [self setNeedsDisplay:YES];
}

- (NSEdgeInsets)targetViewMargin
{
    return NSEdgeInsetsMake(self.highlightPadding.top + self.highlightMargin,
                            self.highlightPadding.left + self.highlightMargin,
                            self.highlightPadding.bottom + self.highlightMargin,
                            self.highlightPadding.right + self.highlightMargin);
}

- (void)refresh
{
    [self.shakeValues removeAllObjects];
    [self.arrowRadiiValues removeAllObjects];
    [self setNeedsLayout:YES];
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)event
{
    if (self.completionBlock == nil && self.removeFromSuperviewOnClick == NO) {
        [super mouseDown:event];
    }
    [self setDragged:NO];
}

- (void)mouseDragged:(NSEvent *)event
{
    [super mouseDragged:event];
    [self setDragged:YES];
}

- (void)mouseUp:(NSEvent *)event
{
    [super mouseUp:event];
    if (self.completionBlock == nil && self.removeFromSuperviewOnClick == NO) {
        [super mouseUp:event];
    } else if (self.isDragged == NO) {
        if (self.completionBlock) {
            self.completionBlock(self);
        }
        if (self.removeFromSuperviewOnClick) {
            [self removeFromSuperview];
        }
    }
}

#pragma mark - Layout
- (void)layout
{
    [super layout];
    
    CGSize selfSize             = self.frame.size;
    CGSize tipsViewSize         = CGSizeZero;
    CGRect tipsViewFrame        = CGRectZero;
    CGFloat tipsViewMinX        = self.padding;
    CGFloat tipsViewMaxX        = selfSize.width - self.padding;
    CGFloat tipsViewMaxWidth    = selfSize.width - self.padding * 2;
    CGRect targetViewFrame      = [self frameForTargetView];
    NSEdgeInsets targetViewMargin   = self.targetViewMargin;
    NSEdgeInsets tipsBorderPadding  = self.tipsBorderPadding;
    
    if (_tipsLabel && self.customTipsView == _tipsLabel) {
        
        CGSize containerSize    = CGSizeZero;
        CGFloat maxLayoutWidth  = self.tipsLabel.preferredMaxLayoutWidth;
        if (maxLayoutWidth > 0) {
            containerSize       = CGSizeMake(maxLayoutWidth, FLT_MAX);
        } else {
            CGFloat textWidth   = [self.tipsLabel sizeThatFits:CGSizeMake(FLT_MAX, FLT_MAX)].width;
            if (textWidth < tipsViewMaxWidth && textWidth > selfSize.width * 0.6) {
                maxLayoutWidth  = textWidth * 0.6; // 对折一下
            } else if (textWidth > tipsViewMaxWidth) {
                maxLayoutWidth  = textWidth / ceil(textWidth / (tipsViewMaxWidth - tipsBorderPadding.left - tipsBorderPadding.right));
            } else {
                maxLayoutWidth  = textWidth;
            }
            containerSize       = CGSizeMake(maxLayoutWidth, FLT_MAX);
        }
        tipsViewSize            = [self.tipsLabel sizeThatFits:containerSize];
        
    } else if (self.customTipsView) {
        
        tipsViewSize            = [self.customTipsView intrinsicContentSize];
        if (tipsViewSize.width == 0 || tipsViewSize.height == 0) {
            tipsViewSize        = self.customTipsView.frame.size;
        }
    }
    
    if (self.customedTipsViewCenterOffset) {
        tipsViewFrame =
        CGRectMake(CGRectGetMidX(targetViewFrame) + self.tipsViewCenterOffset.x,
                   CGRectGetMidY(targetViewFrame) + self.tipsViewCenterOffset.y,
                   tipsViewSize.width,
                   tipsViewSize.height);
    } else {
        KKViewPosition viewPosition   = [NSView positionForView:self.targetView relativeToView:self];
        CGFloat offsetY             = 0;
        switch (viewPosition) {
            case KKViewPositionTop:
            case KKViewPositionCenter:
            case KKViewPositionBottom: {
                offsetY     = 90;
                break;
            }
            default: {
                offsetY     = 40;
                break;
            }
        }
        switch (viewPosition) {
            case KKViewPositionTopLeft:
            case KKViewPositionLeft:{
                CGFloat tipsViewY =
                self.isFlipped ?
                CGRectGetMaxY(targetViewFrame) + offsetY :
                CGRectGetMinY(targetViewFrame) - offsetY - tipsViewSize.height;
                CGFloat tipsViewX =
                CGRectGetMaxX(targetViewFrame) + targetViewMargin.right + tipsBorderPadding.left;
                if (tipsViewX + tipsViewSize.width > tipsViewMaxX) {
                    tipsViewX = tipsViewX - (tipsViewX + tipsViewSize.width - tipsViewMaxX);
                }
                tipsViewFrame = CGRectMake(tipsViewX, tipsViewY, tipsViewSize.width, tipsViewSize.height);
                break;
            }
            case KKViewPositionTopRigth:
            case KKViewPositionRigth: {
                CGFloat tipsViewY =
                self.isFlipped ?
                CGRectGetMaxY(targetViewFrame) + offsetY :
                CGRectGetMinY(targetViewFrame) - offsetY - tipsViewSize.height - tipsBorderPadding.right;
                CGFloat tipsViewX =
                CGRectGetMinX(targetViewFrame) - tipsViewSize.width - targetViewMargin.left - tipsBorderPadding.right;
                if (tipsViewX < tipsViewMinX) {
                    tipsViewX = tipsViewMinX;
                }
                tipsViewFrame = CGRectMake(tipsViewX, tipsViewY, tipsViewSize.width, tipsViewSize.height);
                break;
            }
            case KKViewPositionBottomLeft: {
                CGFloat tipsViewY =
                self.isFlipped ?
                CGRectGetMinY(targetViewFrame) - offsetY - tipsViewSize.height :
                CGRectGetMaxY(targetViewFrame) + offsetY;
                CGFloat tipsViewX =
                CGRectGetMaxX(targetViewFrame) + targetViewMargin.right + tipsBorderPadding.left;
                if (tipsViewX + tipsViewSize.width > tipsViewMaxX) {
                    tipsViewX = tipsViewX - (tipsViewX + tipsViewSize.width - tipsViewMaxX);
                }
                tipsViewFrame = CGRectMake(tipsViewX, tipsViewY, tipsViewSize.width, tipsViewSize.height);
                break;
            }
            case KKViewPositionBottomRigth: {
                CGFloat tipsViewY =
                self.isFlipped ?
                CGRectGetMinY(targetViewFrame) - offsetY - tipsViewSize.height :
                CGRectGetMaxY(targetViewFrame) + offsetY;
                CGFloat tipsViewX =
                CGRectGetMinX(targetViewFrame) - tipsViewSize.width - targetViewMargin.left  - tipsBorderPadding.right;
                if (tipsViewX < tipsViewMinX) {
                    tipsViewX = tipsViewMinX;
                }
                tipsViewFrame = CGRectMake(tipsViewX, tipsViewY, tipsViewSize.width, tipsViewSize.height);
                break;
            }
            case KKViewPositionBottom: {
                CGFloat tipsViewY =
                self.isFlipped ?
                CGRectGetMinY(targetViewFrame) - offsetY - tipsViewSize.height :
                CGRectGetMaxY(targetViewFrame) + offsetY;
                tipsViewFrame =
                CGRectMake((selfSize.width - tipsViewSize.width) * 0.5, tipsViewY, tipsViewSize.width, tipsViewSize.height);
                break;
            }
            default: {
                // KKViewPositionTop
                // KKViewPositionCenter
                CGFloat tipsViewY =
                self.isFlipped ?
                CGRectGetMaxY(targetViewFrame) + offsetY :
                CGRectGetMinY(targetViewFrame) - offsetY - tipsViewSize.height;
                tipsViewFrame =
                CGRectMake((selfSize.width - tipsViewSize.width) * 0.5, tipsViewY, tipsViewSize.width, tipsViewSize.height);
                
                break;
            }
        }
        self.viewPosition       = viewPosition;
        _tipsViewCenterOffset   =
        CGPointMake(CGRectGetMidX(tipsViewFrame) - CGRectGetMidX(targetViewFrame),
                    CGRectGetMidY(tipsViewFrame) - CGRectGetMidY(targetViewFrame));
    }
    self.customTipsView.frame   = tipsViewFrame;
    self.targetViewFrame        = targetViewFrame;
    
    if (self.customedTipsViewCenterOffset) {
        self.viewPosition       = [NSView positionForView:self.targetView relativeToView:self.customTipsView];
    }
}

- (CGRect)frameForTargetView
{
    return [self convertRect:self.targetView.bounds fromView:self.targetView];
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    if (self.backgroundColor) {
        // 背景色
        NSBezierPath *path = [NSBezierPath bezierPathWithRect:dirtyRect];
        [self.backgroundColor setFill];
        [path fill];
    }
    if (self.backgroundColor) {
        // 高亮区域
        NSEdgeInsets padding    = self.highlightPadding;
        CGFloat cornerRadius    = self.highlightCornerRadius;
        CGRect frame            = [self frameForTargetView];
        CGRect rect             =
        CGRectMake(frame.origin.x - padding.left,
                   (self.isFlipped ? frame.origin.y - padding.top : frame.origin.y - padding.bottom),
                   frame.size.width + padding.left + padding.right,
                   frame.size.height + padding.top + padding.bottom);
        NSBezierPath *path      = [self shapePathWithStyle:self.highlightShapeStyle rect:rect cornerRadius:cornerRadius];
        CGContextRef context    = [NSGraphicsContext currentContext].CGContext;
        CGContextSaveGState(context);
        CGContextSetBlendMode(context, kCGBlendModeClear);
        [path fill];
        CGContextRestoreGState(context);
    }
    [self.tintColor setStroke];
    
    if (self.highlightBorderLineFillStyle != KKGuideViewLineFillStyleNone) {
        // 高亮区域边框
        NSEdgeInsets margin     = self.targetViewMargin;
        CGFloat cornerRadius    = self.highlightCornerRadius;
        CGRect frame            = [self frameForTargetView];
        CGRect rect             =
        CGRectMake(frame.origin.x - margin.left,
                   (self.isFlipped ? frame.origin.y - margin.top : frame.origin.y - margin.bottom),
                   frame.size.width + margin.left + margin.right,
                   frame.size.height + margin.top + margin.bottom);
        NSBezierPath *border    = [self shapePathWithStyle:self.highlightShapeStyle rect:rect cornerRadius:cornerRadius];
        [border setLineWidth:self.borderLineWidth];
        if (self.tipsBorderLineFillStyle == KKGuideViewLineFillStyleDotted) {
            CGFloat lengths[] = {self.borderLineWidth * 3,self.borderLineWidth};
            [border setLineDash:lengths count:2 phase:0];
        }
        [border stroke];
    }
    
    // 绘制引导线
    [self drawLeadingLines];
    
    // tips视图的边框
    if (self.tipsBorderLineFillStyle != KKGuideViewLineFillStyleNone)
    {
        CGRect tipsViewFrame    = self.customTipsView.frame;
        NSEdgeInsets padding    = self.tipsBorderPadding;
        CGRect borderFrame      =
        CGRectMake(tipsViewFrame.origin.x - padding.left,
                   self.isFlipped ? tipsViewFrame.origin.y - padding.top : tipsViewFrame.origin.y - padding.bottom,
                   tipsViewFrame.size.width + padding.left + padding.right,
                   tipsViewFrame.size.height + padding.top + padding.bottom);
        
        NSBezierPath *border = [self shapePathWithStyle:self.tipsBorderShapeStyle rect:borderFrame cornerRadius:self.tipsBorderCornerRadius];
        [border setLineWidth:self.borderLineWidth];
        if (self.tipsBorderLineFillStyle == KKGuideViewLineFillStyleDotted) {
            CGFloat lengths[] = {self.borderLineWidth * 3,self.borderLineWidth};
            [border setLineDash:lengths count:2 phase:0];
        }
        [border stroke];
    }
}

- (void)drawLeadingLines
{
    if (self.leadingLineFillStyle == KKGuideViewLineFillStyleNone) {
        return;
    }
    CGRect tipsViewFrame = self.customTipsView.frame;
    
    // 连接线
    CGFloat spacing         = 15;
    CGPoint lineBeginPoint  = CGPointZero;
    CGPoint lineEndPoint    = CGPointZero;
    CGPoint lineCenterPoint = CGPointZero;
    CGPoint controlPoint1   = CGPointZero;
    CGPoint controlPoint2   = CGPointZero;
    CGFloat diameter        = 0;
    NSEdgeInsets margin     = self.targetViewMargin;
    CGFloat lineBeginPointXMaxOffset = 70;
    
    switch (self.viewPosition) {
        case KKViewPositionTopLeft:
        case KKViewPositionLeft:{
            lineBeginPoint.x    = MIN(CGRectGetMinX(tipsViewFrame) + lineBeginPointXMaxOffset, CGRectGetMidX(tipsViewFrame));
            lineBeginPoint.y    = self.isFlipped ? CGRectGetMinY(tipsViewFrame) - spacing: CGRectGetMaxY(tipsViewFrame) + spacing;
            
            lineEndPoint.x      = CGRectGetMaxX(self.targetViewFrame) + margin.right + spacing;
            lineEndPoint.y      = CGRectGetMidY(self.targetViewFrame);
            
            NSBezierPath *line  = [NSBezierPath bezierPath];
            [line moveToPoint:lineBeginPoint];
            lineCenterPoint.x   = (lineBeginPoint.x + lineEndPoint.x) * 0.5;
            lineCenterPoint.y   = (lineBeginPoint.y + lineEndPoint.y) * 0.5;
            
            if (self.leadingLineCurveStyle == KKGuideViewLineCurveStyleCasual) {
                controlPoint1.x     = lineBeginPoint.x;
                controlPoint1.y     = self.isFlipped ? lineCenterPoint.y: lineCenterPoint.y;
                controlPoint2.x     = lineCenterPoint.x;
                controlPoint2.y     = lineEndPoint.y;
                [line curveToPoint:lineCenterPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                if (KKGUIDE_VIEW_DEBUG) {
                    [self drawDebugLine:lineBeginPoint endPoint:controlPoint1 color:NSColor.redColor];
                    [self drawDebugLine:lineCenterPoint endPoint:controlPoint2 color:NSColor.orangeColor];
                }
                
                controlPoint1.x     = lineCenterPoint.x;
                controlPoint1.y     = lineBeginPoint.y;
                controlPoint2.x     = lineBeginPoint.x;
                controlPoint2.y     = lineEndPoint.y;
                [line curveToPoint:lineEndPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                if (KKGUIDE_VIEW_DEBUG) {
                    [self drawDebugLine:lineCenterPoint endPoint:controlPoint1 color:NSColor.yellowColor];
                    [self drawDebugLine:lineEndPoint endPoint:controlPoint2 color:NSColor.greenColor];
                }
            } else {
                controlPoint1.x     = lineBeginPoint.x;
                controlPoint1.y     = self.isFlipped ? lineCenterPoint.y: lineCenterPoint.y;
                controlPoint2.x     = lineCenterPoint.x;
                controlPoint2.y     = lineEndPoint.y;
                [line curveToPoint:lineEndPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                if (KKGUIDE_VIEW_DEBUG) {
                    [self drawDebugLine:lineBeginPoint endPoint:controlPoint1 color:NSColor.redColor];
                    [self drawDebugLine:lineEndPoint endPoint:controlPoint2 color:NSColor.orangeColor];
                }
            }
            
            [line setLineWidth:self.leadingLineWidth];
            if (self.leadingLineFillStyle == KKGuideViewLineFillStyleDotted) {
                CGFloat lengths[] = {self.leadingLineWidth * 3,self.leadingLineWidth};
                [line setLineDash:lengths count:2 phase:0];
            }
            [line stroke];
            
            // 箭头
            [self drawArrowWithAngle:M_PI arrowCenter:lineEndPoint];
            //[self drawArrowWithAngle:[self angleWithCenter:lineBeginPoint point:lineEndPint] arrowCenter:lineEndPint];
            
            break;
        }
        case KKViewPositionTopRigth:
        case KKViewPositionRigth: {
            lineBeginPoint.x    = MAX(CGRectGetMaxX(tipsViewFrame) - lineBeginPointXMaxOffset, CGRectGetMidX(tipsViewFrame));
            lineBeginPoint.y    = self.isFlipped ? CGRectGetMinY(tipsViewFrame) - spacing: CGRectGetMaxY(tipsViewFrame) + spacing;
            
            lineEndPoint.x      = CGRectGetMinX(self.targetViewFrame) - margin.right - spacing;
            lineEndPoint.y      = CGRectGetMidY(self.targetViewFrame);
            
            NSBezierPath *line  = [NSBezierPath bezierPath];
            [line moveToPoint:lineBeginPoint];
            lineCenterPoint.x   = (lineBeginPoint.x + lineEndPoint.x) * 0.5;
            lineCenterPoint.y   = (lineBeginPoint.y + lineEndPoint.y) * 0.5;
            
            if (self.leadingLineCurveStyle == KKGuideViewLineCurveStyleCasual) {
                controlPoint1.x     = lineBeginPoint.x;
                controlPoint1.y     = self.isFlipped ? lineCenterPoint.y : lineCenterPoint.y;
                controlPoint2.x     = lineCenterPoint.x;
                controlPoint2.y     = lineEndPoint.y;
                [line curveToPoint:lineCenterPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                if (KKGUIDE_VIEW_DEBUG) {
                    [self drawDebugLine:lineBeginPoint endPoint:controlPoint1 color:NSColor.redColor];
                    [self drawDebugLine:lineCenterPoint endPoint:controlPoint2 color:NSColor.orangeColor];
                }
                
                controlPoint1.x     = lineCenterPoint.x;
                controlPoint1.y     = lineBeginPoint.y;
                controlPoint2.x     = lineBeginPoint.x;
                controlPoint2.y     = lineEndPoint.y;
                [line curveToPoint:lineEndPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                if (KKGUIDE_VIEW_DEBUG) {
                    [self drawDebugLine:lineCenterPoint endPoint:controlPoint1 color:NSColor.yellowColor];
                    [self drawDebugLine:lineEndPoint endPoint:controlPoint2 color:NSColor.greenColor];
                }
            } else {
                controlPoint1.x     = lineBeginPoint.x;
                controlPoint1.y     = self.isFlipped ? lineCenterPoint.y : lineCenterPoint.y;
                controlPoint2.x     = lineCenterPoint.x;
                controlPoint2.y     = lineEndPoint.y;
                [line curveToPoint:lineEndPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                if (KKGUIDE_VIEW_DEBUG) {
                    [self drawDebugLine:lineBeginPoint endPoint:controlPoint1 color:NSColor.redColor];
                    [self drawDebugLine:lineEndPoint endPoint:controlPoint2 color:NSColor.orangeColor];
                }
            }
            
            [line setLineWidth:self.leadingLineWidth];
            if (self.leadingLineFillStyle == KKGuideViewLineFillStyleDotted) {
                CGFloat lengths[] = {self.leadingLineWidth * 3,self.leadingLineWidth};
                [line setLineDash:lengths count:2 phase:0];
            }
            [line stroke];
            
            // 箭头
            [self drawArrowWithAngle:0 arrowCenter:lineEndPoint];
            //[self drawArrowWithAngle:[self angleWithCenter:lineBeginPoint point:lineEndPint] arrowCenter:lineEndPint];
            
            break;
        }
        case KKViewPositionBottomLeft: {
            
            lineBeginPoint.x    = MIN(CGRectGetMinX(tipsViewFrame) + lineBeginPointXMaxOffset, CGRectGetMidX(tipsViewFrame));
            lineBeginPoint.y    = self.isFlipped ? CGRectGetMaxY(tipsViewFrame) + spacing: CGRectGetMinY(tipsViewFrame) - spacing;
            
            lineEndPoint.x      = CGRectGetMaxX(self.targetViewFrame) + margin.right + spacing;
            lineEndPoint.y      = CGRectGetMidY(self.targetViewFrame);
            
            NSBezierPath *line  = [NSBezierPath bezierPath];
            [line moveToPoint:lineBeginPoint];
            lineCenterPoint.x   = (lineBeginPoint.x + lineEndPoint.x) * 0.5;
            lineCenterPoint.y   = (lineBeginPoint.y + lineEndPoint.y) * 0.5;
            
            if (self.leadingLineCurveStyle == KKGuideViewLineCurveStyleCasual) {
                controlPoint1.x     = lineBeginPoint.x;
                controlPoint1.y     = self.isFlipped ? lineCenterPoint.y : lineCenterPoint.y;
                controlPoint2.x     = lineCenterPoint.x;
                controlPoint2.y     = lineEndPoint.y;
                [line curveToPoint:lineCenterPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                if (KKGUIDE_VIEW_DEBUG) {
                    [self drawDebugLine:lineBeginPoint endPoint:controlPoint1 color:NSColor.redColor];
                    [self drawDebugLine:lineCenterPoint endPoint:controlPoint2 color:NSColor.orangeColor];
                }
                
                controlPoint1.x     = lineCenterPoint.x;
                controlPoint1.y     = lineBeginPoint.y;
                controlPoint2.x     = lineBeginPoint.x;
                controlPoint2.y     = lineEndPoint.y;
                [line curveToPoint:lineEndPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                if (KKGUIDE_VIEW_DEBUG) {
                    [self drawDebugLine:lineCenterPoint endPoint:controlPoint1 color:NSColor.yellowColor];
                    [self drawDebugLine:lineEndPoint endPoint:controlPoint2 color:NSColor.greenColor];
                }
            } else {
                controlPoint1.x     = lineBeginPoint.x;
                controlPoint1.y     = self.isFlipped ? lineCenterPoint.y : lineCenterPoint.y;
                controlPoint2.x     = lineCenterPoint.x;
                controlPoint2.y     = lineEndPoint.y;
                [line curveToPoint:lineEndPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                if (KKGUIDE_VIEW_DEBUG) {
                    [self drawDebugLine:lineBeginPoint endPoint:controlPoint1 color:NSColor.redColor];
                    [self drawDebugLine:lineEndPoint endPoint:controlPoint2 color:NSColor.orangeColor];
                }
            }
            
            [line setLineWidth:self.leadingLineWidth];
            if (self.leadingLineFillStyle == KKGuideViewLineFillStyleDotted) {
                CGFloat lengths[] = {self.leadingLineWidth * 3,self.leadingLineWidth};
                [line setLineDash:lengths count:2 phase:0];
            }
            [line stroke];
            
            // 箭头
            [self drawArrowWithAngle:M_PI arrowCenter:lineEndPoint];
            //[self drawArrowWithAngle:[self angleWithCenter:lineBeginPoint point:lineEndPint] arrowCenter:lineEndPint];
            
            break;
        }
        case KKViewPositionBottomRigth: {
            
            lineBeginPoint.x    = MAX(CGRectGetMaxX(tipsViewFrame) - lineBeginPointXMaxOffset, CGRectGetMidX(tipsViewFrame));
            lineBeginPoint.y    = self.isFlipped ? CGRectGetMaxY(tipsViewFrame) + spacing : CGRectGetMinY(tipsViewFrame) - spacing;
            
            lineEndPoint.x      = CGRectGetMinX(self.targetViewFrame) - margin.right - spacing;
            lineEndPoint.y      = CGRectGetMidY(self.targetViewFrame);
            
            NSBezierPath *line  = [NSBezierPath bezierPath];
            [line moveToPoint:lineBeginPoint];
            lineCenterPoint.x   = (lineBeginPoint.x + lineEndPoint.x) * 0.5;
            lineCenterPoint.y   = (lineBeginPoint.y + lineEndPoint.y) * 0.5;
            
            if (self.leadingLineCurveStyle == KKGuideViewLineCurveStyleCasual) {
                controlPoint1.x     = lineBeginPoint.x;
                controlPoint1.y     = self.isFlipped ? lineCenterPoint.y : lineCenterPoint.y;
                controlPoint2.x     = lineCenterPoint.x;
                controlPoint2.y     = lineEndPoint.y;
                [line curveToPoint:lineCenterPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                if (KKGUIDE_VIEW_DEBUG) {
                    [self drawDebugLine:lineBeginPoint endPoint:controlPoint1 color:NSColor.redColor];
                    [self drawDebugLine:lineCenterPoint endPoint:controlPoint2 color:NSColor.orangeColor];
                }
                
                controlPoint1.x     = lineCenterPoint.x;
                controlPoint1.y     = lineBeginPoint.y;
                controlPoint2.x     = lineBeginPoint.x;
                controlPoint2.y     = lineEndPoint.y;
                [line curveToPoint:lineEndPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                if (KKGUIDE_VIEW_DEBUG) {
                    [self drawDebugLine:lineCenterPoint endPoint:controlPoint1 color:NSColor.yellowColor];
                    [self drawDebugLine:lineEndPoint endPoint:controlPoint2 color:NSColor.greenColor];
                }
            } else {
                controlPoint1.x     = lineBeginPoint.x;
                controlPoint1.y     = self.isFlipped ? lineCenterPoint.y : lineCenterPoint.y;
                controlPoint2.x     = lineCenterPoint.x;
                controlPoint2.y     = lineEndPoint.y;
                [line curveToPoint:lineEndPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                if (KKGUIDE_VIEW_DEBUG) {
                    [self drawDebugLine:lineBeginPoint endPoint:controlPoint1 color:NSColor.redColor];
                    [self drawDebugLine:lineEndPoint endPoint:controlPoint2 color:NSColor.orangeColor];
                }
            }
            
            [line setLineWidth:self.leadingLineWidth];
            if (self.leadingLineFillStyle == KKGuideViewLineFillStyleDotted) {
                CGFloat lengths[] = {self.leadingLineWidth * 3,self.leadingLineWidth};
                [line setLineDash:lengths count:2 phase:0];
            }
            [line stroke];
            
            // 箭头
            [self drawArrowWithAngle:0 arrowCenter:lineEndPoint];
            //[self drawArrowWithAngle:[self angleWithCenter:lineBeginPoint point:lineEndPint] arrowCenter:lineEndPint];
            
            break;
        }
        case KKViewPositionBottom: {
            lineBeginPoint.x    = CGRectGetMidX(tipsViewFrame);
            lineBeginPoint.y    =
            self.isFlipped ?
            CGRectGetMaxY(tipsViewFrame) + spacing :
            CGRectGetMinY(tipsViewFrame) - spacing;
            
            lineEndPoint.x      = CGRectGetMidX(self.targetViewFrame);
            lineEndPoint.y      =
            self.isFlipped ?
            CGRectGetMinY(self.targetViewFrame) - spacing - margin.top :
            CGRectGetMaxY(self.targetViewFrame) + spacing + margin.top;
            
            diameter            = [self diagonalDistanceWithPoint:lineBeginPoint otherPoint:lineEndPoint] * 0.3;
            CGFloat distanceY   = fabs(lineEndPoint.y - lineBeginPoint.y);
            CGFloat offsetY     = distanceY * 0.25;
            
            NSBezierPath *line  = [NSBezierPath bezierPath];
            [line moveToPoint:lineBeginPoint];
            
            if (self.leadingLineCurveStyle == KKGuideViewLineCurveStyleCasual) {
                lineCenterPoint.x   = (lineBeginPoint.x + lineEndPoint.x) * 0.5 + diameter;
                lineCenterPoint.y   = (lineBeginPoint.y + lineEndPoint.y) * 0.5;
                controlPoint1.x     = (lineBeginPoint.x + lineEndPoint.x) * 0.5;
                controlPoint1.y     = self.isFlipped ? lineCenterPoint.y + offsetY : lineCenterPoint.y - offsetY;
                controlPoint2.x     = lineCenterPoint.x;
                controlPoint2.y     = controlPoint1.y;
                [line curveToPoint:lineCenterPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                if (KKGUIDE_VIEW_DEBUG) {
                    [self drawDebugLine:lineBeginPoint endPoint:controlPoint1 color:NSColor.redColor];
                    [self drawDebugLine:lineCenterPoint endPoint:controlPoint2 color:NSColor.orangeColor];
                }
                
                controlPoint1.x     = lineCenterPoint.x;
                controlPoint1.y     = self.isFlipped ? lineCenterPoint.y - offsetY : lineCenterPoint.y + offsetY;
                controlPoint2.x     = (lineBeginPoint.x + lineEndPoint.x) * 0.5;
                controlPoint2.y     = controlPoint1.y;
                [line curveToPoint:lineEndPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                if (KKGUIDE_VIEW_DEBUG) {
                    [self drawDebugLine:lineCenterPoint endPoint:controlPoint1 color:NSColor.yellowColor];
                    [self drawDebugLine:lineEndPoint endPoint:controlPoint2 color:NSColor.greenColor];
                }
            } else {
                lineCenterPoint.x   = (lineBeginPoint.x + lineEndPoint.x) * 0.5;
                lineCenterPoint.y   = (lineBeginPoint.y + lineEndPoint.y) * 0.5;
                controlPoint1.x     = lineCenterPoint.x;
                controlPoint1.y     = lineBeginPoint.y;
                controlPoint2.x     = lineEndPoint.x;
                controlPoint2.y     = lineCenterPoint.y;
                [line curveToPoint:lineEndPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                if (KKGUIDE_VIEW_DEBUG) {
                    [self drawDebugLine:lineBeginPoint endPoint:controlPoint1 color:NSColor.redColor];
                    [self drawDebugLine:lineEndPoint endPoint:controlPoint2 color:NSColor.orangeColor];
                }
            }
            
            [line setLineWidth:self.leadingLineWidth];
            if (self.leadingLineFillStyle == KKGuideViewLineFillStyleDotted) {
                CGFloat lengths[] = {self.leadingLineWidth * 3,self.leadingLineWidth};
                [line setLineDash:lengths count:2 phase:0];
            }
            [line stroke];
            
            // 箭头
            if (self.leadingLineCurveStyle == KKGuideViewLineCurveStyleCasual) {
                [self drawArrowWithAngle:[self angleWithCenter:lineBeginPoint point:lineEndPoint] arrowCenter:lineEndPoint];
            } else {
                [self drawArrowWithAngle:M_PI_2 * 3 arrowCenter:lineEndPoint];
            }
            
            break;
        }
        default: {
            // KKViewPositionTop
            // KKViewPositionCenter
            lineBeginPoint.x    = CGRectGetMidX(tipsViewFrame);
            lineBeginPoint.y    = self.isFlipped ? CGRectGetMinY(tipsViewFrame) - spacing: CGRectGetMaxY(tipsViewFrame) + spacing;
            
            lineEndPoint.x      = CGRectGetMidX(self.targetViewFrame);
            lineEndPoint.y      =
            self.isFlipped ?
            CGRectGetMaxY(self.targetViewFrame) + spacing + margin.bottom :
            CGRectGetMinY(self.targetViewFrame) - spacing - margin.bottom;
            
            diameter            = [self diagonalDistanceWithPoint:lineBeginPoint otherPoint:lineEndPoint] * 0.3;
            CGFloat distanceY   = fabs(lineEndPoint.y - lineBeginPoint.y);
            CGFloat offsetY     = distanceY * 0.25;
            
            NSBezierPath *line  = [NSBezierPath bezierPath];
            [line moveToPoint:lineBeginPoint];
            
            if (self.leadingLineCurveStyle == KKGuideViewLineCurveStyleCasual) {
                lineCenterPoint.x   = (lineBeginPoint.x + lineEndPoint.x) * 0.5 - diameter;
                lineCenterPoint.y   = (lineBeginPoint.y + lineEndPoint.y) * 0.5;
                controlPoint1.x     = (lineBeginPoint.x + lineEndPoint.x) * 0.5;
                controlPoint1.y     = self.isFlipped ? lineCenterPoint.y - offsetY : lineCenterPoint.y + offsetY;
                controlPoint2.x     = lineCenterPoint.x;
                controlPoint2.y     = controlPoint1.y;
                [line curveToPoint:lineCenterPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                if (KKGUIDE_VIEW_DEBUG) {
                    [self drawDebugLine:lineBeginPoint endPoint:controlPoint1 color:NSColor.redColor];
                    [self drawDebugLine:lineCenterPoint endPoint:controlPoint2 color:NSColor.orangeColor];
                }
                
                controlPoint1.x     = lineCenterPoint.x;
                controlPoint1.y     = self.isFlipped ? lineCenterPoint.y + offsetY : lineCenterPoint.y - offsetY;
                controlPoint2.x     = (lineBeginPoint.x + lineEndPoint.x) * 0.5;
                controlPoint2.y     = controlPoint1.y;
                [line curveToPoint:lineEndPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                if (KKGUIDE_VIEW_DEBUG) {
                    [self drawDebugLine:lineCenterPoint endPoint:controlPoint1 color:NSColor.yellowColor];
                    [self drawDebugLine:lineEndPoint endPoint:controlPoint2 color:NSColor.greenColor];
                }
            } else {
                lineCenterPoint.x   = (lineBeginPoint.x + lineEndPoint.x) * 0.5;
                lineCenterPoint.y   = (lineBeginPoint.y + lineEndPoint.y) * 0.5;
                controlPoint1.x     = lineCenterPoint.x;
                controlPoint1.y     = lineBeginPoint.y;
                controlPoint2.x     = lineEndPoint.x;
                controlPoint2.y     = lineCenterPoint.y;
                [line curveToPoint:lineEndPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                if (KKGUIDE_VIEW_DEBUG) {
                    [self drawDebugLine:lineBeginPoint endPoint:controlPoint1 color:NSColor.redColor];
                    [self drawDebugLine:lineEndPoint endPoint:controlPoint2 color:NSColor.orangeColor];
                }
            }
            
            [line setLineWidth:self.leadingLineWidth];
            if (self.leadingLineFillStyle == KKGuideViewLineFillStyleDotted) {
                CGFloat lengths[] = {self.leadingLineWidth * 3,self.leadingLineWidth};
                [line setLineDash:lengths count:2 phase:0];
            }
            [line stroke];
            
            // 箭头
            if (self.leadingLineCurveStyle == KKGuideViewLineCurveStyleCasual) {
                [self drawArrowWithAngle:[self angleWithCenter:lineBeginPoint point:lineEndPoint] arrowCenter:lineEndPoint];
            } else {
                [self drawArrowWithAngle:M_PI_2 arrowCenter:lineEndPoint];
            }
            
            break;
        }
    }
}

- (void)drawDebugLine:(CGPoint)point endPoint:(CGPoint)endPoint color:(NSColor *)color
{
    CGContextRef context = [NSGraphicsContext currentContext].CGContext;
    CGContextSaveGState(context);
    [color setStroke];
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint:point];
    [path lineToPoint:endPoint];
    [path setLineWidth:1];
    [path stroke];
    CGContextRestoreGState(context);
}

- (NSBezierPath *)shapePathWithStyle:(KKGuideViewShapeStyle)style rect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius
{
    NSBezierPath *path = nil;
    switch (style) {
        case KKGuideViewShapeStyleCasual: {
            self.shakeValuesDidLoad = self.shakeValues.count > 0;
            self.shakeValueIndex    = 0;
            path                    = [NSBezierPath bezierPath];
            CGPoint beginPoint      = [self shakePoint:CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect))];
            [path moveToPoint:beginPoint];
            
            {
                CGPoint toPoint     = [self shakePoint:CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect))];
                CGPoint referencePoint  = CGPointMake(CGRectGetMaxX(rect), CGRectGetMinY(rect));
                CGPoint point1      = [self shakePoint:referencePoint];
                CGPoint point2      = [self shakePoint:referencePoint];
                [path curveToPoint:toPoint controlPoint1:point1 controlPoint2:point2];
            }
            {
                CGPoint toPoint     = [self shakePoint:CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect))];
                CGPoint referencePoint  = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
                CGPoint point1      = [self shakePoint:referencePoint];
                CGPoint point2      = [self shakePoint:referencePoint];
                [path curveToPoint:toPoint controlPoint1:point1 controlPoint2:point2];
            }
            {
                CGPoint toPoint     = [self shakePoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect))];
                CGPoint referencePoint  = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
                CGPoint point1      = [self shakePoint:referencePoint];
                CGPoint point2      = [self shakePoint:referencePoint];
                [path curveToPoint:toPoint controlPoint1:point1 controlPoint2:point2];
            }
            {
                CGPoint toPoint     = beginPoint;
                CGPoint referencePoint  = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
                CGPoint point1      = [self shakePoint:referencePoint];
                CGPoint point2      = [self shakePoint:referencePoint];
                [path curveToPoint:toPoint controlPoint1:point1 controlPoint2:point2];
            }
            
            [path closePath];
            break;
        }
        case KKGuideViewShapeStyleOval: {
            path = [NSBezierPath bezierPathWithOvalInRect:rect];
            break;
        }
        default: {
            path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius:cornerRadius yRadius:cornerRadius];
            break;
        }
    }
    return path;
}

- (CGFloat)angleWithCenter:(CGPoint)center point:(CGPoint)point
{
    if (self.isFlipped == NO) {
        // 转换坐标系
        center.y    = self.frame.size.height - center.y;
        point.y     = self.frame.size.height - point.y;
    }
    CGFloat x       = point.x - center.x;
    CGFloat y       = -(point.y - center.y);
    CGFloat angle   = atan2(y, x);
    if (angle < 0) {
        // 假如在第三第四象限，就加上2π转为正数
        angle = 2 * M_PI + angle;
    }
    // 0 ~ 2π
    return angle;
}

- (void)drawArrowWithAngle:(CGFloat)angle arrowCenter:(CGPoint)arrowCenter
{
    if (self.arrowRadiiValues.count == 0) {
        for (NSInteger i = 0; i < 4; i++) {
            [self.arrowRadiiValues addObject:@(arc4random_uniform(10) + 5)];
        }
    }
    CGFloat radius          = 0;
    CGPoint arrowBeginPoint = CGPointZero;
    CGPoint arrowEndPoint   = CGPointZero;
    CGPoint controlPoint1   = CGPointZero;
    CGPoint controlPoint2   = CGPointZero;
    CGFloat angle1          = M_PI + angle - 0.9;
    CGFloat angle2          = M_PI + angle + 0.9;
    radius                  = self.arrowRadiiValues[0].doubleValue;
    arrowBeginPoint.x       = arrowCenter.x + radius * cos(angle1);
    radius                  = self.arrowRadiiValues[1].doubleValue;
    arrowBeginPoint.y       = arrowCenter.y + (self.isFlipped ? -radius : radius) * sin(angle1);
    radius                  = self.arrowRadiiValues[2].doubleValue;
    arrowEndPoint.x         = arrowCenter.x + radius * cos(angle2);
    radius                  = self.arrowRadiiValues[3].doubleValue;
    arrowEndPoint.y         = arrowCenter.y + (self.isFlipped ? -radius : radius) * sin(angle2);
    
    NSBezierPath *arrow = [NSBezierPath bezierPath];
    [arrow moveToPoint:arrowBeginPoint];
    controlPoint1.x         = arrowCenter.x - 3 * cos(angle);
    controlPoint1.y         = arrowCenter.y - 3 * sin(angle);
    controlPoint2           = arrowCenter;
    [arrow curveToPoint:arrowCenter controlPoint1:controlPoint1 controlPoint2:controlPoint2];
    controlPoint2           = arrowEndPoint;
    [arrow curveToPoint:arrowEndPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
    [arrow setLineJoinStyle:NSLineJoinStyleRound];
    [arrow setLineWidth:self.leadingLineWidth];
    [arrow stroke];
}

- (CGPoint)shakePoint:(CGPoint)point
{
    CGFloat shakeX = 0;
    if (self.shakeValuesDidLoad) {
        shakeX = [self.shakeValues objectAtIndex:self.shakeValueIndex].doubleValue;
        self.shakeValueIndex++;
    } else {
        shakeX = (CGFloat)arc4random_uniform(5) - 2;
        [self.shakeValues addObject:@(shakeX)];
    }
    CGFloat shakeY = 0;
    if (self.shakeValuesDidLoad) {
        shakeY = [self.shakeValues objectAtIndex:self.shakeValueIndex].doubleValue;
        self.shakeValueIndex++;
    } else {
        shakeY = (CGFloat)arc4random_uniform(5) - 2;
        [self.shakeValues addObject:@(shakeY)];
    }
    return CGPointMake(point.x + shakeX, point.y + shakeY);
}

- (CGFloat)diagonalDistanceWithPoint:(CGPoint)a otherPoint:(CGPoint)b
{
    return fabs(sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2)));
}

- (NSMutableArray<NSNumber *> *)shakeValues
{
    if (_shakeValues == nil) {
        _shakeValues = [NSMutableArray array];
    }
    return _shakeValues;
}

- (NSMutableArray<NSNumber *> *)arrowRadiiValues
{
    if (_arrowRadiiValues == nil) {
        _arrowRadiiValues = [NSMutableArray array];
    }
    return _arrowRadiiValues;
}

- (void)dealloc
{
    for (NSString *keypath in [self observableKeypaths]) {
        [self removeObserver:self forKeyPath:keypath];
    }
}

//- (BOOL)isFlipped
//{
//    return YES;
//}

@end

@implementation NSView (KKPosition)

+ (KKViewPosition)positionForView:(NSView *)view relativeToView:(NSView *)relativeView
{
    CGRect relativeFrame    = CGRectZero;
    CGPoint relativeCenter  = CGPointZero;
    CGRect viewFrame        = CGRectZero;
    CGPoint viewCenter      = CGPointZero;
    
    BOOL isFlipped          = NO;
    if (view.superview == relativeView) {
        isFlipped           = relativeView.isFlipped;
        viewFrame           = [relativeView convertRect:view.bounds fromView:view];
        viewCenter          = CGPointMake(viewFrame.origin.x + viewFrame.size.width * 0.5,
                                          viewFrame.origin.y - (isFlipped ? viewFrame.size.height * 0.5 : -viewFrame.size.height * 0.5));
        relativeCenter      = CGPointMake(relativeView.frame.size.width * 0.5, relativeView.frame.size.height * 0.5);
        
    } else if (view.superview == relativeView.superview) {
        isFlipped           = view.superview.isFlipped;
        relativeFrame       = [relativeView.superview convertRect:relativeView.bounds fromView:relativeView];
        relativeCenter      = CGPointMake(relativeFrame.origin.x + relativeFrame.size.width * 0.5,
                                          relativeFrame.origin.y - (isFlipped ? relativeFrame.size.height * 0.5 : -relativeFrame.size.height * 0.5));
        viewFrame           = [view.superview convertRect:view.bounds fromView:view];
        viewCenter          = CGPointMake(viewFrame.origin.x + viewFrame.size.width * 0.5,
                                          viewFrame.origin.y - (isFlipped ? viewFrame.size.height * 0.5 : -viewFrame.size.height * 0.5));
        
    } else if (view.window == relativeView.window){
        isFlipped           = view.window.contentView.isFlipped;
        relativeFrame       = [relativeView.window.contentView convertRect:relativeView.bounds fromView:relativeView];
        relativeCenter      = CGPointMake(relativeFrame.origin.x + relativeFrame.size.width * 0.5,
                                          relativeFrame.origin.y - (isFlipped ? relativeFrame.size.height * 0.5 : -relativeFrame.size.height * 0.5));
        viewFrame           = [view.window.contentView convertRect:view.bounds fromView:view];
        viewCenter          = CGPointMake(viewFrame.origin.x + viewFrame.size.width * 0.5,
                                          viewFrame.origin.y - (isFlipped ? viewFrame.size.height * 0.5 : -viewFrame.size.height * 0.5));
    } else {
        assert(NO); // 条件不满足
        return KKViewPositionOverlaps;
    }
    
    CGFloat minX        = CGRectGetMinX(viewFrame);
    CGFloat minY        = isFlipped ? CGRectGetMinY(viewFrame) : CGRectGetMaxY(viewFrame);
    CGFloat maxX        = CGRectGetMaxX(viewFrame);
    CGFloat maxY        = isFlipped ? CGRectGetMaxY(viewFrame) : CGRectGetMinY(viewFrame);
    
    KKViewPosition position   = KKViewPositionOverlaps;
    if (viewCenter.x == relativeCenter.x) {
        // 水平对齐
        if (minY > relativeCenter.y) {
            position = isFlipped ? KKViewPositionBottom : KKViewPositionTop;
        } else  if (maxY < relativeCenter.y)  {
            position = isFlipped ? KKViewPositionTop : KKViewPositionBottom;
        }
    } else if (viewCenter.y == relativeCenter.y) {
        // 垂直对齐
        if (minX > relativeCenter.x) {
            position = KKViewPositionRigth;
        } else if (maxX < relativeCenter.x) {
            position = KKViewPositionLeft;
        }
    } else {
        if (minX > relativeCenter.x) {
            if (minY > relativeCenter.y) {
                position = isFlipped ? KKViewPositionBottomRigth : KKViewPositionTopRigth;
            } else {
                position = isFlipped ? KKViewPositionTopRigth : KKViewPositionBottomRigth;
            }
        } else if (maxX < relativeCenter.x) {
            if (minY > relativeCenter.y) {
                position = isFlipped ? KKViewPositionBottomLeft : KKViewPositionTopLeft;
            } else {
                position = isFlipped ? KKViewPositionTopLeft : KKViewPositionBottomLeft;
            }
        } else if (minY > relativeCenter.y) {
            position = isFlipped ? KKViewPositionBottom : KKViewPositionTop;
        } else {
            position = isFlipped ? KKViewPositionTop : KKViewPositionBottom;
        }
    }
    return position;
}

@end

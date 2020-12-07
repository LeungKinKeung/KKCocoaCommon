//
//  KKGuideView.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKGuideView.h"
#import "NSView+KK.h"

@interface KKGuideView ()

@property (nonatomic, assign, getter=isDragged) BOOL dragged;
@property (nonatomic, assign) CGRect targetViewFrame;
@property (nonatomic, assign) KKRectAlignment alignment;
@property (nonatomic, strong) NSMutableArray <NSNumber *>*shakeValues;
@property (nonatomic, strong) NSMutableArray <NSNumber *>*arrowRadiiValues;
@property (nonatomic, assign) NSInteger shakeValueIndex;
@property (nonatomic, assign) BOOL shakeValuesDidLoad;
@property (nonatomic, assign) BOOL customLineOffset;
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
    _lineWidth              = 2.0;
    _highlightShapeStyle    = KKGuideViewShapeStyleDefault;
    _tipsBorderShapeStyle   = KKGuideViewShapeStyleCasual;
    _tipsBorderLineStyle    = KKGuideViewLineStyleDotted;
    _lineStyle              = KKGuideViewLineStyleSolid;
    _backgroundColor        = [NSColor colorWithWhite:0 alpha:0.7];
    _tipsBorderPadding       = NSEdgeInsetsMake(8, 8, 8, 8);
    _tintColor              = NSColor.whiteColor;
    
    for (NSString *keypath in [self observableKeypaths]) {
        [self addObserver:self forKeyPath:keypath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
}

- (NSArray *)observableKeypaths
{
    return @[@"tipsLabel.stringValue", @"tipsLabel.attributedStringValue", @"tipsLabel.font", @"highlightShapeStyle", @"highlightPadding", @"highlightCornerRadius", @"tipsBorderShapeStyle", @"tipsBorderLineStyle", @"tipsBorderPadding", @"tipsBorderCornerRadius", @"lineStyle", @"lineWidth"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    [self refresh];
}

+ (instancetype)showGuideViewAddedTo:(NSView *)superview targetView:(NSView *)targetView tips:(NSString *)tips completion:(KKGuideViewCompletionBlock)completion
{
    KKGuideView *guide          = [self new];
    guide.tipsLabel.stringValue = tips ? tips : @"";
    guide.targetView            = targetView;
    guide.highlightCornerRadius = targetView.layer.cornerRadius;
    guide.completionBlock       = completion;
    guide.removeFromSuperviewOnClick    = completion == NULL;
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

- (void)setLineOffset:(CGPoint)lineOffset
{
    _lineOffset = lineOffset;
    self.customLineOffset = YES;
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

- (void)refresh
{
    [self.shakeValues removeAllObjects];
    [self.arrowRadiiValues removeAllObjects];
    [self setNeedsLayout:YES];
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)event
{
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
    if (self.isDragged == NO) {
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
    CGFloat tipsViewMinX        = 20;
    CGFloat tipsViewMaxX        = selfSize.width - 20;
    CGFloat tipsViewMaxWidth    = selfSize.width - tipsViewMinX * 2;
    CGRect targetViewFrame      = [self frameForTargetView];
    KKRectAlignment alignment   = [self.targetView alignmentAtView:self];
    if (self.customLineOffset == NO) {
        switch (alignment) {
            case KKRectAlignmentTop:
            case KKRectAlignmentCenter:
            case KKRectAlignmentBottom: {
                _lineOffset     = CGPointMake(0, 90);
                break;
            }
            default: {
                _lineOffset     = CGPointMake(0, 40);
                break;
            }
        }
    }
    CGPoint lineOffset              = self.lineOffset;
    NSEdgeInsets highlightPadding   = self.highlightPadding;
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
    
    switch (alignment) {
        case KKRectAlignmentTopLeft:
        case KKRectAlignmentLeft:{
            CGFloat tipsViewY = self.isFlipped ? CGRectGetMaxY(targetViewFrame) + lineOffset.y : CGRectGetMinY(targetViewFrame) - lineOffset.y - tipsViewSize.height;
            CGFloat tipsViewX = CGRectGetMaxX(targetViewFrame) + highlightPadding.right + tipsBorderPadding.left + lineOffset.x;
            if (tipsViewX + tipsViewSize.width > tipsViewMaxX) {
                tipsViewX = tipsViewX - (tipsViewX + tipsViewSize.width - tipsViewMaxX);
            }
            tipsViewFrame = CGRectMake(tipsViewX, tipsViewY, tipsViewSize.width, tipsViewSize.height);
            break;
        }
        case KKRectAlignmentTopRigth:
        case KKRectAlignmentRigth: {
            CGFloat tipsViewY = self.isFlipped ? CGRectGetMaxY(targetViewFrame) + lineOffset.y : CGRectGetMinY(targetViewFrame) - lineOffset.y - tipsViewSize.height - tipsBorderPadding.right;
            CGFloat tipsViewX = CGRectGetMinX(targetViewFrame) - tipsViewSize.width - highlightPadding.left - tipsBorderPadding.right - lineOffset.x;
            if (tipsViewX < tipsViewMinX) {
                tipsViewX = tipsViewMinX;
            }
            tipsViewFrame = CGRectMake(tipsViewX, tipsViewY, tipsViewSize.width, tipsViewSize.height);
            break;
        }
        case KKRectAlignmentBottomLeft: {
            CGFloat tipsViewY = self.isFlipped ? CGRectGetMinY(targetViewFrame) - lineOffset.y - tipsViewSize.height : CGRectGetMaxY(targetViewFrame) + lineOffset.y;
            CGFloat tipsViewX = CGRectGetMaxX(targetViewFrame) + highlightPadding.right + tipsBorderPadding.left + lineOffset.x;
            if (tipsViewX + tipsViewSize.width > tipsViewMaxX) {
                tipsViewX = tipsViewX - (tipsViewX + tipsViewSize.width - tipsViewMaxX);
            }
            tipsViewFrame = CGRectMake(tipsViewX, tipsViewY, tipsViewSize.width, tipsViewSize.height);
            break;
        }
        case KKRectAlignmentBottomRigth: {
            CGFloat tipsViewY = self.isFlipped ? CGRectGetMinY(targetViewFrame) - lineOffset.y - tipsViewSize.height : CGRectGetMaxY(targetViewFrame) + lineOffset.y;
            CGFloat tipsViewX = CGRectGetMinX(targetViewFrame) - tipsViewSize.width - highlightPadding.left  - tipsBorderPadding.right - lineOffset.x;
            if (tipsViewX < tipsViewMinX) {
                tipsViewX = tipsViewMinX;
            }
            tipsViewFrame = CGRectMake(tipsViewX, tipsViewY, tipsViewSize.width, tipsViewSize.height);
            break;
        }
        case KKRectAlignmentBottom: {
            CGFloat tipsViewY = self.isFlipped ? CGRectGetMinY(targetViewFrame) - lineOffset.y - tipsViewSize.height : CGRectGetMaxY(targetViewFrame) + lineOffset.y;
            tipsViewFrame = CGRectMake((selfSize.width - tipsViewSize.width) * 0.5 + lineOffset.x, tipsViewY, tipsViewSize.width, tipsViewSize.height);
            break;
        }
        default: {
            // KKRectAlignmentTop
            // KKRectAlignmentCenter
            CGFloat tipsViewY = self.isFlipped ? CGRectGetMaxY(targetViewFrame) + lineOffset.y : CGRectGetMinY(targetViewFrame) - lineOffset.y - tipsViewSize.height;
            tipsViewFrame = CGRectMake((selfSize.width - tipsViewSize.width) * 0.5 + lineOffset.x, tipsViewY, tipsViewSize.width, tipsViewSize.height);
            
            break;
        }
    }
    self.customTipsView.frame   = tipsViewFrame;
    self.targetViewFrame        = targetViewFrame;
    self.alignment              = alignment;
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
        CGRect rect             = CGRectMake(frame.origin.x - padding.left, (self.isFlipped ? frame.origin.y - padding.top : frame.origin.y - padding.bottom), frame.size.width + padding.left + padding.right, frame.size.height + padding.top + padding.bottom);
        NSBezierPath *path      = [self shapePathWithStyle:self.highlightShapeStyle rect:rect cornerRadius:cornerRadius];
        CGContextRef context    = [NSGraphicsContext currentContext].CGContext;
        CGContextSaveGState(context);
        CGContextSetBlendMode(context, kCGBlendModeClear);
        [path fill];
        CGContextRestoreGState(context);
    }
    [self.tintColor setStroke];
    
    CGRect tipsViewFrame = self.customTipsView.frame;
    
    if (self.lineStyle != KKGuideViewLineStyleNone)
    {
        // 连接线
        CGFloat spacing         = 15;
        CGPoint lineBeginPoint  = CGPointZero;
        CGPoint lineEndPint     = CGPointZero;
        CGPoint lineCenterPoint = CGPointZero;
        CGPoint controlPoint1   = CGPointZero;
        CGPoint controlPoint2   = CGPointZero;
        CGFloat diameter        = 0;
        NSEdgeInsets padding    = self.highlightPadding;
        CGPoint lineOffset      = self.lineOffset;
        
        switch (self.alignment) {
            case KKRectAlignmentTopLeft:
            case KKRectAlignmentLeft:{
                lineBeginPoint.x    = CGRectGetMidX(tipsViewFrame);
                lineBeginPoint.y    = self.isFlipped ? CGRectGetMinY(tipsViewFrame) - spacing: CGRectGetMaxY(tipsViewFrame) + spacing;
                
                lineEndPint.x       = CGRectGetMaxX(self.targetViewFrame) + padding.right + spacing;
                lineEndPint.y       = CGRectGetMidY(self.targetViewFrame);
                
                if ((lineBeginPoint.x - lineEndPint.x) < lineOffset.x) {
                    lineBeginPoint.x = lineEndPint.x + lineOffset.x;
                }
                
                diameter            = [self diagonalDistanceWithPoint:lineBeginPoint otherPoint:lineEndPint] * 0.3;
                
                NSBezierPath *line  = [NSBezierPath bezierPath];
                [line moveToPoint:lineBeginPoint];
                lineCenterPoint.x   = (lineBeginPoint.x + lineEndPint.x) * 0.5;
                lineCenterPoint.y   = (lineBeginPoint.y + lineEndPint.y) * 0.5;
                controlPoint1.x     = lineBeginPoint.x;
                controlPoint1.y     = self.isFlipped ? lineCenterPoint.y - diameter : lineCenterPoint.y + diameter;
                controlPoint2.x     = lineCenterPoint.x;
                controlPoint2.y     = lineEndPint.y;
                [line curveToPoint:lineCenterPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];

                controlPoint1.x     = lineCenterPoint.x;
                controlPoint1.y     = lineBeginPoint.y;
                controlPoint2.x     = lineBeginPoint.x + diameter;
                controlPoint2.y     = lineEndPint.y;
                [line curveToPoint:lineEndPint controlPoint1:controlPoint1 controlPoint2:controlPoint2];

                [line setLineWidth:self.lineWidth];
                if (self.lineStyle == KKGuideViewLineStyleDotted) {
                    CGFloat lengths[] = {self.lineWidth * 3,self.lineWidth};
                    [line setLineDash:lengths count:2 phase:0];
                }
                [line stroke];
                
                // 箭头
                [self drawArrowWithAngle:M_PI arrowCenter:lineEndPint];
                //[self drawArrowWithAngle:[self angleWithCenter:lineBeginPoint point:lineEndPint] arrowCenter:lineEndPint];
                
                break;
            }
            case KKRectAlignmentTopRigth:
            case KKRectAlignmentRigth: {
                lineBeginPoint.x    = CGRectGetMidX(tipsViewFrame);
                lineBeginPoint.y    = self.isFlipped ? CGRectGetMinY(tipsViewFrame) - spacing: CGRectGetMaxY(tipsViewFrame) + spacing;
                
                lineEndPint.x       = CGRectGetMinX(self.targetViewFrame) - padding.right - spacing;
                lineEndPint.y       = CGRectGetMidY(self.targetViewFrame);
                
                if ((lineEndPint.x - lineBeginPoint.x) < lineOffset.x) {
                    lineBeginPoint.x = lineEndPint.x - lineOffset.x;
                }
                
                diameter            = [self diagonalDistanceWithPoint:lineBeginPoint otherPoint:lineEndPint] * 0.3;
                
                NSBezierPath *line  = [NSBezierPath bezierPath];
                [line moveToPoint:lineBeginPoint];
                lineCenterPoint.x   = (lineBeginPoint.x + lineEndPint.x) * 0.5;
                lineCenterPoint.y   = (lineBeginPoint.y + lineEndPint.y) * 0.5;
                controlPoint1.x     = lineBeginPoint.x;
                controlPoint1.y     = self.isFlipped ? lineCenterPoint.y - diameter : lineCenterPoint.y + diameter;
                controlPoint2.x     = lineCenterPoint.x;
                controlPoint2.y     = lineEndPint.y;
                [line curveToPoint:lineCenterPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                controlPoint1.x     = lineCenterPoint.x;
                controlPoint1.y     = lineBeginPoint.y;
                controlPoint2.x     = lineBeginPoint.x - diameter;
                controlPoint2.y     = lineEndPint.y;
                [line curveToPoint:lineEndPint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                [line setLineWidth:self.lineWidth];
                if (self.lineStyle == KKGuideViewLineStyleDotted) {
                    CGFloat lengths[] = {self.lineWidth * 3,self.lineWidth};
                    [line setLineDash:lengths count:2 phase:0];
                }
                [line stroke];
                
                // 箭头
                [self drawArrowWithAngle:0 arrowCenter:lineEndPint];
                //[self drawArrowWithAngle:[self angleWithCenter:lineBeginPoint point:lineEndPint] arrowCenter:lineEndPint];
                
                break;
            }
            case KKRectAlignmentBottomLeft: {
                
                lineBeginPoint.x    = CGRectGetMidX(tipsViewFrame);
                lineBeginPoint.y    = self.isFlipped ? CGRectGetMaxY(tipsViewFrame) + spacing: CGRectGetMinY(tipsViewFrame) - spacing;
                
                lineEndPint.x       = CGRectGetMaxX(self.targetViewFrame) + padding.right + spacing;
                lineEndPint.y       = CGRectGetMidY(self.targetViewFrame);
                
                if ((lineBeginPoint.x - lineEndPint.x) < lineOffset.x) {
                    lineBeginPoint.x = lineEndPint.x + lineOffset.x;
                }
                
                diameter            = [self diagonalDistanceWithPoint:lineBeginPoint otherPoint:lineEndPint] * 0.3;
                
                NSBezierPath *line  = [NSBezierPath bezierPath];
                [line moveToPoint:lineBeginPoint];
                lineCenterPoint.x   = (lineBeginPoint.x + lineEndPint.x) * 0.5;
                lineCenterPoint.y   = (lineBeginPoint.y + lineEndPint.y) * 0.5;
                controlPoint1.x     = lineBeginPoint.x;
                controlPoint1.y     = self.isFlipped ? lineCenterPoint.y - diameter : lineCenterPoint.y + diameter;
                controlPoint2.x     = lineCenterPoint.x;
                controlPoint2.y     = lineEndPint.y;
                [line curveToPoint:lineCenterPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                controlPoint1.x     = lineCenterPoint.x;
                controlPoint1.y     = lineBeginPoint.y;
                controlPoint2.x     = lineBeginPoint.x + diameter;
                controlPoint2.y     = lineEndPint.y;
                [line curveToPoint:lineEndPint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                [line setLineWidth:self.lineWidth];
                if (self.lineStyle == KKGuideViewLineStyleDotted) {
                    CGFloat lengths[] = {self.lineWidth * 3,self.lineWidth};
                    [line setLineDash:lengths count:2 phase:0];
                }
                [line stroke];
                
                // 箭头
                [self drawArrowWithAngle:M_PI arrowCenter:lineEndPint];
                //[self drawArrowWithAngle:[self angleWithCenter:lineBeginPoint point:lineEndPint] arrowCenter:lineEndPint];
                
                break;
            }
            case KKRectAlignmentBottomRigth: {
                
                lineBeginPoint.x    = CGRectGetMidX(tipsViewFrame);
                lineBeginPoint.y    = self.isFlipped ? CGRectGetMaxY(tipsViewFrame) + spacing : CGRectGetMinY(tipsViewFrame) - spacing;
                
                lineEndPint.x       = CGRectGetMinX(self.targetViewFrame) - padding.right - spacing;
                lineEndPint.y       = CGRectGetMidY(self.targetViewFrame);
                
                if ((lineEndPint.x - lineBeginPoint.x) < lineOffset.x) {
                    lineBeginPoint.x = lineEndPint.x - lineOffset.x;
                }
                
                diameter            = [self diagonalDistanceWithPoint:lineBeginPoint otherPoint:lineEndPint] * 0.3;
                
                NSBezierPath *line  = [NSBezierPath bezierPath];
                [line moveToPoint:lineBeginPoint];
                lineCenterPoint.x   = (lineBeginPoint.x + lineEndPint.x) * 0.5;
                lineCenterPoint.y   = (lineBeginPoint.y + lineEndPint.y) * 0.5;
                controlPoint1.x     = lineBeginPoint.x;
                controlPoint1.y     = self.isFlipped ? lineCenterPoint.y - diameter : lineCenterPoint.y + diameter;
                controlPoint2.x     = lineCenterPoint.x;
                controlPoint2.y     = lineEndPint.y;
                [line curveToPoint:lineCenterPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                controlPoint1.x     = lineCenterPoint.x;
                controlPoint1.y     = lineBeginPoint.y;
                controlPoint2.x     = lineBeginPoint.x - diameter;
                controlPoint2.y     = lineEndPint.y;
                [line curveToPoint:lineEndPint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                [line setLineWidth:self.lineWidth];
                if (self.lineStyle == KKGuideViewLineStyleDotted) {
                    CGFloat lengths[] = {self.lineWidth * 3,self.lineWidth};
                    [line setLineDash:lengths count:2 phase:0];
                }
                [line stroke];
                
                // 箭头
                [self drawArrowWithAngle:0 arrowCenter:lineEndPint];
                //[self drawArrowWithAngle:[self angleWithCenter:lineBeginPoint point:lineEndPint] arrowCenter:lineEndPint];
                
                break;
            }
            case KKRectAlignmentBottom: {
                lineBeginPoint.x    = CGRectGetMidX(tipsViewFrame);
                lineBeginPoint.y    = self.isFlipped ? CGRectGetMaxY(tipsViewFrame) + spacing : CGRectGetMinY(tipsViewFrame) - spacing;
                
                lineEndPint.x       = CGRectGetMidX(self.targetViewFrame);
                lineEndPint.y       = self.isFlipped ? CGRectGetMinY(self.targetViewFrame) - spacing - padding.top :  CGRectGetMaxY(self.targetViewFrame) + spacing + padding.top;
                
                diameter            = [self diagonalDistanceWithPoint:lineBeginPoint otherPoint:lineEndPint] * 0.3;
                
                NSBezierPath *line  = [NSBezierPath bezierPath];
                [line moveToPoint:lineBeginPoint];
                lineCenterPoint.x   = (lineBeginPoint.x + lineEndPint.x) * 0.5 + diameter;
                lineCenterPoint.y   = (lineBeginPoint.y + lineEndPint.y) * 0.5;
                controlPoint1.x     = lineBeginPoint.x;
                controlPoint1.y     = self.isFlipped ? lineEndPint.y - diameter : lineEndPint.y + diameter;
                controlPoint2.x     = lineCenterPoint.x;
                controlPoint2.y     = controlPoint1.y;
                [line curveToPoint:lineCenterPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                controlPoint1.x     = lineCenterPoint.x;
                controlPoint1.y     = self.isFlipped ? lineBeginPoint.y + diameter : lineBeginPoint.y - diameter;
                controlPoint2.x     = lineBeginPoint.x;
                controlPoint2.y     = controlPoint1.y;
                [line curveToPoint:lineEndPint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                [line setLineWidth:self.lineWidth];
                if (self.lineStyle == KKGuideViewLineStyleDotted) {
                    CGFloat lengths[] = {self.lineWidth * 3,self.lineWidth};
                    [line setLineDash:lengths count:2 phase:0];
                }
                [line stroke];
                
                // 箭头
                //[self drawArrowWithAngle:M_PI_2 * 3 arrowCenter:lineEndPint];
                [self drawArrowWithAngle:[self angleWithCenter:lineBeginPoint point:lineEndPint] arrowCenter:lineEndPint];
                
                break;
            }
            default: {
                // KKRectAlignmentTop
                // KKRectAlignmentCenter
                lineBeginPoint.x    = CGRectGetMidX(tipsViewFrame);
                lineBeginPoint.y    = self.isFlipped ? CGRectGetMinY(tipsViewFrame) - spacing: CGRectGetMaxY(tipsViewFrame) + spacing;
                
                lineEndPint.x       = CGRectGetMidX(self.targetViewFrame);
                lineEndPint.y       = self.isFlipped ? CGRectGetMaxY(self.targetViewFrame) + spacing + padding.bottom : CGRectGetMinY(self.targetViewFrame) - spacing - padding.bottom;
                
                diameter            = [self diagonalDistanceWithPoint:lineBeginPoint otherPoint:lineEndPint] * 0.3;
                
                NSBezierPath *line  = [NSBezierPath bezierPath];
                [line moveToPoint:lineBeginPoint];
                lineCenterPoint.x   = (lineBeginPoint.x + lineEndPint.x) * 0.5 - diameter;
                lineCenterPoint.y   = (lineBeginPoint.y + lineEndPint.y) * 0.5;
                controlPoint1.x     = lineEndPint.x;
                controlPoint1.y     = self.isFlipped ? lineEndPint.y + diameter : lineEndPint.y - diameter;
                controlPoint2.x     = lineEndPint.x - diameter;
                controlPoint2.y     = controlPoint1.y;
                [line curveToPoint:lineCenterPoint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                controlPoint1.x     = lineBeginPoint.x - diameter;
                controlPoint1.y     = self.isFlipped ? lineBeginPoint.y - diameter : lineBeginPoint.y + diameter;
                controlPoint2.x     = lineBeginPoint.x;
                controlPoint2.y     = controlPoint1.y;
                [line curveToPoint:lineEndPint controlPoint1:controlPoint1 controlPoint2:controlPoint2];
                
                [line setLineWidth:self.lineWidth];
                if (self.lineStyle == KKGuideViewLineStyleDotted) {
                    CGFloat lengths[] = {self.lineWidth * 3,self.lineWidth};
                    [line setLineDash:lengths count:2 phase:0];
                }
                [line stroke];
                
                // 箭头
                //[self drawArrowWithAngle:M_PI_2 arrowCenter:lineEndPint];
                [self drawArrowWithAngle:[self angleWithCenter:lineBeginPoint point:lineEndPint] arrowCenter:lineEndPint];
                
                break;
            }
        }
    }
    if (self.tipsBorderLineStyle != KKGuideViewLineStyleNone)
    {
        NSEdgeInsets padding    = self.tipsBorderPadding;
        CGRect borderFrame = CGRectMake(tipsViewFrame.origin.x - padding.left, self.isFlipped ? tipsViewFrame.origin.y - padding.top : tipsViewFrame.origin.y - padding.bottom, tipsViewFrame.size.width + padding.left + padding.right, tipsViewFrame.size.height + padding.top + padding.bottom);
        
        NSBezierPath *border = [self shapePathWithStyle:self.tipsBorderShapeStyle rect:borderFrame cornerRadius:self.tipsBorderCornerRadius];
        [border setLineWidth:self.lineWidth];
        if (self.tipsBorderLineStyle == KKGuideViewLineStyleDotted) {
            CGFloat lengths[] = {self.lineWidth * 3,self.lineWidth};
            [border setLineDash:lengths count:2 phase:0];
        }
        [border stroke];
    }
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
    [arrow setLineWidth:self.lineWidth];
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

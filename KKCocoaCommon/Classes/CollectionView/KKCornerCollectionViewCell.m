//
//  KKCornerCollectionViewCell.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKCornerCollectionViewCell.h"
#import <QuartzCore/CAShapeLayer.h>
#import "NSBezierPath+KK.h"

@interface KKCornerCollectionViewCellBackgroundView : NSView

@property (nonatomic, copy) void(^block)(NSRect dirtyRect, BOOL isFlipped);

- (void)drawRectBlock:(void(^)(NSRect dirtyRect, BOOL isFlipped))block;

@end

@implementation KKCornerCollectionViewCellBackgroundView

- (void)drawRectBlock:(void (^)(NSRect, BOOL))block
{
    self.block = block;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    if (self.block) {
        self.block(dirtyRect, self.isFlipped);
    }
}

@end

@interface KKCornerCollectionViewCell ()<CALayerDelegate>

@property (nonatomic, strong) CAShapeLayer *maskLayer;

@end

@implementation KKCornerCollectionViewCell

- (void)loadView
{
    self.view = [KKCornerCollectionViewCellBackgroundView new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _separatorInset     = NSEdgeInsetsMake(0, 14.0, 0, 14.0);
    _borderLineWidth    = 1.0;
    _cornerRadius       = 6.0;
    _borderColor        = [NSColor colorWithWhite:0.5 alpha:0.1];
    
    KKCornerCollectionViewCellBackgroundView *view = (KKCornerCollectionViewCellBackgroundView *)self.view;
    __weak typeof(self) weakself = self;
    [view drawRectBlock:^(NSRect dirtyRect, BOOL isFlipped) {

        [weakself.borderColor setStroke];
        
        CGRect rect             = dirtyRect;
        CGFloat lineWidth       = weakself.borderLineWidth;
        CGFloat lineEdgeInset   = lineWidth * 0.5;
        CGSize cornerRadii      = CGSizeMake(weakself.cornerRadius, weakself.cornerRadius);
        CGFloat bottomLineY     = isFlipped ? rect.size.height - lineEdgeInset : lineEdgeInset;
        NSEdgeInsets separatorInset = weakself.separatorInset;
        
        switch (weakself.corner) {
            case KKCornerCollectionViewCellCornerMiddle: {
                NSBezierPath *path = [NSBezierPath bezierPath];
                [path moveToPoint:CGPointMake(lineEdgeInset, 0)];
                [path lineToPoint:CGPointMake(lineEdgeInset, rect.size.height)];
                path.lineWidth = lineWidth;
                [path stroke];
                
                path = [NSBezierPath bezierPath];
                [path moveToPoint:CGPointMake(rect.size.width - lineEdgeInset, 0)];
                [path lineToPoint:CGPointMake(rect.size.width - lineEdgeInset, rect.size.height)];
                path.lineWidth = lineWidth;
                [path stroke];
                
                path = [NSBezierPath bezierPath];
                [path moveToPoint:CGPointMake(separatorInset.left, bottomLineY)];
                [path lineToPoint:CGPointMake(rect.size.width - separatorInset.right, bottomLineY)];
                path.lineWidth = lineWidth;
                [path stroke];
                break;
            }
            case KKCornerCollectionViewCellCornerTop: {
                CGRect bezierRect = CGRectMake(lineEdgeInset, lineEdgeInset, rect.size.width - lineWidth, rect.size.height + lineWidth);
                NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:bezierRect byRoundingCorners:KKRectCornerTopLeft | KKRectCornerTopRight cornerRadii:cornerRadii viewIsFlipped:isFlipped viewBounds:dirtyRect];
                path.lineWidth = lineWidth;
                [path stroke];
                
                path = [NSBezierPath bezierPath];
                [path moveToPoint:CGPointMake(separatorInset.left, bottomLineY)];
                [path lineToPoint:CGPointMake(rect.size.width - separatorInset.right, bottomLineY)];
                path.lineWidth = lineWidth;
                [path stroke];
                break;
            }
            case KKCornerCollectionViewCellCornerBottom: {
                CGRect bezierRect = CGRectMake(lineEdgeInset, -lineEdgeInset, rect.size.width - lineWidth, rect.size.height - lineEdgeInset);
                NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:bezierRect byRoundingCorners:KKRectCornerBottomLeft | KKRectCornerBottomRight cornerRadii:cornerRadii viewIsFlipped:isFlipped viewBounds:dirtyRect];
                path.lineWidth = lineWidth;
                [path stroke];
                break;
            }
            case KKCornerCollectionViewCellCornerAll: {
                CGRect bezierRect = CGRectMake(lineEdgeInset, lineEdgeInset, rect.size.width - lineWidth, rect.size.height - lineWidth);
                NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:bezierRect cornerRadius:cornerRadii.width];
                path.lineWidth = lineWidth;
                [path stroke];
                break;
            }
            default: {
                
                break;
            }
        }
    }];
}

- (void)setSeparatorInset:(NSEdgeInsets)separatorInset
{
    _separatorInset = separatorInset;
    [self.view setNeedsDisplay:YES];
}

- (void)setCorner:(KKCornerCollectionViewCellCorner)corner
{
    if (_corner == corner) {
        return;
    }
    _corner = corner;
    [self.view setNeedsDisplay:YES];
    [self updateMaskLayer];
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    if (_cornerRadius == cornerRadius) {
        return;
    }
    _cornerRadius = cornerRadius;
    [self.view setNeedsDisplay:YES];
    [self updateMaskLayer];
}

- (void)setBorderColor:(NSColor *)borderColor
{
    _borderColor = borderColor != nil ? borderColor : NSColor.lightGrayColor;
    [self.view setNeedsDisplay:YES];
}

- (void)setBorderLineWidth:(CGFloat)borderLineWidth
{
    _borderLineWidth = borderLineWidth;
    [self.view setNeedsDisplay:YES];
}

- (void)setMasksToCorners:(BOOL)masksToCorners
{
    if (_masksToCorners == masksToCorners) {
        return;
    }
    _masksToCorners = masksToCorners;
    [self updateMaskLayer];
}

- (CAShapeLayer *)maskLayer
{
    if (_maskLayer == nil) {
        _maskLayer = [CAShapeLayer new];
        _maskLayer.fillRule = kCAFillRuleNonZero;
    }
    return _maskLayer;
}

- (void)viewDidLayout
{
    [super viewDidLayout];
    [self updateMaskLayer];
}

- (void)updateMaskLayer
{
    if (self.masksToCorners == NO ||
        (self.corner != KKCornerCollectionViewCellCornerTop &&
         self.corner != KKCornerCollectionViewCellCornerBottom)) {
        if (self.view.layer.mask) {
            self.view.layer.mask = nil;
        }
        return;
    }
    if (self.view.layer.mask == nil) {
        self.view.layer.mask = self.maskLayer;
    }
    CGSize cornerRadii = CGSizeMake(self.cornerRadius, self.cornerRadius);
    switch (self.corner) {
        case KKCornerCollectionViewCellCornerTop: {
            __weak typeof(self) weakself = self;
            [[NSBezierPath bezierPathWithRoundedRect:self.view.bounds byRoundingCorners:KKRectCornerTopLeft | KKRectCornerTopRight cornerRadii:cornerRadii] CGPathBlock:^(CGPathRef  _Nonnull CGPath) {
                weakself.maskLayer.path = CGPath;
            }];
            break;
        }
        case KKCornerCollectionViewCellCornerBottom: {
            __weak typeof(self) weakself = self;
            [[NSBezierPath bezierPathWithRoundedRect:self.view.bounds byRoundingCorners:KKRectCornerBottomLeft | KKRectCornerBottomRight cornerRadii:cornerRadii] CGPathBlock:^(CGPathRef  _Nonnull CGPath) {
                weakself.maskLayer.path = CGPath;
            }];
            break;
        }
        default: {
            
            break;
        }
    }
}

- (void)setCornersWithCollectionView:(NSCollectionView *)collectionView indexPath:(NSIndexPath *)indexPath
{
    if ([collectionView.dataSource respondsToSelector:@selector(collectionView:numberOfItemsInSection:)]) {
         NSInteger cellCount = [collectionView.dataSource collectionView:collectionView numberOfItemsInSection:indexPath.section];
        if (cellCount == 1) {
            self.corner = KKCornerCollectionViewCellCornerAll;
        } else if (indexPath.item == 0) {
            self.corner = KKCornerCollectionViewCellCornerTop;
        } else if (indexPath.item == cellCount - 1) {
            self.corner = KKCornerCollectionViewCellCornerBottom;
        } else {
            self.corner = KKCornerCollectionViewCellCornerMiddle;
        }
    }
}

@end

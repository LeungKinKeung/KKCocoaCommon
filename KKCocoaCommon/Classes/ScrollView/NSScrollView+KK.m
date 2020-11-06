//
//  NSScrollView+KK.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "NSScrollView+KK.h"

static CGFloat _animationDuration = 0.3;

@implementation NSScrollView (KK)

- (void)scrollUp:(CGFloat)value animated:(BOOL)animated
{
    if (self.documentView == nil) {
        return;
    }
    if (animated) {
        [NSAnimationContext beginGrouping];
        NSAnimationContext *ctx     = [NSAnimationContext currentContext];
        ctx.duration                = _animationDuration;
        ctx.allowsImplicitAnimation = YES;
    }
    CGFloat originY     = self.contentView.bounds.origin.y;
    NSPoint newOrigin   = NSMakePoint(0, originY - value);
    CGFloat y           = self.documentView.frame.size.height - self.contentSize.height;
    if (newOrigin.y <= 0) {
        newOrigin.y = 1;
    }
    if (self.hasVerticalScroller) {
        self.verticalScroller.doubleValue = (newOrigin.y / y);
    }
    [self.contentView scrollToPoint:newOrigin];
    if (animated) {
        [NSAnimationContext endGrouping];
    }
}

- (void)scrollLow:(CGFloat)value animated:(BOOL)animated
{
    if (self.documentView == nil) {
        return;
    }
    if (animated) {
        [NSAnimationContext beginGrouping];
        NSAnimationContext *ctx     = [NSAnimationContext currentContext];
        ctx.duration                = _animationDuration;
        ctx.allowsImplicitAnimation = YES;
    }
    CGFloat originY     = self.contentView.bounds.origin.y;
    NSPoint newOrigin   = NSMakePoint(0, originY + value);
    CGFloat y           = self.documentView.frame.size.height - self.contentSize.height;
    if (newOrigin.y >= y) {
        newOrigin.y = y - 1;
    }
    if (self.hasVerticalScroller) {
        self.verticalScroller.doubleValue = (newOrigin.y / y);
    }
    [self.contentView scrollToPoint:newOrigin];
    if (animated) {
        [NSAnimationContext endGrouping];
    }
}

- (void)scrollToTopUsingAnimation:(BOOL)animated
{
    if (self.documentView == nil) {
        return;
    }
    if (animated) {
        [NSAnimationContext beginGrouping];
        NSAnimationContext *ctx     = [NSAnimationContext currentContext];
        ctx.duration                = _animationDuration;
        ctx.allowsImplicitAnimation = YES;
    }
    if (self.hasVerticalScroller) {
        self.verticalScroller.floatValue = 0;
    }
    CGFloat y = 0;
    if (self.documentView.isFlipped) {
        y = -self.contentInsets.top;
    } else {
        y = NSMaxY(self.documentView.frame) - NSHeight(self.contentView.bounds);
    }
    [self.contentView scrollToPoint:NSMakePoint(0, y)];
    if (animated) {
        [NSAnimationContext endGrouping];
    }
}

- (void)scrollToBottomUsingAnimation:(BOOL)animated
{
    if (self.documentView == nil) {
        return;
    }
    if (animated) {
        [NSAnimationContext beginGrouping];
        NSAnimationContext *ctx     = [NSAnimationContext currentContext];
        ctx.duration                = _animationDuration;
        ctx.allowsImplicitAnimation = YES;
    }
    if (self.hasVerticalScroller) {
        self.verticalScroller.floatValue = 1;
    }
    NSPoint newOrigin = NSZeroPoint;
    if (self.documentView.isFlipped) {
        CGFloat originY = self.documentView.frame.size.height - self.contentSize.height + self.contentInsets.bottom;
        newOrigin       = NSMakePoint(0, originY);
    } else {
        newOrigin       = NSMakePoint(0, 0);
    }
    [self.contentView scrollToPoint:newOrigin];
    if (animated) {
        [NSAnimationContext endGrouping];
    }
}

- (void)adjustVerticalScroller
{
    CGRect docViewFrame         = self.documentView.frame;
    CGRect contentViewBounds    = self.contentView.bounds;
    CGFloat maxY = docViewFrame.size.height - contentViewBounds.size.height;
    if (maxY == 0) {
        maxY = 1;
    }
    CGFloat value               = contentViewBounds.origin.y / maxY;
    if (self.hasVerticalScroller) {
        self.verticalScroller.doubleValue = value;
    }
}

- (void)adjustsContentViewBounds
{
    NSClipView *clipView    = self.contentView;
    clipView.bounds         = [clipView constrainBoundsRect:clipView.bounds];
}

@end

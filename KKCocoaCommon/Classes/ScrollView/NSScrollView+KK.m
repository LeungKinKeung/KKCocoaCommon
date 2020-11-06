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

- (void)adjustHorizontalScroller
{
    CGRect docViewFrame         = self.documentView.frame;
    CGRect contentViewBounds    = self.contentView.bounds;
    CGFloat maxX = docViewFrame.size.width - contentViewBounds.size.width;
    if (maxX == 0) {
        maxX = 1;
    }
    CGFloat value               = contentViewBounds.origin.y / maxX;
    if (self.hasHorizontalScroller) {
        self.horizontalScroller.doubleValue = value;
    }
}

- (void)adjustsContentViewBounds
{
    NSClipView *clipView    = self.contentView;
    clipView.bounds         = [clipView constrainBoundsRect:clipView.bounds];
}

- (void)scrollToRect:(CGRect)rect atScrollPosition:(KKScrollViewScrollPosition)scrollPosition animated:(BOOL)animated
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
    CGFloat docViewHeight = self.documentView.frame.size.height;
    CGFloat y = 0;
    if (self.documentView.isFlipped) {
        switch (scrollPosition) {
            case KKScrollViewScrollPositionBottom: {
                y = rect.origin.y - self.contentSize.height + rect.size.height;
                break;
            }
            case KKScrollViewScrollPositionMiddle: {
                y = rect.origin.y - self.contentSize.height * 0.5 + rect.size.height * 0.5;
                break;
            }
            default: {
                y = rect.origin.y;
                break;
            }
        }
        if (y < 0) {
            // 顶部越出
            y = 0;
        }
        if (docViewHeight - y < self.contentSize.height) {
            // 底部越出
            y = docViewHeight - self.contentSize.height;
        }
    } else {
        y = rect.origin.y;
        if (y < 0) {
            // 底部越出
            y = 0;
        }
        if (docViewHeight - y < self.contentSize.height) {
            // 顶部越出
            y = docViewHeight - self.contentSize.height;
        }
    }
    [self.contentView scrollToPoint:NSMakePoint(rect.origin.x, y)];
    [self adjustVerticalScroller];
    if (animated) {
        [NSAnimationContext endGrouping];
    }
}


@end

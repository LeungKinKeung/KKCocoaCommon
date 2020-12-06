//
//  NSScrollView+KK.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "NSScrollView+KK.h"

static CGFloat gAnimationDuration = 0.3;

@implementation NSScrollView (KK)

- (void)scrollUp:(CGFloat)value animated:(BOOL)animated
{
    if (self.documentView == nil) {
        return;
    }
    if (animated) {
        [NSAnimationContext beginGrouping];
        NSAnimationContext *ctx     = [NSAnimationContext currentContext];
        ctx.duration                = gAnimationDuration;
        ctx.allowsImplicitAnimation = YES;
    }
    CGFloat originY     = 0;
    if (self.documentView.isFlipped) {
        originY         = self.contentView.bounds.origin.y + value;
    } else {
        originY         = self.contentView.bounds.origin.y - value;
    }
    NSPoint newOrigin   = NSMakePoint(self.contentView.bounds.origin.x, originY);
    [self.contentView scrollToPoint:[self adjustPoint:newOrigin]];
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
        ctx.duration                = gAnimationDuration;
        ctx.allowsImplicitAnimation = YES;
    }
    CGFloat originY     = 0;
    if (self.documentView.isFlipped) {
        originY         = self.contentView.bounds.origin.y - value;
    } else {
        originY         = self.contentView.bounds.origin.y + value;
    }
    NSPoint newOrigin   = NSMakePoint(self.contentView.bounds.origin.x, originY);
    [self.contentView scrollToPoint:[self adjustPoint:newOrigin]];
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
        ctx.duration                = gAnimationDuration;
        ctx.allowsImplicitAnimation = YES;
    }
    if (self.hasVerticalScroller) {
        self.verticalScroller.floatValue = 0;
    }
    CGFloat x = self.contentView.bounds.origin.x;
    CGFloat y = 0;
    if (self.documentView.isFlipped) {
        y = -self.contentInsets.top;
    } else {
        y = NSMaxY(self.documentView.frame) - NSHeight(self.contentView.bounds) + self.contentInsets.top;
    }
    [self.contentView scrollToPoint:NSMakePoint(x, y)];
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
        ctx.duration                = gAnimationDuration;
        ctx.allowsImplicitAnimation = YES;
    }
    if (self.hasVerticalScroller) {
        self.verticalScroller.floatValue = 1;
    }
    CGFloat originX     = self.contentView.bounds.origin.x;
    NSPoint newOrigin   = NSZeroPoint;
    if (self.documentView.isFlipped) {
        CGFloat originY = self.documentView.frame.size.height - self.contentSize.height + self.contentInsets.bottom;
        newOrigin       = NSMakePoint(originX, originY);
    } else {
        newOrigin       = NSMakePoint(originX, -self.contentInsets.bottom);
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
        ctx.duration                = gAnimationDuration;
        ctx.allowsImplicitAnimation = YES;
    }
    CGFloat y = 0;
    if (self.documentView.isFlipped) {
        switch (scrollPosition) {
            case KKScrollViewScrollPositionBottom: {
                y = rect.origin.y - self.contentSize.height + rect.size.height + self.contentInsets.bottom;
                break;
            }
            case KKScrollViewScrollPositionMiddle: {
                y = rect.origin.y - self.contentSize.height * 0.5 + rect.size.height * 0.5 + self.contentInsets.bottom * 0.5 - self.contentInsets.top * 0.5;
                break;
            }
            default: {
                y = rect.origin.y - self.contentInsets.top;
                break;
            }
        }
    } else {
        switch (scrollPosition) {
            case KKScrollViewScrollPositionBottom: {
                y = rect.origin.y - self.contentInsets.bottom;
                break;
            }
            case KKScrollViewScrollPositionMiddle: {
                y = rect.origin.y - self.contentSize.height * 0.5 + rect.size.height * 0.5 - self.contentInsets.bottom * 0.5 + self.contentInsets.top * 0.5;
                break;
            }
            default: {
                y = rect.origin.y - self.contentSize.height + rect.size.height + self.contentInsets.top;
                break;
            }
        }
    }
    CGPoint adjustedPoint = [self adjustPoint:CGPointMake(rect.origin.x, y)];
    [self.contentView scrollToPoint:adjustedPoint];
    if (animated) {
        [NSAnimationContext endGrouping];
    }
}

- (CGPoint)adjustPoint:(CGPoint)point
{
    CGFloat docViewHeight = self.documentView.frame.size.height;
    CGFloat x = point.x;
    CGFloat y = point.y;
    if (self.documentView.isFlipped) {
        if (y < -self.contentInsets.top) {
            // 顶部越出
            y = -self.contentInsets.top;
        }
        if ((docViewHeight - y - self.contentInsets.bottom) < self.contentSize.height) {
            // 底部越出
            y = docViewHeight - self.contentSize.height + self.contentInsets.bottom;
        }
    } else {
        if (y < -self.contentInsets.bottom) {
            // 底部越出
            y = -self.contentInsets.bottom;
        }
        if ((docViewHeight - y - self.contentInsets.top) < self.contentSize.height) {
            // 顶部越出
            y = docViewHeight - self.contentSize.height + self.contentInsets.top;
        }
    }
    return CGPointMake(x, y);
}


@end

//
//  NSView+KK.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "NSView+KK.h"

@implementation NSView (KK)

- (void)setLayerBackgroundColor:(NSColor *)layerBackgroundColor
{
    if (self.layer == nil) {
        self.wantsLayer = YES;
    }
    self.layer.backgroundColor = layerBackgroundColor.CGColor;
}

- (NSColor *)layerBackgroundColor
{
    if (self.layer.backgroundColor == NULL) {
        return nil;
    }
    return [NSColor colorWithCGColor:self.layer.backgroundColor];
}

- (void)updateTrackingAreasWithOptions:(NSTrackingAreaOptions)options
{
    for (NSTrackingArea *trackingArea in self.trackingAreas) {
        if (trackingArea.options == options) {
            [self removeTrackingArea:trackingArea];
            break;;
        }
    }
    NSTrackingArea *trackingArea =
    [[NSTrackingArea alloc] initWithRect:self.bounds options:options owner:self userInfo:nil];
    
    [self addTrackingArea:trackingArea];
}

- (void)popUpMenu:(NSMenu *)menu
{
    CGPoint point   = [self convertRect:self.bounds toView:self.window.contentView].origin;
    //point.x         = point.x + self.bounds.size.width * 0.5 - self.menu.size.width * 0.5;
    point.y         = point.y - 6;
    
    NSEvent *popupEvent =
    [NSEvent mouseEventWithType:NSEventTypeLeftMouseDown
                       location:point
                  modifierFlags:0
                      timestamp:0
                   windowNumber:self.window.windowNumber
                        context:self.window.graphicsContext
                    eventNumber:0
                     clickCount:1
                       pressure:1];
    
    [NSMenu popUpContextMenu:menu withEvent:popupEvent forView:self];
}

- (KKRectAlignment)centerAlignmentAtView:(NSView *)view
{
    BOOL isFlipped      = view.isFlipped;
    NSRect frame        = [view convertRect:self.bounds fromView:self];
    NSPoint selfCenter  = CGPointMake(frame.origin.x + frame.size.width * 0.5,
                                      frame.origin.y - (isFlipped ? frame.size.height * 0.5 : -frame.size.height * 0.5));
    NSPoint viewCenter  = CGPointMake(view.frame.origin.x + view.frame.size.width * 0.5,
                                      view.frame.origin.y + view.frame.size.height * 0.5);
    
    KKRectAlignment alignment   = KKRectAlignmentCenter;
    if (selfCenter.x == viewCenter.x) {
        // 水平对齐
        if (selfCenter.y == viewCenter.y) {
            alignment = KKRectAlignmentCenter;
        } else if (selfCenter.y > viewCenter.y) {
            alignment = isFlipped ? KKRectAlignmentBottom : KKRectAlignmentTop;
        } else {
            alignment = isFlipped ? KKRectAlignmentTop : KKRectAlignmentBottom;
        }
    } else if (selfCenter.y == viewCenter.y) {
        // 垂直对齐
        if (selfCenter.x > viewCenter.x) {
            alignment = KKRectAlignmentRigth;
        } else {
            alignment = KKRectAlignmentLeft;
        }
    } else {
        if (selfCenter.x > viewCenter.x && selfCenter.y > viewCenter.y) {
            alignment = isFlipped ? KKRectAlignmentBottomRigth : KKRectAlignmentTopRigth;
        } else if (selfCenter.x > viewCenter.x && selfCenter.y < viewCenter.y) {
            alignment = isFlipped ? KKRectAlignmentTopRigth : KKRectAlignmentBottomRigth;
        } else if (selfCenter.x < viewCenter.x && selfCenter.y > viewCenter.y) {
            alignment = isFlipped ? KKRectAlignmentBottomLeft : KKRectAlignmentTopLeft;
        } else {
            alignment = isFlipped ? KKRectAlignmentTopLeft : KKRectAlignmentBottomLeft;
        }
    }
    return alignment;
}

- (KKRectAlignment)alignmentAtView:(NSView *)view
{
    BOOL isFlipped      = view.isFlipped;
    NSRect frame        = [view convertRect:self.bounds fromView:self];
    NSPoint selfCenter  = CGPointMake(frame.origin.x + frame.size.width * 0.5,
                                      frame.origin.y - (isFlipped ? frame.size.height * 0.5 : -frame.size.height * 0.5));
    NSPoint viewCenter  = CGPointMake(view.frame.origin.x + view.frame.size.width * 0.5,
                                      view.frame.origin.y + view.frame.size.height * 0.5);
    
    CGFloat minX        = CGRectGetMinX(frame);
    CGFloat minY        = isFlipped ? CGRectGetMinY(frame) : CGRectGetMaxY(frame);
    CGFloat maxX        = CGRectGetMaxX(frame);
    CGFloat maxY        = isFlipped ? CGRectGetMaxY(frame) : CGRectGetMinY(frame);
    
    KKRectAlignment alignment   = KKRectAlignmentCenter;
    if (selfCenter.x == viewCenter.x) {
        // 水平对齐
        if (minY > viewCenter.y) {
            alignment = isFlipped ? KKRectAlignmentBottom : KKRectAlignmentTop;
        } else  if (maxY < viewCenter.y)  {
            alignment = isFlipped ? KKRectAlignmentTop : KKRectAlignmentBottom;
        }
    } else if (selfCenter.y == viewCenter.y) {
        // 垂直对齐
        if (minX > viewCenter.x) {
            alignment = KKRectAlignmentRigth;
        } else if (maxX < viewCenter.x) {
            alignment = KKRectAlignmentLeft;
        }
    } else {
        if (minX > viewCenter.x) {
            if (minY > viewCenter.y) {
                alignment = isFlipped ? KKRectAlignmentBottomRigth : KKRectAlignmentTopRigth;
            } else {
                alignment = isFlipped ? KKRectAlignmentTopRigth : KKRectAlignmentBottomRigth;
            }
        } else if (maxX < viewCenter.x) {
            if (minY > viewCenter.y) {
                alignment = isFlipped ? KKRectAlignmentBottomLeft : KKRectAlignmentTopLeft;
            } else {
                alignment = isFlipped ? KKRectAlignmentTopLeft : KKRectAlignmentBottomLeft;
            }
        } else if (minY > viewCenter.y) {
            alignment = isFlipped ? KKRectAlignmentBottom : KKRectAlignmentTop;
        } else {
            alignment = isFlipped ? KKRectAlignmentTop : KKRectAlignmentBottom;
        }
    }
    return alignment;
}


@end

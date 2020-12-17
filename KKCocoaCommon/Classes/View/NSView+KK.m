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

@end

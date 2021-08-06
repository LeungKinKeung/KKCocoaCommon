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
    [menu popUpMenuPositioningItem:nil atLocation:NSMakePoint(0, self.bounds.size.height + 6) inView:self];
}

@end

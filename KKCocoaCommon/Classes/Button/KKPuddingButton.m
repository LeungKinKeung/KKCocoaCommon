//
//  KKPuddingButton.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/11/16.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKPuddingButton.h"
#import "NSView+KKAnimation.h"

@interface KKPuddingButton ()

@property (nonatomic, assign, getter=isMouseInside) BOOL mouseInside;

@end

@implementation KKPuddingButton

- (void)updateTrackingAreas
{
    [super updateTrackingAreas];
    
    NSTrackingAreaOptions options = NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways;
    
    for (NSTrackingArea *trackingArea in self.trackingAreas) {
        if (trackingArea.options == options) {
            [self removeTrackingArea:trackingArea];
            break;
        }
    }
    NSTrackingArea *trackingArea =
    [[NSTrackingArea alloc] initWithRect:self.bounds options:options owner:self userInfo:nil];
    
    [self addTrackingArea:trackingArea];
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    self.mouseInside = YES;
}

- (void)mouseExited:(NSEvent *)event
{
    self.mouseInside = NO;
}

- (void)mouseDown:(NSEvent *)event
{
    if (self.enabled == NO) {
        return;
    }
    [self addCAAnimationWithDuration:0.1 fromScale:1 toScale:0.95 forKey:nil removedOnCompletion:NO completionBlock:nil];
}

- (void)mouseUp:(NSEvent *)event
{
    if (self.enabled == NO) {
        return;
    }
    if (self.isMouseInside) {
        __weak typeof(self) weakself = self;
        [self addCAAnimationWithDuration:0.35 fromScale:0.85 toScale:1.0 forKey:nil removedOnCompletion:NO completionBlock:^(BOOL animationFinished) {
            if (animationFinished) {
                [weakself removeAllCAAnimations];
            }
        }];
        
        if (self.action && self.target) {
            [NSApp sendAction:[self action] to:[self target] from:self];
        }
    } else {
        [self removeAllCAAnimations];
    }
    [super mouseUp:event];
}



@end

//
//  KKLoopRotateImageView.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKLoopRotateImageView.h"
#import "NSView+KKAnimation.h"

@implementation KKLoopRotateImageView

- (void)resizeWithOldSuperviewSize:(NSSize)oldSize
{
    [super resizeWithOldSuperviewSize:oldSize];
    [self stopAnimation];
}

- (void)updateTrackingAreas
{
    [super updateTrackingAreas];
    if (self.isHidden == NO) {
        [self stopAnimation];
        [self startAnimation];
    }
}

- (void)setHidden:(BOOL)hidden
{
    [super setHidden:hidden];
    if (hidden) {
        [self stopAnimation];
    } else {
        [self startAnimation];
    }
}

- (void)startAnimation
{
    [self addLoopRotateAnimationForKey:[self className]];
}

- (void)stopAnimation
{
    [self.layer removeAnimationForKey:[self className]];
}

- (void)dealloc
{
    [self stopAnimation];
}

@end

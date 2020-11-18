//
//  KKClipView.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKClipView.h"

CGFloat KKClipViewCenteredCoordinateUnit(CGFloat proposedContentViewBoundsDimension, CGFloat documentViewFrameDimension);

@implementation KKClipView

#pragma mark 通知
- (void)viewFrameChanged:(NSNotification *)notification
{
    if (self.postsFrameChangedNotifications) {
        [[NSNotificationCenter defaultCenter] postNotificationName:
         NSViewFrameDidChangeNotification object:self];
    }
}

#pragma mark 约束位置
- (NSRect)constrainBoundsRect:(NSRect)proposedBounds
{
    NSRect constrainedClipViewBoundsRect = [super constrainBoundsRect:proposedBounds];
    
    NSRect documentViewFrameRect = [self.documentView frame];
    
    if (proposedBounds.size.width >= documentViewFrameRect.size.width) {
        constrainedClipViewBoundsRect.origin.x =
        KKClipViewCenteredCoordinateUnit(proposedBounds.size.width, documentViewFrameRect.size.width);
    }
    if (proposedBounds.size.height >= documentViewFrameRect.size.height) {
        constrainedClipViewBoundsRect.origin.y =
        KKClipViewCenteredCoordinateUnit(proposedBounds.size.height, documentViewFrameRect.size.height);
    }
    return constrainedClipViewBoundsRect;
}

CGFloat KKClipViewCenteredCoordinateUnit(CGFloat proposedContentViewBoundsDimension, CGFloat documentViewFrameDimension)
{
    CGFloat result = floor((proposedContentViewBoundsDimension - documentViewFrameDimension) / -2.0);
    return result;
}

@end

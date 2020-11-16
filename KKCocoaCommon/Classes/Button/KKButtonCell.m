//
//  KKButtonCell.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/11/16.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKButtonCell.h"

@implementation KKButtonCell

- (NSSize)cellSizeForBounds:(NSRect)rect
{
    if (self.imagePosition != NSImageLeft &&
        self.imagePosition != NSImageRight &&
        self.imagePosition != NSImageAbove &&
        self.imagePosition != NSImageBelow) {
        return [super cellSizeForBounds:rect];
    }
    CGSize titleSize    = self.attributedTitle.size;
    CGSize imageSize    = self.image.size;
    CGFloat width       = 0;
    CGFloat height      = 0;
    
    switch (self.imagePosition)
    {
        case NSImageLeft:
        case NSImageRight:
        {
            // 图片在左侧/右侧
            width   = titleSize.width + imageSize.width + self.margin.left + self.margin.right + self.interitemSpacing;
            height  = MAX(imageSize.height, titleSize.height) + self.margin.top + self.margin.bottom;
            break;
        }
        case NSImageAbove:
        case NSImageBelow:
        {
            // 图片在上侧/下侧
            width   = MAX(titleSize.width, imageSize.width) + self.margin.left + self.margin.right;
            height  = imageSize.height + titleSize.height + self.margin.top + self.margin.bottom + self.interitemSpacing;
            break;
        }
        default:
        {
            return [super cellSizeForBounds:rect];
        }
    }
    return CGSizeMake(width, height);
}

- (NSRect)titleRectForBounds:(NSRect)rect
{
    if (self.imagePosition != NSImageLeft &&
        self.imagePosition != NSImageRight &&
        self.imagePosition != NSImageAbove &&
        self.imagePosition != NSImageBelow) {
        return [super titleRectForBounds:rect];
    }
    CGSize titleSize    = self.attributedTitle.size;
    CGSize imageSize    = self.image.size;
    NSEdgeInsets margin = self.margin;
    CGFloat rectX       = 0;
    CGFloat rectY       = 0;
    switch (self.imagePosition)
    {
        case NSImageLeft:
        {
            // 图片在左侧
            CGFloat contentWidth = titleSize.width + imageSize.width + self.interitemSpacing;
            CGFloat unusedWidth = rect.size.width - margin.left - margin.right - contentWidth;
            CGFloat alignmentSpacing = unusedWidth * 0.5;
            rectX = margin.left + alignmentSpacing + imageSize.width + self.interitemSpacing;
            rectY = (rect.size.height - margin.top - margin.bottom - titleSize.height) * 0.5 + margin.top;
            break;
        }
        case NSImageRight:
        {
            // 图片在右侧
            CGFloat contentWidth = titleSize.width + imageSize.width + self.interitemSpacing;
            CGFloat unusedWidth = rect.size.width - margin.left - margin.right - contentWidth;
            CGFloat alignmentSpacing = unusedWidth * 0.5;
            rectX = margin.left + alignmentSpacing;
            rectY = (rect.size.height - margin.top - margin.bottom - titleSize.height) * 0.5 + margin.top;
            break;
        }
        case NSImageAbove:
        {
            // 图片在上侧
            CGFloat contentHeight = titleSize.height + imageSize.height + self.interitemSpacing;
            CGFloat unusedHeight = rect.size.height - margin.top - margin.bottom - contentHeight;
            CGFloat alignmentSpacing = unusedHeight * 0.5;
            rectX = (rect.size.width - margin.left - margin.right - titleSize.width) * 0.5 + margin.left;
            rectY = margin.top + alignmentSpacing + imageSize.height + self.interitemSpacing;
            break;
        }
        case NSImageBelow:
        {
            // 图片在下侧
            CGFloat contentHeight = titleSize.height + imageSize.height + self.interitemSpacing;
            CGFloat unusedHeight = rect.size.height - margin.top - margin.bottom - contentHeight;
            CGFloat alignmentSpacing = unusedHeight * 0.5;
            rectX = (rect.size.width - margin.left - margin.right - titleSize.width) * 0.5 + margin.left;
            rectY = margin.top + alignmentSpacing;
            break;
        }
        default:
        {
            return [super titleRectForBounds:rect];
        }
    }
    return CGRectMake(rectX, rectY, titleSize.width, titleSize.height);
}

- (NSRect)imageRectForBounds:(NSRect)rect
{
    if (self.imagePosition != NSImageLeft &&
        self.imagePosition != NSImageRight &&
        self.imagePosition != NSImageAbove &&
        self.imagePosition != NSImageBelow) {
        return [super imageRectForBounds:rect];
    }
    CGSize titleSize    = self.attributedTitle.size;
    CGSize imageSize    = self.image.size;
    NSEdgeInsets margin = self.margin;
    CGFloat rectX       = 0;
    CGFloat rectY       = 0;
    switch (self.imagePosition)
    {
        case NSImageLeft:
        {
            // 图片在左侧
            CGFloat contentWidth = titleSize.width + imageSize.width + self.interitemSpacing;
            CGFloat unusedWidth = rect.size.width - margin.left - margin.right - contentWidth;
            CGFloat alignmentSpacing = unusedWidth * 0.5;
            rectX = margin.left + alignmentSpacing;
            rectY = (rect.size.height - margin.top - margin.bottom - imageSize.height) * 0.5 + margin.top;
            break;
        }
        case NSImageRight:
        {
            // 图片在右侧
            CGFloat contentWidth = titleSize.width + imageSize.width + self.interitemSpacing;
            CGFloat unusedWidth = rect.size.width - margin.left - margin.right - contentWidth;
            CGFloat alignmentSpacing = unusedWidth * 0.5;
            rectX = margin.left + alignmentSpacing + titleSize.width + self.interitemSpacing;
            rectY = (rect.size.height - margin.top - margin.bottom - imageSize.height) * 0.5 + margin.top;
            break;
        }
        case NSImageAbove:
        {
            // 图片在上侧
            CGFloat contentHeight = titleSize.height + imageSize.height + self.interitemSpacing;
            CGFloat unusedHeight = rect.size.height - margin.top - margin.bottom - contentHeight;
            CGFloat alignmentSpacing = unusedHeight * 0.5;
            rectX = (rect.size.width - margin.left - margin.right - imageSize.width) * 0.5 + margin.left;
            rectY = margin.top + alignmentSpacing;
            break;
        }
        case NSImageBelow:
        {
            // 图片在下侧
            CGFloat contentHeight = titleSize.height + imageSize.height + self.interitemSpacing;
            CGFloat unusedHeight = rect.size.height - margin.top - margin.bottom - contentHeight;
            CGFloat alignmentSpacing = unusedHeight * 0.5;
            rectX = (rect.size.width - margin.left - margin.right - imageSize.width) * 0.5 + margin.left;
            rectY = margin.top + alignmentSpacing + titleSize.height + self.interitemSpacing;
            break;
        }
        default:
        {
            return [super imageRectForBounds:rect];
        }
    }
    return CGRectMake(rectX, rectY, imageSize.width, imageSize.height);
}


@end

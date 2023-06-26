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
            width   = titleSize.width + imageSize.width + self.padding.left + self.padding.right + self.interitemSpacing;
            height  = MAX(imageSize.height, titleSize.height) + self.padding.top + self.padding.bottom;
            break;
        }
        case NSImageAbove:
        case NSImageBelow:
        {
            // 图片在上侧/下侧
            width   = MAX(titleSize.width, imageSize.width) + self.padding.left + self.padding.right;
            height  = imageSize.height + titleSize.height + self.padding.top + self.padding.bottom + self.interitemSpacing;
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
    NSEdgeInsets padding = self.padding;
    CGFloat rectX       = 0;
    CGFloat rectY       = 0;
    switch (self.imagePosition)
    {
        case NSImageLeft:
        {
            // 图片在左侧
            CGFloat contentWidth = titleSize.width + imageSize.width + self.interitemSpacing;
            CGFloat unusedWidth = rect.size.width - padding.left - padding.right - contentWidth;
            CGFloat alignmentSpacing = unusedWidth * 0.5;
            rectX = padding.left + alignmentSpacing + imageSize.width + self.interitemSpacing;
            rectY = (rect.size.height - padding.top - padding.bottom - titleSize.height) * 0.5 + padding.top;
            break;
        }
        case NSImageRight:
        {
            // 图片在右侧
            CGFloat contentWidth = titleSize.width + imageSize.width + self.interitemSpacing;
            CGFloat unusedWidth = rect.size.width - padding.left - padding.right - contentWidth;
            CGFloat alignmentSpacing = unusedWidth * 0.5;
            rectX = padding.left + alignmentSpacing;
            rectY = (rect.size.height - padding.top - padding.bottom - titleSize.height) * 0.5 + padding.top;
            break;
        }
        case NSImageAbove:
        {
            // 图片在上侧
            CGFloat contentHeight = titleSize.height + imageSize.height + self.interitemSpacing;
            CGFloat unusedHeight = rect.size.height - padding.top - padding.bottom - contentHeight;
            CGFloat alignmentSpacing = unusedHeight * 0.5;
            rectX = (rect.size.width - padding.left - padding.right - titleSize.width) * 0.5 + padding.left;
            rectY = padding.top + alignmentSpacing + imageSize.height + self.interitemSpacing;
            break;
        }
        case NSImageBelow:
        {
            // 图片在下侧
            CGFloat contentHeight = titleSize.height + imageSize.height + self.interitemSpacing;
            CGFloat unusedHeight = rect.size.height - padding.top - padding.bottom - contentHeight;
            CGFloat alignmentSpacing = unusedHeight * 0.5;
            rectX = (rect.size.width - padding.left - padding.right - titleSize.width) * 0.5 + padding.left;
            rectY = padding.top + alignmentSpacing;
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
    NSEdgeInsets padding = self.padding;
    CGFloat rectX       = 0;
    CGFloat rectY       = 0;
    switch (self.imagePosition)
    {
        case NSImageLeft:
        {
            // 图片在左侧
            CGFloat contentWidth = titleSize.width + imageSize.width + self.interitemSpacing;
            CGFloat unusedWidth = rect.size.width - padding.left - padding.right - contentWidth;
            CGFloat alignmentSpacing = unusedWidth * 0.5;
            rectX = padding.left + alignmentSpacing;
            rectY = (rect.size.height - padding.top - padding.bottom - imageSize.height) * 0.5 + padding.top;
            break;
        }
        case NSImageRight:
        {
            // 图片在右侧
            CGFloat contentWidth = titleSize.width + imageSize.width + self.interitemSpacing;
            CGFloat unusedWidth = rect.size.width - padding.left - padding.right - contentWidth;
            CGFloat alignmentSpacing = unusedWidth * 0.5;
            rectX = padding.left + alignmentSpacing + titleSize.width + self.interitemSpacing;
            rectY = (rect.size.height - padding.top - padding.bottom - imageSize.height) * 0.5 + padding.top;
            break;
        }
        case NSImageAbove:
        {
            // 图片在上侧
            CGFloat contentHeight = titleSize.height + imageSize.height + self.interitemSpacing;
            CGFloat unusedHeight = rect.size.height - padding.top - padding.bottom - contentHeight;
            CGFloat alignmentSpacing = unusedHeight * 0.5;
            rectX = (rect.size.width - padding.left - padding.right - imageSize.width) * 0.5 + padding.left;
            rectY = padding.top + alignmentSpacing;
            break;
        }
        case NSImageBelow:
        {
            // 图片在下侧
            CGFloat contentHeight = titleSize.height + imageSize.height + self.interitemSpacing;
            CGFloat unusedHeight = rect.size.height - padding.top - padding.bottom - contentHeight;
            CGFloat alignmentSpacing = unusedHeight * 0.5;
            rectX = (rect.size.width - padding.left - padding.right - imageSize.width) * 0.5 + padding.left;
            rectY = padding.top + alignmentSpacing + titleSize.height + self.interitemSpacing;
            break;
        }
        default:
        {
            return [super imageRectForBounds:rect];
        }
    }
    return CGRectMake(rectX, rectY, imageSize.width, imageSize.height);
}

- (void)setSpacingBetweenImageAndTitle:(CGFloat)spacingBetweenImageAndTitle {
    [self setInteritemSpacing:spacingBetweenImageAndTitle];
}

- (CGFloat)spacingBetweenImageAndTitle {
    return [self interitemSpacing];
}

@end

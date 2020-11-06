//
//  KKImageTitleButton.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKImageTitleButton.h"

@interface KKImageTitleButtonCell : NSButtonCell

@property (nonatomic, assign) NSEdgeInsets margin;
@property (nonatomic, assign) CGFloat contentSpacing;

@end

@implementation KKImageTitleButtonCell

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
            width   = titleSize.width + imageSize.width + self.margin.left + self.margin.right + self.contentSpacing;
            height  = MAX(imageSize.height, titleSize.height) + self.margin.top + self.margin.bottom;
            break;
        }
        case NSImageAbove:
        case NSImageBelow:
        {
            // 图片在上侧/下侧
            width   = MAX(titleSize.width, imageSize.width) + self.margin.left + self.margin.right;
            height  = imageSize.height + titleSize.height + self.margin.top + self.margin.bottom + self.contentSpacing;
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
            CGFloat contentWidth = titleSize.width + imageSize.width + self.contentSpacing;
            CGFloat unusedWidth = rect.size.width - margin.left - margin.right - contentWidth;
            CGFloat alignmentSpacing = unusedWidth * 0.5;
            rectX = margin.left + alignmentSpacing + imageSize.width + self.contentSpacing;
            rectY = (rect.size.height - margin.top - margin.bottom - titleSize.height) * 0.5 + margin.top;
            break;
        }
        case NSImageRight:
        {
            // 图片在右侧
            CGFloat contentWidth = titleSize.width + imageSize.width + self.contentSpacing;
            CGFloat unusedWidth = rect.size.width - margin.left - margin.right - contentWidth;
            CGFloat alignmentSpacing = unusedWidth * 0.5;
            rectX = margin.left + alignmentSpacing;
            rectY = (rect.size.height - margin.top - margin.bottom - titleSize.height) * 0.5 + margin.top;
            break;
        }
        case NSImageAbove:
        {
            // 图片在上侧
            CGFloat contentHeight = titleSize.height + imageSize.height + self.contentSpacing;
            CGFloat unusedHeight = rect.size.height - margin.top - margin.bottom - contentHeight;
            CGFloat alignmentSpacing = unusedHeight * 0.5;
            rectX = (rect.size.width - margin.left - margin.right - titleSize.width) * 0.5 + margin.left;
            rectY = margin.top + alignmentSpacing + imageSize.height + self.contentSpacing;
            break;
        }
        case NSImageBelow:
        {
            // 图片在下侧
            CGFloat contentHeight = titleSize.height + imageSize.height + self.contentSpacing;
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
            CGFloat contentWidth = titleSize.width + imageSize.width + self.contentSpacing;
            CGFloat unusedWidth = rect.size.width - margin.left - margin.right - contentWidth;
            CGFloat alignmentSpacing = unusedWidth * 0.5;
            rectX = margin.left + alignmentSpacing;
            rectY = (rect.size.height - margin.top - margin.bottom - imageSize.height) * 0.5 + margin.top;
            break;
        }
        case NSImageRight:
        {
            // 图片在右侧
            CGFloat contentWidth = titleSize.width + imageSize.width + self.contentSpacing;
            CGFloat unusedWidth = rect.size.width - margin.left - margin.right - contentWidth;
            CGFloat alignmentSpacing = unusedWidth * 0.5;
            rectX = margin.left + alignmentSpacing + titleSize.width + self.contentSpacing;
            rectY = (rect.size.height - margin.top - margin.bottom - imageSize.height) * 0.5 + margin.top;
            break;
        }
        case NSImageAbove:
        {
            // 图片在上侧
            CGFloat contentHeight = titleSize.height + imageSize.height + self.contentSpacing;
            CGFloat unusedHeight = rect.size.height - margin.top - margin.bottom - contentHeight;
            CGFloat alignmentSpacing = unusedHeight * 0.5;
            rectX = (rect.size.width - margin.left - margin.right - imageSize.width) * 0.5 + margin.left;
            rectY = margin.top + alignmentSpacing;
            break;
        }
        case NSImageBelow:
        {
            // 图片在下侧
            CGFloat contentHeight = titleSize.height + imageSize.height + self.contentSpacing;
            CGFloat unusedHeight = rect.size.height - margin.top - margin.bottom - contentHeight;
            CGFloat alignmentSpacing = unusedHeight * 0.5;
            rectX = (rect.size.width - margin.left - margin.right - imageSize.width) * 0.5 + margin.left;
            rectY = margin.top + alignmentSpacing + titleSize.height + self.contentSpacing;
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

@implementation KKImageTitleButton

+ (instancetype)buttonWithImage:(NSImage *)image title:(NSString *)title color:(NSColor *)color font:(NSFont *)font
{
    KKImageTitleButton *button = [self new];
    [button setButtonType:NSButtonTypeMomentaryPushIn];
    button.bordered             = NO;
    button.wantsLayer           = YES;
    button.imageScaling         = NSImageScaleNone;
    button.ignoresMultiClick    = YES;
    button.image                = image;
    button.imagePosition        = NSImageLeft;
    button.contentSpacing       = 7.0;
    if (color || font) {
        NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
        [attrs setValue:color forKey:NSForegroundColorAttributeName];
        [attrs setValue:font forKey:NSFontAttributeName];
        button.attributedTitle = [[NSAttributedString alloc] initWithString:title attributes:attrs];
    } else {
        button.title = title;
    }
    return button;
}

- (KKImageTitleButtonCell *)buttonCell
{
    return (KKImageTitleButtonCell *)self.cell;
}

- (void)setContentSpacing:(CGFloat)contentSpacing
{
    _contentSpacing = contentSpacing;
    [self buttonCell].contentSpacing = contentSpacing;
    [self invalidateIntrinsicContentSize];
}

- (void)setMargin:(NSEdgeInsets)margin
{
    _margin = margin;
    [self buttonCell].margin = margin;
    [self invalidateIntrinsicContentSize];
}

+ (instancetype)buttonWithImage:(NSImage *)image title:(NSString *)title
{
    return [self buttonWithImage:image title:title color:nil font:nil];
}

+ (Class)cellClass
{
    return [KKImageTitleButtonCell class];
}

@end

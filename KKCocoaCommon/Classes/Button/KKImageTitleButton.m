//
//  KKImageTitleButton.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKImageTitleButton.h"
#import "KKButtonCell.h"

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
    button.interitemSpacing     = 7.0;
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

- (KKButtonCell *)buttonCell
{
    return (KKButtonCell *)self.cell;
}

- (void)setInteritemSpacing:(CGFloat)interitemSpacing
{
    _interitemSpacing = interitemSpacing;
    [self buttonCell].interitemSpacing = interitemSpacing;
    [self invalidateIntrinsicContentSize];
}

- (void)setPadding:(NSEdgeInsets)padding
{
    _padding = padding;
    [self buttonCell].padding = padding;
    [self invalidateIntrinsicContentSize];
}

+ (instancetype)buttonWithImage:(NSImage *)image title:(NSString *)title
{
    return [self buttonWithImage:image title:title color:nil font:nil];
}

+ (Class)cellClass
{
    return [KKButtonCell class];
}

@end

//
//  NSButton+KK.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "NSButton+KK.h"

@implementation NSButton (KK)

+ (instancetype)buttonWithType:(NSButtonType)type
{
    return [self buttonWithType:type bezelStyle:NSBezelStyleRegularSquare bordered:NO];
}

+ (instancetype)buttonWithType:(NSButtonType)type bezelStyle:(NSBezelStyle)bezelStyle bordered:(BOOL)bordered
{
    NSButton *button            = [self new];
    [button setButtonType:type];
    button.title                = @"";
    button.bezelStyle           = bezelStyle;
    button.bordered             = bordered;
    button.wantsLayer           = YES;
    button.imageScaling         = NSImageScaleNone;
    button.ignoresMultiClick    = YES;
    return button;
}

- (void)setTitle:(NSString *)title color:(NSColor *)color font:(NSFont *)font
{
    [self setTitle:title color:color font:font alignment:NSTextAlignmentCenter lineBreakMode:NSLineBreakByTruncatingTail];
}

- (void)setTitle:(NSString *)title color:(NSColor *)color font:(NSFont *)font alignment:(NSTextAlignment)alignment lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    if (title == nil || [title isEqualToString:@""]) {
        self.title = @"";
        return;
    }
    NSMutableDictionary *attrs      = [NSMutableDictionary dictionary];
    [attrs setValue:color forKey:NSForegroundColorAttributeName];
    [attrs setValue:font forKey:NSFontAttributeName];
    NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
    style.alignment                 = alignment;
    style.lineBreakMode             = lineBreakMode;
    [attrs setValue:style forKey:NSParagraphStyleAttributeName];
    self.attributedTitle            = [[NSAttributedString alloc] initWithString:title attributes:attrs];
}

- (void)updateAttributedTitle:(NSString *)title
{
    if (title == nil || [title isEqualToString:@""]) {
        self.title = @"";
        return;
    }
    NSDictionary *attrs     = [self.attributedTitle attributesAtIndex:0 effectiveRange:nil];
    self.attributedTitle    = [[NSAttributedString alloc] initWithString:title attributes:attrs];
}

- (void)setBackgroundColor:(NSColor *)backgroundColor cornerRadius:(CGFloat)cornerRadius
{
    self.wantsLayer             = YES;
    self.layer.backgroundColor  = backgroundColor.CGColor;
    self.layer.cornerRadius     = cornerRadius;
    self.layer.masksToBounds    = YES;
}

- (void)setBackgroundColor:(NSColor *)backgroundColor cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(NSColor *)borderColor
{
    self.wantsLayer             = YES;
    self.layer.backgroundColor  = backgroundColor.CGColor;
    self.layer.cornerRadius     = cornerRadius;
    self.layer.borderWidth      = borderWidth;
    self.layer.borderColor      = borderColor.CGColor;
    self.layer.masksToBounds    = YES;
}

- (void)setBackgroundImage:(NSImage *)backgroundImage scaling:(NSImageScaling)scaling
{
    self.imageScaling   = scaling;
    self.imagePosition  = NSImageOverlaps;
    self.image          = backgroundImage;
}

- (void)setOnState:(BOOL)onState
{
    self.state = onState ? NSControlStateValueOn : NSControlStateValueOff;
}

- (BOOL)isOnState
{
    return self.state == NSControlStateValueOn;
}

@end

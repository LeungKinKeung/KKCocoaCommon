//
//  NSTextField+KK.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "NSTextField+KK.h"

@implementation NSTextField (KK)

- (void)setText:(NSString *)text
{
    if (text == nil || ![text isKindOfClass:[NSString class]]) {
        self.stringValue = @"";
    } else {
        self.stringValue = [text copy];
    }
}

- (NSString *)text
{
    return self.stringValue;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    self.alignment = textAlignment;
}

- (NSTextAlignment)textAlignment
{
    return self.alignment;
}

+ (instancetype)label
{
    NSTextField *label      = [self new];
    label.editable          = NO;
    label.selectable        = NO;
    label.bordered          = NO;
    label.drawsBackground   = NO;
    label.backgroundColor   = [NSColor clearColor];
    label.focusRingType     = NSFocusRingTypeNone;
    label.bezelStyle        = NSTextFieldSquareBezel;
    label.lineBreakMode     = NSLineBreakByTruncatingTail;
    label.cell.scrollable   = NO;
    label.wantsLayer        = YES;
    label.layer.backgroundColor = [NSColor clearColor].CGColor;
    return label;
}

@end

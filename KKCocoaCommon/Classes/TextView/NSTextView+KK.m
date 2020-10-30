//
//  NSTextView+KK.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "NSTextView+KK.h"

@implementation NSTextView (KK)

- (void)setText:(NSString *)text
{
    if (text == nil || ![text isKindOfClass:[NSString class]]) {
        self.string = @"";
    } else {
        self.string = [text copy];
    }
}

- (NSString *)text
{
    return self.string;
}

+ (instancetype)textView
{
    NSTextContainer *textContainer  = nil;
    if (@available(macOS 10.11, *)) {
        textContainer  = [[NSTextContainer alloc] initWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    } else {
        textContainer  = [[NSTextContainer alloc] initWithContainerSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    }
    NSTextStorage *textStorage      = [[NSTextStorage alloc] initWithString:@""];
    NSLayoutManager *layoutManager  = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    [layoutManager addTextContainer:textContainer];
    NSTextView *textView    = [[NSTextView alloc] initWithFrame:CGRectZero textContainer:textContainer];
    [textContainer setWidthTracksTextView:YES];
    [textContainer setHeightTracksTextView:NO];
    [textView setVerticallyResizable:YES];
    [textView setHorizontallyResizable:NO];
    [textView setAutoresizingMask:NSViewWidthSizable];
    return textView;
}

@end

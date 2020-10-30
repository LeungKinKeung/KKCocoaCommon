//
//  NSColor+KK.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "NSColor+KK.h"

@implementation NSColor (KK)

NSColor *KKColor(NSUInteger hexValue, CGFloat alpha)
{
    CGFloat red     = (CGFloat)((hexValue & 0xFF0000) >> 16);
    CGFloat green   = (CGFloat)((hexValue & 0xFF00) >> 8);
    CGFloat blue    = (CGFloat)(hexValue & 0xFF);
    
    return [NSColor colorWithDeviceRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

NSColor *KKRandomColor(void)
{
    return [NSColor colorWithDeviceRed:(arc4random() % 256)/255.0
                                 green:(arc4random() % 256)/255.0
                                  blue:(arc4random() % 256)/255.0
                                 alpha:1];
}

BOOL KKColorEqualToColor(NSColor *color1, NSColor *color2)
{
    return CGColorEqualToColor(color1.CGColor, color2.CGColor);
}

@end

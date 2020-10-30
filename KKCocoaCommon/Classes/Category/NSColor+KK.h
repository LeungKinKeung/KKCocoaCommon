//
//  NSColor+KK.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSColor (KK)

OBJC_EXTERN NSColor *KKColor(NSUInteger hexValue, CGFloat alpha);
OBJC_EXTERN NSColor *KKRandomColor(void);
OBJC_EXTERN BOOL KKColorEqualToColor(NSColor *color1, NSColor *color2);

@end

NS_ASSUME_NONNULL_END

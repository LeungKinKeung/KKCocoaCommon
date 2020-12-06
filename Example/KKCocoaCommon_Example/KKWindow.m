//
//  KKWindow.m
//  KKCocoaCommon_Example
//
//  Created by LeungKinKeung on 2020/10/30.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKWindow.h"

@implementation KKWindow


- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag
{
    self = [super initWithContentRect:contentRect styleMask:style backing:backingStoreType defer:flag];
    if (self) {
        
        //设置为点击背景可以移动窗口
        self.movableByWindowBackground = YES;
    }
    return self;
}

- (void)mouseDown:(NSEvent *)event
{
    [self makeFirstResponder:nil];
    [super mouseDown:event];
}

//- (NSUserInterfaceLayoutDirection)windowTitlebarLayoutDirection
//{
//    return NSUserInterfaceLayoutDirectionRightToLeft;
//}

@end

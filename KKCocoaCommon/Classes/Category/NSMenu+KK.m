//
//  NSMenu+KK.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "NSMenu+KK.h"

@implementation NSMenu (KK)

- (NSMenuItem *)addItemWithTitle:(NSString *)string target:(id)target action:(SEL)selector
{
    NSMenuItem *item    = [[NSMenuItem alloc] initWithTitle:string action:selector keyEquivalent:@""];
    item.target         = target;
    [self addItem:item];
    return item;
}

- (NSMenuItem *)addItemWithTitle:(NSString *)string target:(id)target action:(SEL)selector keyEquivalent:(NSString *)charCode
{
    NSMenuItem *item    = [[NSMenuItem alloc] initWithTitle:string action:selector keyEquivalent:charCode];
    item.target         = target;
    [self addItem:item];
    return item;
}

@end

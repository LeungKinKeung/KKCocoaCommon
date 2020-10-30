//
//  NSMenu+KK.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMenu (KK)

- (NSMenuItem *)addItemWithTitle:(NSString *)string target:(id)target action:(SEL)selector;

/// 添加item，keyEquivalent：快捷键
- (NSMenuItem *)addItemWithTitle:(NSString *)string target:(id)target action:(SEL)selector keyEquivalent:(NSString *)charCode;

@end

NS_ASSUME_NONNULL_END

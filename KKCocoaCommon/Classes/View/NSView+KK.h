//
//  NSView+KK.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (KK)

/// 设置背景色
@property (nonatomic, readwrite) NSColor *layerBackgroundColor;

/// 更新或增加跟踪区域
/// @param options 选项
- (void)updateTrackingAreasWithOptions:(NSTrackingAreaOptions)options;

/// 弹出菜单
/// @param menu 菜单
- (void)popUpMenu:(NSMenu *)menu;

@end

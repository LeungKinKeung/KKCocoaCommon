//
//  NSView+KK.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, KKRectAlignment) {
    KKRectAlignmentCenter,
    KKRectAlignmentTop,
    KKRectAlignmentTopLeft,
    KKRectAlignmentLeft,
    KKRectAlignmentBottomLeft,
    KKRectAlignmentBottom,
    KKRectAlignmentBottomRigth,
    KKRectAlignmentRigth,
    KKRectAlignmentTopRigth,
};

@interface NSView (KK)

/// 设置背景色
@property (nonatomic, readwrite) NSColor *layerBackgroundColor;

/// 更新或增加跟踪区域
/// @param options 选项
- (void)updateTrackingAreasWithOptions:(NSTrackingAreaOptions)options;

/// 弹出菜单
/// @param menu 菜单
- (void)popUpMenu:(NSMenu *)menu;

/// 自身在视图的哪个位置
/// @param view 相对的视图（父视图）
- (KKRectAlignment)alignmentAtView:(NSView *)view;

/// 自身中心在视图的哪个位置
/// @param view 相对的视图（父视图）
- (KKRectAlignment)centerAlignmentAtView:(NSView *)view;

@end

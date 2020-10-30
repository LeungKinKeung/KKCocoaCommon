//
//  KKImageTitleButton.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface KKImageTitleButton : NSButton

/// 创建图片标题按钮，图片默认在左侧
/// @param image 图片
/// @param title 标题
/// @param color 颜色
/// @param font 字体
+ (instancetype)buttonWithImage:(NSImage *)image title:(NSString *)title color:(NSColor *)color font:(NSFont *)font;

/// 创建图片标题按钮
+ (instancetype)buttonWithImage:(NSImage *)image title:(NSString *)title;

/// 上下左右的间隔（使用Masonry布局后再设置无法生效）
@property (nonatomic, assign) NSEdgeInsets edgeInset;

/// 图片和标题的间隔，默认：7（使用Masonry布局后再设置无法生效）
@property (nonatomic, assign) CGFloat contentSpacing;

@end

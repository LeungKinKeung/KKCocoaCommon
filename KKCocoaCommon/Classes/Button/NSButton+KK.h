//
//  NSButton+KK.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSButton (KK)

/// 创建按钮（bezelStyle=NSBezelStyleRegularSquare，bordered=NO）
/// @param type 类型，一般使用NSButtonTypeMomentaryPushIn
+ (instancetype)buttonWithType:(NSButtonType)type;

/// 创建按钮
/// @param type 类型，一般使用NSButtonTypeMomentaryPushIn
/// @param bezelStyle 样式
/// @param bordered 边框
+ (instancetype)buttonWithType:(NSButtonType)type bezelStyle:(NSBezelStyle)bezelStyle bordered:(BOOL)bordered;

/// 创建无背景的图像按钮
+ (instancetype)imageButtonWithImage:(NSImage *)image target:(id)target action:(SEL)action;

/// 设置标题（居中对齐）
/// @param title 标题
/// @param color 颜色
/// @param font 字体
- (void)setTitle:(NSString *)title color:(NSColor *)color font:(NSFont *)font;

/// 设置标题
/// @param title 标题
/// @param color 颜色
/// @param font 字体
/// @param alignment 对齐
/// @param lineBreakMode 换行方式
- (void)setTitle:(NSString *)title color:(NSColor *)color font:(NSFont *)font alignment:(NSTextAlignment)alignment lineBreakMode:(NSLineBreakMode)lineBreakMode;

/// 更新富文本标题（取第一个字符属性）
- (void)updateAttributedTitle:(NSString *)title;

/// 设置背景色
/// @param backgroundColor 背景色
/// @param cornerRadius 圆角（masksToBounds=YES）
- (void)setBackgroundColor:(NSColor *)backgroundColor cornerRadius:(CGFloat)cornerRadius;

/// 设置Layer
/// @param backgroundColor 背景色
/// @param cornerRadius 圆角（masksToBounds=YES）
/// @param borderWidth 边框宽度
/// @param borderColor 边框颜色
- (void)setBackgroundColor:(NSColor *)backgroundColor cornerRadius:(CGFloat)cornerRadius borderWidth:(CGFloat)borderWidth borderColor:(NSColor *)borderColor;

/// 设置背景图
/// @param backgroundImage 背景图
/// @param scaling 缩放
- (void)setBackgroundImage:(NSImage *)backgroundImage scaling:(NSImageScaling)scaling;

/// 是否按下状态，NSButtonType为NSButtonTypeToggle时可用（alternateImage也是）
@property (nonatomic, readwrite, getter=isOnState) BOOL onState;

@end

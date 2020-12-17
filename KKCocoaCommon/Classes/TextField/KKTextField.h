//
//  KKTextField.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class KKTextField;

typedef NS_ENUM(NSInteger, KKTextFieldState) {
    KKTextFieldStateNormal,        // 默认
    KKTextFieldStateMouseInside,   // 鼠标在输入框里
    KKTextFieldStateEditing,       // 编辑中
};

@protocol KKTextFieldDelegate <NSObject>

@optional

/// 已获得输入焦点
- (void)textFieldDidBeginEditing:(KKTextField *)textField;

/// 已失去输入焦点
- (void)textFieldDidEndEditing:(KKTextField *)textField;

/// 文本已更改
- (void)textFieldTextDidChange:(KKTextField *)textField;

/// 按下了Enter键，覆盖KKTextField实例的currentTextField.delegate之后不生效
- (BOOL)textFieldShouldReturn:(KKTextField *)textField;

@end

@interface KKTextField : NSView

/// 文本
@property (nonatomic, readwrite) NSString *text;
/// 颜色，默认：black
@property (nonatomic, strong) NSColor *textColor;
/// 读写默认状态下的背景颜色，默认：white
@property (nonatomic, readwrite) NSColor *backgroundColor;
/// 字体，默认：system font 12 pt
@property (nonatomic, strong) NSFont *font;
/// 文本对齐方式：NSTextAlignmentLeft
@property (nonatomic, assign) NSTextAlignment textAlignment;
/// 插入光标颜色
@property (nonatomic, strong) NSColor *insertionPointColor;
/// 占位文字颜色
@property (nonatomic, strong) NSColor *placeholderColor;
/// 占位文字
@property (nonatomic, copy) NSString *placeholder;
/// 占位文字（富文本）
@property (nonatomic, copy) NSAttributedString *attributedPlaceholder;
/// 圆角半径
@property (nonatomic, assign) CGFloat cornerRadius;
/// 边框粗细
@property (nonatomic, readwrite) CGFloat borderWidth;
/// 边框颜色
@property (nonatomic, readwrite) NSColor *borderColor;
/// 左视图
@property (nonatomic, strong) NSView *leftView;
/// 右视图
@property (nonatomic, strong) NSView *rightView;
/// 内边距（仅左右有效）
@property (nonatomic, assign) NSEdgeInsets padding;
/// 代理
@property (nonatomic, weak) id<KKTextFieldDelegate> delegate;
/// 允许编辑，默认：YES
@property (nonatomic, getter=isEditable) BOOL editable;
/// 安全文本输入，默认：NO
@property (nonatomic, getter=isSecureTextEntry) BOOL secureTextEntry;
/// 正在编辑中
@property (nonatomic, readonly) BOOL isEditing;
/// 当前的文本输入框(isSecureTextEntry ? secureTextField : textField)
@property (nonatomic, readonly) NSTextField *currentTextField;
/// 普通文本输入框
@property (nonatomic, readonly) NSTextField *textField;
/// 安全文本输入框
@property (nonatomic, readonly) NSSecureTextField *secureTextField;
/// 当前输入框状态
@property (nonatomic, readonly) KKTextFieldState currentState;
/// 设置边框粗细
- (void)setBorderWidth:(CGFloat)borderWidth forState:(KKTextFieldState)state;
/// 设置边框颜色
- (void)setBorderColor:(NSColor *)borderColor forState:(KKTextFieldState)state;
/// 设置背景色
- (void)setBackgroundColor:(NSColor *)backgroundColor forState:(KKTextFieldState)state;

@end

@interface NSView (KKTextField)

/// 结束此视图窗口的所有编辑
- (void)endEditing;

@end

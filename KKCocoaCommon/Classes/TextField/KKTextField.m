//
//  KKTextField.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKTextField.h"

CGFloat KKTFGetFloat(NSMutableDictionary *map, KKTextFieldState state)
{
    id value = [map objectForKey:@(state)];
    if (value == [NSNull null]) {
        return 0.0;
    }
    NSNumber *number = value;
    if (number) {
        return number.doubleValue;
    }
    value = [map objectForKey:@(KKTextFieldStateNormal)];
    if (value == [NSNull null]) {
        return 0;
    }
    number = value;
    return number.doubleValue;
}

void KKTFSetFloat(NSMutableDictionary *map, CGFloat value, KKTextFieldState state)
{
    [map setObject:@(value) forKey:@(state)];
}

id KKTFGetValue(NSMutableDictionary *map, KKTextFieldState state)
{
    id value = [map objectForKey:@(state)];
    
    if (value == [NSNull null]) {
        return nil;
    }
    if (value) {
        return value;
    }
    value = [map objectForKey:@(KKTextFieldStateNormal)];
    
    if (value == [NSNull null]) {
        return nil;
    }
    return value;
}

void KKTFSetValue(NSMutableDictionary *map, id value, KKTextFieldState state)
{
    if (value) {
        [map setObject:value forKey:@(state)];
    } else {
        [map setObject:[NSNull null] forKey:@(state)];
    }
}

@protocol KKPrivateTextFieldDelegate <NSObject>
@optional
- (void)textFieldDidBeginEditing:(NSTextField *)textField;
- (void)textFieldDidEndEditing:(NSTextField *)textField;
- (void)textFieldTextDidChange:(NSTextField *)textField;
@end

@interface NSTextField (KKPrivateTextField)
@property (nonatomic, readonly) NSTextFieldCell *textFieldCell;
@end
@implementation NSTextField (KKPrivateTextField)
- (NSTextFieldCell *)textFieldCell
{
    if ([self.cell isKindOfClass:[NSTextFieldCell class]]) {
        return (NSTextFieldCell *)self.cell;
    }
    return nil;
}
@end

@interface KKPrivateTextField : NSTextField
@property (nonatomic, weak) id<KKPrivateTextFieldDelegate> KK_delegate;
@property (nonatomic, strong) NSColor *originalInsertionPointColor;
@property (nonatomic, strong) NSColor *alternateInsertionPointColor;
@end
@implementation KKPrivateTextField
- (void)selectText:(id)sender
{
    [super selectText:sender];
    if (self.window.isKeyWindow == NO) {
        return;
    }
    if (self.isEditable &&
        [self.KK_delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [self.KK_delegate textFieldDidBeginEditing:self];
    }
    NSTextView *currentEditor = (NSTextView *)self.currentEditor;
    if (currentEditor &&
        [currentEditor isKindOfClass:[NSTextView class]] &&
        self.alternateInsertionPointColor) {
        self.originalInsertionPointColor = currentEditor.insertionPointColor;
        currentEditor.insertionPointColor = self.alternateInsertionPointColor;
    }
}
- (void)textDidEndEditing:(NSNotification *)notification
{
    NSTextView *currentEditor = (NSTextView *)self.currentEditor;
    if (currentEditor &&
        [currentEditor isKindOfClass:[NSTextView class]] &&
        self.originalInsertionPointColor) {
        currentEditor.insertionPointColor = self.originalInsertionPointColor;
    }
    [super textDidEndEditing:notification];
    if ([self.KK_delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [self.KK_delegate textFieldDidEndEditing:self];
    }
}
- (void)textDidChange:(NSNotification *)notification
{
    [super textDidChange:notification];
    if ([self.KK_delegate respondsToSelector:@selector(textFieldTextDidChange:)]) {
        [self.KK_delegate textFieldTextDidChange:self];
    }
}
@end

@interface KKPrivateSecureTextField : NSSecureTextField
@property (nonatomic, weak) id<KKPrivateTextFieldDelegate> KK_delegate;
@property (nonatomic, strong) NSColor *originalInsertionPointColor;
@property (nonatomic, strong) NSColor *alternateInsertionPointColor;
@end

@implementation KKPrivateSecureTextField
- (void)selectText:(id)sender
{
    [super selectText:sender];
    if (self.window.isKeyWindow == NO) {
        return;
    }
    if (self.isEditable &&
        [self.KK_delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [self.KK_delegate textFieldDidBeginEditing:self];
    }
    NSTextView *currentEditor = (NSTextView *)self.currentEditor;
    if (currentEditor &&
        [currentEditor isKindOfClass:[NSTextView class]] &&
        self.alternateInsertionPointColor) {
        self.originalInsertionPointColor = currentEditor.insertionPointColor;
        currentEditor.insertionPointColor = self.alternateInsertionPointColor;
    }
}
- (void)textDidEndEditing:(NSNotification *)notification
{
    NSTextView *currentEditor = (NSTextView *)self.currentEditor;
    if (currentEditor &&
        [currentEditor isKindOfClass:[NSTextView class]] &&
        self.originalInsertionPointColor) {
        currentEditor.insertionPointColor = self.originalInsertionPointColor;
    }
    [super textDidEndEditing:notification];
    if ([self.KK_delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [self.KK_delegate textFieldDidEndEditing:self];
    }
}
- (void)textDidChange:(NSNotification *)notification
{
    [super textDidChange:notification];
    if ([self.KK_delegate respondsToSelector:@selector(textFieldTextDidChange:)]) {
        [self.KK_delegate textFieldTextDidChange:self];
    }
}
@end


@interface KKTextField ()<KKPrivateTextFieldDelegate, NSTextFieldDelegate>
{
    @protected
    KKPrivateTextField *_textField;
    KKPrivateSecureTextField *_secureTextField;
    KKTextFieldState _state;
}

@property (nonatomic, strong) NSTrackingArea *trackingArea;
@property (nonatomic, strong) NSMutableDictionary <NSString *,NSNumber *>*borderWidthMap;
@property (nonatomic, strong) NSMutableDictionary <NSString *,NSColor *>*borderColorMap;
@property (nonatomic, strong) NSMutableDictionary <NSString *,NSColor *>*backgroundColorMap;
@property (nonatomic, readwrite) KKTextFieldState state;
@property (nonatomic, assign) BOOL isIBeamCursor;
@property (nonatomic, assign) BOOL isMouseInside;
@property (nonatomic, weak) NSView *KKNextKeyView;

@end

@implementation KKTextField

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    _state                  = -1;
    _editable               = YES;
    self.wantsLayer         = YES;
    [self textField];
    [self secureTextField];
    self.secureTextEntry    = NO;
    [self setNeedsLayout:YES];
}

#pragma mark - 属性设置
- (void)setAppearance:(NSAppearance *)appearance
{
    [super setAppearance:appearance];
    [[self textField] setAppearance:appearance];
    [[self secureTextField] setAppearance:appearance];
}

- (void)setText:(NSString *)text
{
    self.currentTextField.stringValue = text ? text : @"";
}

- (NSString *)text
{
    return self.currentTextField.stringValue;
}

- (void)setTextColor:(NSColor *)textColor
{
    _textColor                      = textColor;
    self.textField.textColor        =
    self.secureTextField.textColor  = textColor;
}

- (void)setBackgroundColor:(NSColor *)backgroundColor
{
    [self setBackgroundColor:backgroundColor forState:KKTextFieldStateNormal];
}

- (NSColor *)backgroundColor
{
    return KKTFGetValue(self.backgroundColorMap, KKTextFieldStateNormal);
}

- (void)setFont:(NSFont *)font
{
    _font = font;
    self.textField.font =
    self.secureTextField.font = font;
    [self setNeedsLayout:YES];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    _textAlignment                  = textAlignment;
    self.textField.alignment        =
    self.secureTextField.alignment  = textAlignment;
}

- (void)setInsertionPointColor:(NSColor *)insertionPointColor
{
    _insertionPointColor = insertionPointColor;
    _textField.alternateInsertionPointColor =
    _secureTextField.alternateInsertionPointColor = insertionPointColor;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder.copy;
    [self updatePlaceholder];
}

- (void)setPlaceholderColor:(NSColor *)placeholderColor
{
    _placeholderColor = placeholderColor.copy;
    [self updatePlaceholder];
}

- (void)updatePlaceholder
{
    if (self.placeholder == nil || self.placeholderColor == nil) {
        if (@available(macOS 10.10, *)) {
            self.textField.placeholderString =
            self.secureTextField.placeholderString = self.placeholder;
        } else {
            self.textField.textFieldCell.placeholderString = self.placeholder;
            self.secureTextField.textFieldCell.placeholderString = self.placeholder;
        }
    } else {
        NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
        [attrs setValue:self.placeholderColor forKey:NSForegroundColorAttributeName];
        [attrs setValue:self.font forKey:NSFontAttributeName];
        self.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:attrs];
    }
}

- (void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder
{
    _attributedPlaceholder = attributedPlaceholder;
    if (@available(macOS 10.10, *)) {
        self.textField.placeholderAttributedString =
        self.secureTextField.placeholderAttributedString = attributedPlaceholder;
    } else {
        self.textField.textFieldCell.placeholderAttributedString = attributedPlaceholder;
        self.secureTextField.textFieldCell.placeholderAttributedString = attributedPlaceholder;
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius
{
    _cornerRadius = cornerRadius;
    self.layer.cornerRadius = cornerRadius;
    self.layer.masksToBounds = cornerRadius > 0;
    [self setNeedsLayout:YES];
}

- (void)setBorderWidth:(CGFloat)borderWidth
{
    [self setBorderWidth:borderWidth forState:KKTextFieldStateNormal];
}

- (CGFloat)borderWidth
{
    return KKTFGetFloat(self.borderWidthMap, KKTextFieldStateNormal);
}

- (void)setBorderColor:(NSColor *)borderColor
{
    [self setBorderColor:borderColor forState:KKTextFieldStateNormal];
}

- (NSColor *)borderColor
{
    return KKTFGetValue(self.borderColorMap, KKTextFieldStateNormal);
}

- (void)setLeftView:(NSView *)leftView
{
    if (_leftView) {
        [_leftView removeFromSuperview];
    }
    _leftView = leftView;
    if (leftView) {
        [self addSubview:leftView];
    }
    [self setNeedsLayout:YES];
}

- (void)setRightView:(NSView *)rightView
{
    if (_rightView) {
        [_rightView removeFromSuperview];
    }
    _rightView = rightView;
    if (rightView) {
        [self addSubview:rightView];
    }
    [self setNeedsLayout:YES];
}

- (void)setPadding:(NSEdgeInsets)padding
{
    _padding = padding;
    [self setNeedsLayout:YES];
}

- (void)viewDidMoveToSuperview
{
    [super viewDidMoveToSuperview];
    [self setNeedsLayout:YES];
}

-  (void)setBackgroundColor:(NSColor *)backgroundColor forState:(KKTextFieldState)state
{
    KKTFSetValue(self.backgroundColorMap, backgroundColor, state);
    [self updateBackgroundColor];
}

- (void)setBorderWidth:(CGFloat)borderWidth forState:(KKTextFieldState)state
{
    KKTFSetFloat(self.borderWidthMap, borderWidth, state);
    [self updateBorderWidth];
}

- (void)setBorderColor:(NSColor *)borderColor forState:(KKTextFieldState)state
{
    KKTFSetValue(self.borderColorMap, borderColor, state);
    [self updateBorderColor];
}

- (void)updateBorderWidth
{
    self.layer.borderWidth = KKTFGetFloat(self.borderWidthMap, self.currentState);
}

- (void)updateBorderColor
{
    NSColor *color = KKTFGetValue(self.borderColorMap, self.currentState);
    self.layer.borderColor = color.CGColor;
}

- (void)updateBackgroundColor
{
    NSColor *color = KKTFGetValue(self.backgroundColorMap, self.currentState);
    self.layer.backgroundColor = color.CGColor;
}

- (void)layout
{
    [super layout];
    
    CGFloat leftSpacing     = 0;
    CGFloat rightSpacing    = 0;
    if (self.leftView) {
        
        CGSize size         = self.leftView.frame.size;
        if (size.width == 0 &&
            size.height == 0 &&
            [self.leftView isKindOfClass:[NSControl class]]) {
            size            = [self.leftView intrinsicContentSize];
        }
        self.leftView.frame =
        CGRectMake(self.padding.left,
                   (self.frame.size.height - size.height) * 0.5,
                   size.width,
                   size.height);
        leftSpacing     = CGRectGetMaxX(self.leftView.frame);
    } else {
        leftSpacing     = self.padding.left;
    }
    if (self.rightView) {
        
        CGSize size         = self.rightView.frame.size;
        if (size.width == 0 &&
            size.height == 0 &&
            [self.rightView isKindOfClass:[NSControl class]]) {
            size            = [self.rightView intrinsicContentSize];
        }
        self.rightView.frame =
        CGRectMake(self.frame.size.width - self.padding.right - size.width,
                   (self.frame.size.height - size.height) * 0.5,
                   size.width,
                   size.height);
        rightSpacing    = self.rightView.frame.size.width + self.padding.right;
    } else {
        rightSpacing    = self.padding.right;
    }
    CGFloat textFieldHeight     = self.textField.intrinsicContentSize.height;
    self.textField.frame        =
    self.secureTextField.frame  =
    CGRectMake(leftSpacing,
               (self.frame.size.height - textFieldHeight) * 0.5,
               self.frame.size.width - leftSpacing - rightSpacing,
               textFieldHeight);
}

- (void)setSecureTextEntry:(BOOL)secureTextEntry
{
    BOOL isEditing = self.isEditing;
    NSRange selectedRange =
    isEditing ?
    self.currentTextField.currentEditor.selectedRange :
    NSMakeRange(0, 0);
    _secureTextEntry = secureTextEntry;
    self.textField.hidden = secureTextEntry;
    self.textField.enabled = !secureTextEntry;
    self.secureTextField.hidden = !secureTextEntry;
    self.secureTextField.enabled = secureTextEntry;
    if (secureTextEntry) {
        self.secureTextField.stringValue = self.textField.stringValue;
        [self.textField endEditing:[self.textField currentEditor]];
        self.textField.stringValue = @"";
        if (isEditing) {
            [self.window makeFirstResponder:self.secureTextField];
            self.secureTextField.currentEditor.selectedRange = selectedRange;
        }
    } else {
        self.textField.stringValue = self.secureTextField.stringValue;
        [self.secureTextField endEditing:[self.secureTextField currentEditor]];
        self.secureTextField.stringValue = @"";
        if (isEditing) {
            [self.window makeFirstResponder:self.textField];
            self.textField.currentEditor.selectedRange = selectedRange;
        }
    }
}

- (void)setEditable:(BOOL)editable
{
    _editable = editable;
    self.textField.editable =
    self.secureTextField.editable = editable;
}

- (BOOL)isEditing
{
    //return [self.currentTextField.cell fieldEditorForView:self.currentTextField] != nil;
    return self.window.firstResponder == self.currentTextField.currentEditor;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)canBecomeKeyView
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    [self.window makeFirstResponder:self.currentTextField];
    return [super becomeFirstResponder];
}

- (void)setNextKeyView:(NSView *)nextKeyView
{
    [super setNextKeyView:nextKeyView];
    self.textField.nextKeyView = nextKeyView;
    self.secureTextField.nextKeyView = nextKeyView;
}

#pragma mark - 输入框
- (NSTextField *)textField
{
    if (_textField == nil) {
        _textField                  = [KKPrivateTextField new];
        _textColor                  = _textField.textColor;
        _font                       = _textField.font;
        _textAlignment              = _textField.alignment;
        _textField.KK_delegate      = self;
        _textField.wantsLayer       = YES;
        _textField.drawsBackground  = NO;
        _textField.bordered         = NO;
        _textField.focusRingType    = NSFocusRingTypeNone;
        _textField.cell.scrollable  = YES;
        _textField.layer.backgroundColor    = NSColor.clearColor.CGColor;
        _textField.delegate         = self;
        [self addSubview:_textField];
    }
    return _textField;
}

- (NSSecureTextField *)secureTextField
{
    if (_secureTextField == nil) {
        _secureTextField = [KKPrivateSecureTextField new];
        _secureTextField.KK_delegate       = self;
        _secureTextField.wantsLayer         = YES;
        _secureTextField.drawsBackground    = NO;
        _secureTextField.bordered           = NO;
        _secureTextField.focusRingType      = NSFocusRingTypeNone;
        _secureTextField.cell.scrollable    = YES;
        _secureTextField.layer.backgroundColor  = NSColor.clearColor.CGColor;
        _secureTextField.delegate           = self;
        [self addSubview:_secureTextField];
    }
    return _secureTextField;
}

- (NSTextField *)currentTextField
{
    return self.isSecureTextEntry ? self.secureTextField : self.textField;
}

#pragma mark - 代理
- (void)textFieldDidBeginEditing:(NSTextField *)textField
{
    self.state = KKTextFieldStateEditing;
    if ([self.delegate respondsToSelector:@selector(textFieldDidBeginEditing:)]) {
        [self.delegate textFieldDidBeginEditing:self];
    }
}

- (void)textFieldDidEndEditing:(NSTextField *)textField
{
    self.state = self.isMouseInside ? KKTextFieldStateHover : KKTextFieldStateNormal;
    if ([self.delegate respondsToSelector:@selector(textFieldDidEndEditing:)]) {
        [self.delegate textFieldDidEndEditing:self];
    }
    // -endEditing:会导致alignment属性变成默认的NSTextAlignmentLeft，不知道为何
    NSTextAlignment alignment   = textField.alignment;
    [textField endEditing:textField.currentEditor];
    textField.alignment         = alignment;
}

- (void)textFieldTextDidChange:(NSTextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(textFieldTextDidChange:)]) {
        [self.delegate textFieldTextDidChange:self];
    }
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    if (commandSelector == @selector(insertNewline:) &&
        [self.delegate respondsToSelector:@selector(textFieldShouldReturn:)]) {
        return [self.delegate textFieldShouldReturn:self];
    }
    return NO;
}

#pragma mark - 鼠标和按键
- (void)updateTrackingAreas
{
    [super updateTrackingAreas];
    
    if (self.trackingArea)
    {
        [self removeTrackingArea:self.trackingArea];
    }
    NSTrackingAreaOptions options =
    NSTrackingMouseEnteredAndExited |
    NSTrackingMouseMoved |
    NSTrackingActiveAlways;
    
    self.trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:options owner:self userInfo:nil];
    
    [self addTrackingArea:self.trackingArea];
}

- (void)mouseDown:(NSEvent *)event
{
    if (self.window.isKeyWindow == NO) {
        [super mouseDown:event];
        return;
    }
    if ([self mouseIsInsideTheTextFieldArea:event] && self.isEditing == NO) {
        [self.currentTextField becomeFirstResponder];
    }
}

- (void)mouseEntered:(NSEvent *)event
{
    if (self.window.isKeyWindow == NO) {
        [super mouseEntered:event];
        return;
    }
    self.isMouseInside = YES;
    self.state =
    self.isEditing ?
    KKTextFieldStateEditing :
    KKTextFieldStateHover;
}

- (void)mouseExited:(NSEvent *)event
{
    if (self.window.isKeyWindow == NO) {
        [super mouseExited:event];
        return;
    }
    self.isMouseInside = NO;
    self.state =
    self.isEditing ?
    KKTextFieldStateEditing :
    KKTextFieldStateNormal;
}

- (BOOL)mouseIsInsideTheTextFieldArea:(NSEvent *)event
{
    CGFloat left            = self.leftView.frame.size.width + self.cornerRadius;
    CGFloat right           = self.rightView.frame.size.width + self.cornerRadius;
    CGRect textFieldArea    =
    CGRectMake(left, 0, self.frame.size.width - left - right, self.frame.size.height);
    NSPoint point           = [self convertPoint:event.locationInWindow fromView:nil];
    BOOL mouseInRect        = [self mouse:point inRect:textFieldArea];
    return mouseInRect;
}

- (void)setState:(KKTextFieldState)state
{
    if (_state == state) {
        return;
    }
    _state = state;
    
    [self updateBorderWidth];
    [self updateBorderColor];
    [self updateBackgroundColor];
}

#pragma mark - 其他
- (KKTextFieldState)currentState
{
    return _state;
}

- (NSMutableDictionary<NSString *,NSNumber *> *)borderWidthMap
{
    if (_borderWidthMap == nil) {
        _borderWidthMap = [NSMutableDictionary dictionary];
    }
    return _borderWidthMap;
}

- (NSMutableDictionary<NSString *,NSColor *> *)borderColorMap
{
    if (_borderColorMap == nil) {
        _borderColorMap = [NSMutableDictionary dictionary];
    }
    return _borderColorMap;
}

- (NSMutableDictionary<NSString *,NSColor *> *)backgroundColorMap
{
    if (_backgroundColorMap == nil) {
        _backgroundColorMap = [NSMutableDictionary dictionary];
    }
    return _backgroundColorMap;
}

@end

@implementation NSView (KKTextField)

- (void)endEditing
{
    [self.window makeFirstResponder:nil];
}

@end

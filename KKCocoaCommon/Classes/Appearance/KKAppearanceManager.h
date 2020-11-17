//
//  KKAppearanceManager.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/// 系统外观更改通知
OBJC_EXTERN NSNotificationName const KKAppAppearanceDidChangeNotification;
/// 当前App外观是浅色的
OBJC_EXTERN BOOL KKAppAppearanceIsLight(void);
/// 此视图的外观是浅色的
OBJC_EXTERN BOOL KKViewAppearanceIsLight(NSView *view);

typedef void(^KKAppearanceBlock)(BOOL isLight);

/// 外观样式枚举
typedef NS_ENUM(NSUInteger, KKAppearanceStyle) {
    KKAppearanceStyleLight,  /// 默认，浅色主题
    KKAppearanceStyleDark,   /// 深色主题
};

@interface KKAppearanceManager : NSObject

/// 单例
+ (instancetype)manager;

/// 当前的外观样式：浅色、深色，设置则锁定外观样式
@property (nonatomic, readwrite) KKAppearanceStyle style;

/// 当前APP的外观
@property (nonatomic, readonly) NSAppearance *appearance;

/// 在里面设置颜色，外观更改时也会调用
- (void)addAppearanceObserver:(NSObject *)observer block:(KKAppearanceBlock)block;

/// 移除此observer的所有block
- (void)removeAppearanceObserver:(NSObject *)observer;

@end


@interface NSView (KKAppearanceManager)

/// 是深色主题
@property (nonatomic, assign, getter=isDarkMode) BOOL darkMode;
/// 是浅色主题
@property (nonatomic, assign, getter=isLightMode) BOOL lightMode;

@end


@interface NSApplication (KKAppearanceManager)

/// 是深色主题（全局）
@property (nonatomic, assign, getter=isDarkMode) BOOL darkMode;
/// 是浅色主题（全局）
@property (nonatomic, assign, getter=isLightMode) BOOL lightMode;

@end


@interface NSObject (KKAppearanceManager)

/// 在里面设置颜色，外观更改时也会调用
- (void)appearanceBlock:(KKAppearanceBlock)block;

/// 移除此observer的所有block
- (void)removeAppearanceBlocks;

@end


/// NSSystemColorsDidChangeNotification：系统强调色、高亮显示颜色更改通知
@interface NSColor (KKAppearanceManager)

/// 系统设置的强调色
@property (class, readonly) NSColor *systemAccentColor;

/// 系统预设的选中时的背景色
@property (class, readonly) NSColor *systemSelectedContentBackgroundColor;

/// 系统预设的选中但视图失去焦点时的背景色（灰色）
@property (class, readonly) NSColor *systemUnemphasizedSelectedContentBackgroundColor;

/// 系统设置的高亮显示颜色
@property (class, readonly) NSColor *systemHighlightColor;

@end

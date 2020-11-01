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
/// 当前App外观样式是白色的
OBJC_EXTERN BOOL KKAppAppearanceIsLight(void);
/// 此视图的外观样式是白色的
OBJC_EXTERN BOOL KKViewAppearanceIsLight(NSView *view);

typedef void(^KKAppearanceBlock)(BOOL isLight);

/// 外观样式枚举
typedef NS_ENUM(NSUInteger, KKAppearanceStyle) {
    KKAppearanceStyleLight,  /// 默认，白色
    KKAppearanceStyleDark,   /// 黑色
};

@interface KKAppearanceManager : NSObject

/// 单例
+ (instancetype)manager;

/// 当前的外观样式：默认（亮）、黑夜模式，设置则锁定外观样式
@property (nonatomic, readwrite) KKAppearanceStyle style;

/// 当前APP的外观
@property (nonatomic, readonly) NSAppearance *appearance;

/// 在里面设置颜色，外观更改时也会调用
- (void)addAppearanceObserver:(NSObject *)observer block:(KKAppearanceBlock)block;

/// 移除此observer的所有block
- (void)removeAppearanceObserver:(NSObject *)observer;

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

/// 系统设置的高亮显示颜色
@property (class, readonly) NSColor *systemHighlightColor;

@end

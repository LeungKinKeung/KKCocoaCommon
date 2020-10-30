//
//  KKProgressHUD.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSTextField+KK.h"
#import "NSView+KK.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, KKProgressHUDMode) {
    /// Loading，NSProgressIndicator(indeterminate:YES, style:NSProgressIndicatorStyleSpinning)
    KKProgressHUDModeIndeterminate,
    /// 圆形进度，NSProgressIndicator(indeterminate:NO, style:NSProgressIndicatorStyleSpinning)
    KKProgressHUDModeDeterminate,
    /// 横条进度，NSProgressIndicator(indeterminate:NO, style:NSProgressIndicatorStyleBar)
    KKProgressHUDModeDeterminateHorizontalBar,
    /// 进度指示器替换成自定义视图，如果不设为这个模式customView将和progressIndicator共存
    KKProgressHUDModeCustomView,
    /// 文本
    KKProgressHUDModeText
};

@interface KKProgressHUD : NSView

/// 添加并显示HUD（设置为黑色.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];）
/// @param target 视图(NSView)、视图控制器(NSViewController)、窗口(NSWindow)或屏幕（NSScreen或传nil即可）
/// @param mode 模式
/// @param title 标题
/// @param animated 是否动画
+ (instancetype)showHUDAddedTo:(_Nullable id)target mode:(KKProgressHUDMode)mode title:(NSString * _Nullable)title animated:(BOOL)animated;

/// 添加并显示文本HUD
+ (instancetype)showTextHUDAddedTo:(_Nullable id)target title:(NSString *)title hideAfterDelay:(NSTimeInterval)delay animated:(BOOL)animated;

/// 添加并显示HUD
+ (instancetype)showHUDAddedTo:(_Nullable id)target animated:(BOOL)animated;

/// 隐藏并移除HUD
/// @param animated 动画
/// @param delay 延迟
- (void)hideAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay;

/// 隐藏并移除此视图下的HUD
/// @param view 父视图
/// @param animated 是否动画
+ (void)hideHUDForView:(NSView *)view animated:(BOOL)animated;

/// 此视图下的HUD
/// @param view 父视图
+ (nullable KKProgressHUD *)HUDForView:(NSView *)view;

/// 模式
@property (nonatomic, assign) KKProgressHUDMode mode;
/// 约束视图
@property (nonatomic, strong) NSVisualEffectView *blurView;
/// 进度指示器
@property (nonatomic, strong) NSProgressIndicator *progressIndicator;
/// 自定义视图，如果不是NSControl子类且frame为空，就会被强制设为37*37大小
@property (nonatomic, strong) NSView *customView;
/// 标题
@property (nonatomic, strong) NSTextField *label;
/// 详情
@property (nonatomic, strong) NSTextField *detailsLabel;
/// 上下左右边距，默认：24
@property (nonatomic, assign) CGFloat margin;
/// 中心偏移，默认：{0,0}
@property (nonatomic, assign) CGPoint centerOffset;
/// 子视图之间的行距，默认：10
@property (nonatomic, assign) CGFloat lineSpacing;
/// 约束视图最大宽度，默认：296
@property (nonatomic, assign) CGFloat maxLayoutWidth;
/// 如果可以的话，约束宽度和高度一致
@property (nonatomic, assign, getter = isSquare) BOOL square;
/// 进度（0 ~ 1.0）
@property (nonatomic, readwrite) double progress;

/// 默认实例
+ (instancetype)hud;
/// 添加并显示HUD
- (void)addedTo:(id)target animated:(BOOL)animated;
/// 添加到屏幕并显示HUD
- (void)addedToScreen:(NSScreen *)screen animated:(BOOL)animated;
/// 添加到视图并显示HUD
- (void)addedToView:(NSView *)view animated:(BOOL)animated;
/// 关闭
- (void)hideAnimated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END

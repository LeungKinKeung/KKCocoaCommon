//
//  NSView+KKNavigation.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSView (KKNavigation)

/// 根视图控制器
@property (nonatomic, strong) NSViewController *rootViewController;
/// 顶层视图控制器
@property (nonatomic, readonly) NSViewController *topViewController;
/// 推入视图控制器
- (void)pushViewController:(NSViewController *)viewController animated:(BOOL)animated;
/// 弹出视图控制器
- (NSViewController *)popViewControllerAnimated:(BOOL)animated;
/// 弹出到某视图控制器
- (NSArray <__kindof NSViewController *> *)popToViewController:(NSViewController *)viewController animated:(BOOL)animated;
/// 弹出到根视图控制器
- (NSArray<__kindof NSViewController *> *)popToRootViewControllerAnimated:(BOOL)animated;
/// 视图控制器列表
@property (nonatomic, strong) NSMutableArray <__kindof NSViewController *> *viewControllers;

@end

typedef NS_ENUM(NSUInteger, KKNavigationBarStyle) {
    KKNavigationBarStyleSolidColor, // 纯色
    KKNavigationBarStyleBlur,       // 模糊
    KKNavigationBarStyleImage,      // 图片
};

@interface KKNavigationBar : NSView

/// 样式
@property (nonatomic, assign) KKNavigationBarStyle barStyle;
/// 上下左右间距，默认：{22,16,0,16}
@property (nonatomic, assign) NSEdgeInsets margin;
/// 高度，默认：37
@property (nonatomic, assign) CGFloat barHeight;
/// 按钮、标签之间的间距，默认：6
@property (nonatomic, assign) CGFloat interitemSpacing;
/// 模糊底图
@property (nonatomic, strong) NSVisualEffectView *blurView;
/// 纯色底图
@property (nonatomic, strong) NSView *solidColorView;
/// 图像底图
@property (nonatomic, strong) NSImageView *imageView;
/// 背景视图
@property (nonatomic, readonly) NSView *backgroundView;
/// 约束视图
@property (nonatomic, strong) NSView *containerView;
/// 左边的按钮
@property (nonatomic, copy) NSArray *leftBarButtonItems;
/// 右边的按钮
@property (nonatomic, copy) NSArray *rightBarButtonItems;
/// 中间标题的视图
@property (nonatomic, strong) NSView *titleView;
/// 标题标签
@property (nonatomic, strong) NSTextField *titleLabel;
/// 返回按钮
@property (nonatomic, strong) NSButton *backButton;
/// 设置返回按钮标题
@property (nonatomic, readwrite) NSString *backButtonTitle;
/// 圆润的返回按钮
@property (nonatomic, readwrite) BOOL mellowBackButton;
/// 分隔线
@property (nonatomic, strong) NSView *separator;

/// 初始化
- (void)commonInit;
/// 布局，如不需要则覆盖
- (void)layoutBarSubviews;
/// 返回
- (void)backButtonClick:(NSButton *)sender;

@end

@protocol KKNavigationProtocol <NSObject>

@optional
/// 是否有导航栏，默认：YES
- (BOOL)hasNavigationBar;
/// 自定义导航栏的类(必须继承KKNavigationBar)，默认：[KKNavigationBar class]，
- (Class)navigationBarClass;

@end

@interface NSViewController (KKNavigation)<KKNavigationProtocol>

/// 导航视图（可以看作navigationViewController），在viewDidAppear后才有值
@property (nonatomic, readonly) NSView *navigationView;
/// 此视图控制器是根视图控制器
@property (nonatomic, readonly) BOOL isRootViewController;
/// 导航栏
@property (nonatomic, readonly) KKNavigationBar *navigationBar;

@end

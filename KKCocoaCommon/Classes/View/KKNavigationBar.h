//
//  KKNavigationBar.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/12/4.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSUInteger, KKNavigationBarStyle) {
    KKNavigationBarStyleSolidColor, // 纯色
    KKNavigationBarStyleBlur,       // 模糊
    KKNavigationBarStyleImage,      // 图片
};

typedef NS_ENUM(NSUInteger, KKNavigationBarPosition) {
    KKNavigationBarPositionOverlaps,    // 与window.titlebar重叠，自动计算barHeight，忽略margin.top、margin.bottom
    KKNavigationBarPositionBelow,       // 在window.titlebar下面，自动计算margin.top
    KKNavigationBarPositionCustom,      // 自定义margin、barHeight
};

@interface KKNavigationBar : NSView

/// 样式
@property (nonatomic, assign) KKNavigationBarStyle barStyle;
/// 位置
@property (nonatomic, assign) KKNavigationBarPosition barPosition;
/// 上下左右间距，默认：{0,16,0,16}
@property (nonatomic, assign) NSEdgeInsets margin;
/// 高度，默认：37
@property (nonatomic, assign) CGFloat barHeight;
/// 按钮、标签之间的间距，默认：15
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
/// 左边的按钮列表（不包含backButton）
@property (nonatomic, copy) NSArray *leftBarButtonItems;
/// 右边的按钮列表
@property (nonatomic, copy) NSArray *rightBarButtonItems;
/// 左边的按钮
@property (nonatomic, readwrite) NSView *leftBarButtonItem;
/// 右边的按钮
@property (nonatomic, readwrite) NSView *rightBarButtonItem;
/// 中间标题的视图
@property (nonatomic, strong) NSView *titleView;
/// 标题标签
@property (nonatomic, strong) NSTextField *titleLabel;
/// 返回按钮
@property (nonatomic, strong) NSButton *backButton;
/// 设置返回按钮标题
@property (nonatomic, readwrite) NSString *backButtonTitle;
/// 圆润的返回按钮
@property (nonatomic, readwrite, getter=isMellowBackButton) BOOL mellowBackButton;
/// 圆润的按钮
@property (nonatomic, getter=isMellowStyleButtons) BOOL mellowStyleButtons;
/// 分隔线
@property (nonatomic, strong) NSView *separator;

/// 初始化
- (void)commonInit;
/// 布局，如不需要则覆盖
- (void)layoutBarSubviews;
/// 计算大小
- (CGSize)intrinsicContentSizeWithWindow:(NSWindow *)window;

@end

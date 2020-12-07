//
//  KKNavigationController.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/12/4.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KKNavigationBar.h"

@interface KKNavigationController : NSViewController

/// 根视图控制器
@property (nonatomic, readwrite) NSViewController *rootViewController;
/// 顶层视图控制器
@property (nonatomic, readonly) NSViewController *topViewController;
/// 视图控制器列表
@property (nonatomic, readonly) NSArray <__kindof NSViewController *> *viewControllers;
/// 动画时长，默认：0.4
@property (nonatomic, assign) CGFloat animationDuration;

/// 推入视图控制器
- (void)pushViewController:(NSViewController *)viewController animated:(BOOL)animated;
/// 弹出视图控制器
- (NSViewController *)popViewControllerAnimated:(BOOL)animated;
/// 弹出到某视图控制器
- (NSArray <__kindof NSViewController *> *)popToViewController:(NSViewController *)viewController animated:(BOOL)animated;
/// 弹出到根视图控制器
- (NSArray<__kindof NSViewController *> *)popToRootViewControllerAnimated:(BOOL)animated;

/// 初始化并自定义导航栏的类
- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass;
/// 初始化并设置根视图
- (instancetype)initWithRootViewController:(NSViewController *)rootViewController;

@end

@protocol KKNavigationControllerProtocol <NSObject>

@optional
/// 是否有导航栏，默认：NO（无）
- (BOOL)hasNavigationBar;
/// 自定义导航栏的类（必须继承KKNavigationBar），默认：[KKNavigationBar class]，
- (Class)navigationBarClass;
/// 导航栏已加载，加载顺序：navigationBarDidLoad -> viewDidLoad -> viewWillAppear -> viewDidAppear
- (void)navigationBarDidLoad;

@end

@interface NSViewController (KKNavigationController)<KKNavigationControllerProtocol>

/// 导航视图控制器
@property (nonatomic, readonly) KKNavigationController *navigationController;
/// 导航栏
@property (nonatomic, readwrite) KKNavigationBar *navigationBar;

@end

//
//  NSView+KKNavigation.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "KKNavigationBar.h"
#import "KKNavigationController.h"

/// 建议使用KKNavigationController
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

@interface NSViewController (KKNavigation)

/// 导航视图（可以看作navigationViewController），在viewDidAppear后才有值
@property (nonatomic, readonly) NSView *navigationView;

@end

//
//  AppDelegate.h
//  KKCocoaCommon_Example
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

/// 顶部状态栏按钮
@property (nonatomic, strong) NSStatusItem *statusBarItem;
/// 主窗口
@property (nonatomic, strong) NSWindowController *mainWindowController;


@end


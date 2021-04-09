//
//  AppDelegate.m
//  KKCocoaCommon_Example
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "AppDelegate.h"
#import <KKCocoaCommon/KKCocoaCommon.h>
#import "KKMainController.h"
#import "KKMainWindowController.h"

@interface AppDelegate ()<NSToolbarDelegate>

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    // 锁定为深色主题
    //[NSApplication sharedApplication].appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
    
    [KKAppearanceManager manager];
    
    // 屏幕顶部状态栏图标(22*22pt)
    NSStatusItem *item  =
    [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    self.statusBarItem  = item;
    item.button.action  = @selector(statusBarItemClicked:);
    item.button.target  = self;
    item.button.toolTip = [[NSBundle mainBundle].infoDictionary valueForKey:(__bridge NSString *)kCFBundleNameKey];
    item.button.imageScaling = NSImageScaleNone;
    item.button.image   = [NSImage imageNamed:NSImageNameSmartBadgeTemplate];
    
    // 主窗口
    NSString *mainStoryboardFileName    =
    [[NSBundle mainBundle].infoDictionary valueForKey:@"NSMainStoryboardFile"];
    NSStoryboard *mainStoryboard        =
    [NSStoryboard storyboardWithName:mainStoryboardFileName bundle:[NSBundle mainBundle]];
    NSWindowController *windowController    = [mainStoryboard instantiateControllerWithIdentifier:@"MainWindowController"];
    self.mainWindowController               = windowController;
    [windowController showWindow:nil];
    
    // 工具栏
    NSToolbar *toolbar  = [[NSToolbar alloc] initWithIdentifier:@"toolbar"];
    toolbar.allowsUserCustomization     = NO;
    toolbar.displayMode                 = NSToolbarDisplayModeIconAndLabel;
    toolbar.sizeMode                    = NSToolbarSizeModeRegular;
    toolbar.showsBaselineSeparator      = NO;
    windowController.window.toolbar         = toolbar;
    windowController.window.titleVisibility = NSWindowTitleHidden; // 工具栏和titlebar对齐
    
    // 主视图
    KKMainController *mainController    = [KKMainController new];
    windowController.contentViewController = mainController;
    
    // 顶部菜单
    NSMenuItem *menuItem    = [[NSMenuItem alloc] initWithTitle:@"" action:nil keyEquivalent:@""];
    NSMenu *subMenu         = [[NSMenu alloc] initWithTitle:@"Test"];
    NSMenuItem *testItem    = [subMenu insertItemWithTitle:@"Test Menu Item" action:@selector(testMenuItemClicked:) keyEquivalent:@"" atIndex:0];
    testItem.enabled        = YES;
    testItem.target         = self;
    menuItem.submenu        = subMenu;
    [[NSApplication sharedApplication].mainMenu insertItem:menuItem atIndex:1];
}

- (nullable NSMenu *)applicationDockMenu:(NSApplication *)sender
{
    // Dock菜单
    NSMenu *menu            = [[NSMenu alloc] initWithTitle:@""];
    NSMenuItem *firstItem   = [menu addItemWithTitle:@"First Dock Menu Item"
                                              action:@selector(testMenuItemClicked:)
                                       keyEquivalent:@""];
    firstItem.enabled       = YES;
    firstItem.target        = self;
    
    NSMenuItem *secondItem  = [menu addItemWithTitle:@"Second Dock Menu Item"
                                              action:@selector(testMenuItemClicked:)
                                       keyEquivalent:@""];
    secondItem.enabled      = YES;
    secondItem.target       = self;
    return menu;
}

- (void)testMenuItemClicked:(NSMenuItem *)sender
{
    NSLog(@"Test Menu Item Clicked");
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    if (!flag) {
        [self.mainWindowController.window makeKeyAndOrderFront:nil];
        /* or:
        for (NSWindow *window in [NSApplication sharedApplication].windows) {
            if (window == self.statusBarItem.button.window) {
                continue;
            }
            [window makeKeyAndOrderFront:nil];
            break;
        }
         */
    }
    return YES;
}

- (void)statusBarItemClicked:(NSStatusItem *)sender
{
    NSApplication *app = [NSApplication sharedApplication];
    if (app.isHidden) {
        [app unhide:sender];
    }
    if (app.isActive == NO) {
        [app activateIgnoringOtherApps:YES];
        [[NSRunningApplication currentApplication] activateWithOptions:NSApplicationActivateAllWindows];
    }
    NSWindow *window = self.mainWindowController.window;
    [window makeKeyAndOrderFront:sender];
    [window becomeFirstResponder];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    /*
     info.plist需要添加
     <key>NSSupportsAutomaticTermination</key>
     <true/>
     才能生效
     */
}


@end

//
//  AppDelegate.m
//  KKCocoaCommon_Example
//
//  Created by LeungKinKeung on 2020/10/29.
//

#import "AppDelegate.h"
#import <KKCocoaCommon/KKCocoaCommon.h>
#import "KKLoginViewController.h"

@interface AppDelegate ()

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
    NSWindowController *controller      = [mainStoryboard instantiateControllerWithIdentifier:@"Main"];
    self.mainWindowController           = controller;
    [controller.window makeKeyWindow];
    [controller showWindow:nil];
    controller.window.contentView.rootViewController = [KKLoginViewController new];
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    if (!flag) {
        [[NSApplication sharedApplication].windows.firstObject makeKeyAndOrderFront:nil];
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

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

@property (nonatomic, strong) NSWindowController *mainWindowController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    //[NSApplication sharedApplication].appearance = [NSAppearance appearanceNamed:NSAppearanceNameDarkAqua];
    
    [KKAppearanceManager manager];
    
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


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end

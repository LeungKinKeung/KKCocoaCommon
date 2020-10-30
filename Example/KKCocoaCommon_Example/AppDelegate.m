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
    
    [NSApplication sharedApplication].mainWindow.contentView.rootViewController = [KKLoginViewController new];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end

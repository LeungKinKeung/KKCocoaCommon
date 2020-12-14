//
//  KKMainWindowController.m
//  KKCocoaCommon_Example
//
//  Created by LeungKinKeung on 2020/12/8.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKMainWindowController.h"

@interface KKMainWindowController ()

@end

@implementation KKMainWindowController

- (void)loadWindow
{
    [self setWindowFrameAutosaveName:[self className]];
    
    CGRect windowFrame      = CGRectMake(0, 0, 600, 360);
    CGRect screenFrame      = [NSScreen deepestScreen].frame;
    windowFrame.origin.x    = (screenFrame.size.width - windowFrame.size.width) * 0.5;
    windowFrame.origin.y    = (screenFrame.size.height - windowFrame.size.height) * 0.5;
    
    self.window = [[NSWindow alloc] initWithContentRect:windowFrame styleMask:NSWindowStyleMaskBorderless | NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskResizable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskFullSizeContentView backing:NSBackingStoreBuffered defer:NO screen:nil];
    
    self.window.titlebarAppearsTransparent = YES;
    
    [self windowDidLoad];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self.window setFrameUsingName:[self className] force:YES];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end

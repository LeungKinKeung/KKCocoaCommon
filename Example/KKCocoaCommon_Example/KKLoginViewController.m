//
//  KKLoginViewController.m
//  KKCocoaCommon_Example
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKLoginViewController.h"
#import <KKCocoaCommon/KKCocoaCommon.h>
#import "KKMainViewController.h"
#import "KKTabelViewController.h"

@interface KKLoginViewController ()<KKTextFieldDelegate>
@property (nonatomic, strong) NSVisualEffectView *blurView;
@property (nonatomic, strong) KKTextField *accountTextField;
@property (nonatomic, strong) KKTextField *passwordTextField;
@property (nonatomic, strong) NSButton *loginButton;
@end

@implementation KKLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.layerBackgroundColor = NSColor.clearColor;
    __weak typeof(self) weakSelf = self;
    [self appearanceBlock:^(BOOL isLight) {
        NSArray *colors =
        isLight ?
        @[[NSColor colorWithWhite:1 alpha:1],[NSColor colorWithWhite:0.85 alpha:1]] :
        @[[NSColor colorWithWhite:0.2 alpha:1],[NSColor colorWithWhite:0 alpha:1]];
        [weakSelf setGradientLayerColors:colors];
    }];
//    {
//        NSVisualEffectView *view    = [NSVisualEffectView new];
//        view.state                  = NSVisualEffectStateActive;
//        view.blendingMode           = NSVisualEffectBlendingModeBehindWindow;
//        self.blurView               = view;
//        [self.view addSubview:view];
//    }
    {
        KKTextField *textField  = [KKTextField new];
        textField.placeholder   = @"Account";
        textField.cornerRadius  = 6.0;
        [textField setBackgroundColor:[NSColor colorWithWhite:0.5 alpha:0.2] forState:KKTextFieldStateNormal];
        [textField setBackgroundColor:nil forState:KKTextFieldStateEditing];
        [textField setBorderColor:nil forState:KKTextFieldStateNormal];
        [textField setBorderColor:NSColor.lightGrayColor forState:KKTextFieldStateEditing];
        [textField setBorderWidth:0.0 forState:KKTextFieldStateNormal];
        [textField setBorderWidth:1.0 forState:KKTextFieldStateEditing];
        textField.edgeInsets    = NSEdgeInsetsMake(0, 6, 0, 16);
        textField.delegate      = self;
        self.accountTextField   = textField;
        [self.view addSubview:textField];
    }
    {
        KKTextField *textField  = [KKTextField new];
        textField.placeholder   = @"Password";
        textField.cornerRadius  = 6.0;
        textField.secureTextEntry   = YES;
        [textField setBackgroundColor:[NSColor colorWithWhite:0.5 alpha:0.2] forState:KKTextFieldStateNormal];
        [textField setBackgroundColor:nil forState:KKTextFieldStateEditing];
        [textField setBorderColor:nil forState:KKTextFieldStateNormal];
        [textField setBorderColor:NSColor.lightGrayColor forState:KKTextFieldStateEditing];
        [textField setBorderWidth:0.0 forState:KKTextFieldStateNormal];
        [textField setBorderWidth:1.0 forState:KKTextFieldStateEditing];
        textField.edgeInsets    = NSEdgeInsetsMake(0, 6, 0, 16);
        textField.delegate      = self;
        self.passwordTextField  = textField;
        [self.view addSubview:textField];
    }
    self.accountTextField.nextKeyView   = self.passwordTextField;
    self.passwordTextField.nextKeyView  = self.accountTextField;
    {
        NSButton *button        = [NSButton buttonWithType:NSButtonTypeMomentaryPushIn];
        NSImage *bgImage        = [NSImage imageWithGradientColors:@[KKColor(0x1751c6, 1),KKColor(0x2269f8, 1)] size:CGSizeMake(self.view.frame.size.width - 25 * 2, 40) cornerRadius:6];
        bgImage.resizable       = YES;
        [button setBackgroundImage:bgImage scaling:NSImageScaleAxesIndependently];
        [button setTitle:@"Login" color:NSColor.whiteColor font:[NSFont systemFontOfSize:16]];
        button.target           = self;
        button.action           = @selector(loginButtonClick:);
        self.loginButton        = button;
        [self.view addSubview:button];
    }
}

- (void)loginButtonClick:(NSButton *)sender
{
    [sender addCAAnimationWithDuration:0.5 fromScale:0.95 toScale:1 fromOpacity:1 toOpacity:1 forKey:nil removedOnCompletion:YES completionBlock:nil];
    
    KKProgressHUD *hud = [KKProgressHUD showLoadingTextHUDAddedTo:self.view title:@"Login..." animated:YES];
    [hud hideAnimated:YES afterDelay:1];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [self.navigationView pushViewController:[KKTabelViewController new] animated:YES];
        //[self.navigationView pushViewController:[KKMainViewController new] animated:YES];
    });
}

- (void)viewDidLayout
{
    [super viewDidLayout];
    
    CGFloat spacing = 25;
    CGFloat height  = 40;
    CGFloat width   = self.view.frame.size.width - spacing * 2;
    
    self.blurView.frame = self.view.bounds;
    
    self.accountTextField.frame =
    CGRectMake(spacing, self.view.frame.size.height - 60 - height, width, height);
    
    self.passwordTextField.frame =
    CGRectMake(spacing, CGRectGetMinY(self.accountTextField.frame) - 15 - height, width, height);
    
    self.loginButton.frame =
    CGRectMake(spacing, CGRectGetMinY(self.passwordTextField.frame) - 15 - height, width, height);
}

- (void)dealloc
{
    [self removeAppearanceBlocks];
}

@end

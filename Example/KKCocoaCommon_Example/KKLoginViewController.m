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
@property (nonatomic, strong) NSButton *guideButton;
@property (nonatomic, copy) NSArray *guideTestButtons;
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
        textField.toolTip       = @"Input Account";
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
        textField.toolTip       = @"Input Password";
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
        button.toolTip          = @"Login Button";
        self.loginButton        = button;
        [self.view addSubview:button];
    }
    {
        NSButton *button        = [NSButton buttonWithType:NSButtonTypeMomentaryPushIn];
        [button setTitle:@"Guide"];
        button.target           = self;
        button.action           = @selector(guideButtonClick:);
        button.toolTip          = @"Guide";
        self.guideButton        = button;
        [self.view addSubview:button];
    }
    NSMutableArray *testButtons = [NSMutableArray array];
    for (NSInteger i = 0; i < 3; i++) {
        NSButton *button        = [NSButton buttonWithType:NSButtonTypeMomentaryPushIn];
        [button setTitle:@"Test Guide"];
        button.toolTip          = [NSString stringWithFormat:@"Test Guide %ld",i];
        button.hidden           = YES;
        [testButtons addObject:button];
        [self.view addSubview:button];
    }
    self.guideTestButtons       = testButtons;
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

- (void)guideButtonClick:(NSButton *)sender
{
    NSMutableArray <NSView *>*views = [NSMutableArray array];
    [views addObject:self.accountTextField];
    [views addObject:self.passwordTextField];
    [views addObject:self.loginButton];
    [views addObjectsFromArray:self.guideTestButtons];
    [views addObject:self.guideButton];
    
    for (NSButton *button in self.guideTestButtons) {
        button.hidden           = NO;
        CGSize size             = [button intrinsicContentSize];
        button.frame            = CGRectMake(arc4random_uniform(self.view.frame.size.width), arc4random_uniform(self.view.frame.size.height), size.width, size.height);
    }
    
    KKGuideView *view =
    [KKGuideView showGuideViewAddedTo:self.view targetView:views.firstObject tips:views.firstObject.toolTip completion:^(KKGuideView *guideView) {
        [views removeObjectAtIndex:0];
        if (views.count == 0) {
            [guideView removeFromSuperview];
            for (NSButton *button in self.guideTestButtons) {
                button.hidden   = YES;
            }
            return;
        }
        guideView.targetView    = views.firstObject;
        guideView.tipsLabel.text = guideView.targetView.toolTip;
    }];
    view.highlightMargin        = NSEdgeInsetsMake(3, 3, 3, 3);
    view.highlightCornerRadius  = 3;
    view.tipsLabel.font         = [NSFont fontWithName:@"HannotateSC-W5" size:18];
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
    CGRectMake(spacing, CGRectGetMinY(self.passwordTextField.frame) - 15 - height - 30, width, height);
    
    CGSize guideButtonSize = [self.guideButton intrinsicContentSize];
    CGFloat x = self.view.frame.size.width - spacing - guideButtonSize.width;
    CGFloat y = spacing;
    self.guideButton.frame =
    CGRectMake(x, y,  guideButtonSize.width,  guideButtonSize.height);
}

- (void)dealloc
{
    [self removeAppearanceBlocks];
}

@end

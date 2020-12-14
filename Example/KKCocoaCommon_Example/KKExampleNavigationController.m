//
//  KKExampleNavigationController.m
//  KKCocoaCommon_Example
//
//  Created by LeungKinKeung on 2020/12/14.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKExampleNavigationController.h"

@implementation KKNavigationRootController

- (NSString *)title
{
    return @"Navigation Controller";
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.rootViewController = [KKExampleNavigationController new];
}

@end

@interface KKExampleViewController : KKViewController

@property (nonatomic, strong) NSScrollView *scrollView;

@end

@implementation KKExampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    KKNavigationBar *navigationBar  = self.navigationBar;
    navigationBar.titleLabel.text   = @"Second View Controller";
    navigationBar.barStyle          = KKNavigationBarStyleBlur;
    
    {
        NSScrollView *view      = [[NSScrollView alloc] initWithFrame:self.view.bounds];
        view.focusRingType      = NSFocusRingTypeNone;
        view.borderType         = NSNoBorder;
        view.backgroundColor    = NSColor.clearColor;
        view.drawsBackground    = NO;
        view.scrollerStyle      = NSScrollerStyleOverlay;
        view.autohidesScrollers = YES;
        self.scrollView         = view;
        [self.view addSubview:view];
        view.autoresizingMask   = NSViewWidthSizable | NSViewHeightSizable;
    }
}

- (BOOL)hasNavigationBar
{
    return YES;
}

@end

@interface KKExampleNavigationController ()
@property (weak) IBOutlet NSSegmentedControl *barStylePicker;
@property (weak) IBOutlet NSSegmentedControl *barPositionPicker;
@property (weak) IBOutlet NSButton *separatorButton;
@property (weak) IBOutlet NSColorWell *barSolidColorWell;
@property (weak) IBOutlet NSColorWell *barGradientColorLeftWell;
@property (weak) IBOutlet NSColorWell *barGradientColorRightWell;

@property (weak) IBOutlet NSTextField *paddingTopTextField;
@property (weak) IBOutlet NSTextField *paddingLeftTextField;
@property (weak) IBOutlet NSTextField *paddingBottomTextField;
@property (weak) IBOutlet NSTextField *paddingRightTextField;
@property (weak) IBOutlet NSTextField *barHeightTextField;
@property (weak) IBOutlet NSTextField *interitemSpacingTextField;

@end

@implementation KKExampleNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:NSTextDidChangeNotification object:nil];
    
    self.navigationBar.titleLabel.text          = @"Navigation Bar";
    self.navigationBar.blurView.blendingMode    = NSVisualEffectBlendingModeBehindWindow;
    
    NSMutableArray *rightBarButtonItems = NSMutableArray.new;
    NSArray *imageNames = @[NSImageNameAddTemplate,NSImageNameRemoveTemplate,NSImageNameListViewTemplate,NSImageNameMenuOnStateTemplate];
    for (NSString *name in imageNames) {
        NSButton *button =
        [NSButton imageButtonWithImage:[NSImage imageNamed:name]
                                target:self
                                action:@selector(navigationBarButtonItemClick:)];
        [rightBarButtonItems addObject:button];
    }
    self.navigationBar.rightBarButtonItems = rightBarButtonItems;
    
    NSMutableArray *leftBarButtonItems = NSMutableArray.new;
    imageNames = @[NSImageNameQuickLookTemplate,NSImageNameIChatTheaterTemplate,NSImageNameSlideshowTemplate,NSImageNameHomeTemplate];
    for (NSString *name in imageNames) {
        NSButton *button =
        [NSButton imageButtonWithImage:[NSImage imageNamed:name]
                                target:self
                                action:@selector(navigationBarButtonItemClick:)];
        [leftBarButtonItems addObject:button];
    }
    
    self.navigationBar.leftBarButtonItems   = leftBarButtonItems;
    self.paddingLeftTextField.stringValue   = [NSString stringWithFormat:@"%.0f",self.navigationBar.padding.left];
    self.paddingRightTextField.stringValue  = [NSString stringWithFormat:@"%.0f",self.navigationBar.padding.right];
    
    [self colorChanged:nil];
}

- (void)navigationBarButtonItemClick:(NSButton *)sender
{
    NSLog(@"Navigation Bar Button Item Click");
}

- (BOOL)hasNavigationBar
{
    return YES;
}

- (void)textDidChange:(NSNotification *)notification
{
    NSText *textField = notification.object;
    
    if (textField == [self.paddingTopTextField currentEditor] ||
        textField == [self.paddingLeftTextField currentEditor] ||
        textField == [self.paddingRightTextField currentEditor] ||
        textField == [self.paddingBottomTextField currentEditor]) {
        self.navigationBar.padding =
        NSEdgeInsetsMake(self.paddingTopTextField.stringValue.doubleValue,
                         self.paddingLeftTextField.stringValue.doubleValue,
                         self.paddingBottomTextField.stringValue.doubleValue,
                         self.paddingRightTextField.stringValue.doubleValue);
    } else if (textField == [self.interitemSpacingTextField currentEditor]) {
        self.navigationBar.interitemSpacing = self.interitemSpacingTextField.stringValue.doubleValue;
    } else if (textField == [self.barHeightTextField currentEditor]) {
        self.navigationBar.barHeight = self.barHeightTextField.stringValue.doubleValue;
    }
}

- (IBAction)colorChanged:(id)sender {
    KKNavigationBar *navigationBar = self.navigationBar;
    switch (navigationBar.barStyle) {
        case KKNavigationBarStyleSolidColor: {

            navigationBar.solidColorView.layer.backgroundColor = self.barSolidColorWell.color.CGColor;
            break;
        }
        case KKNavigationBarStyleImage: {

            navigationBar.imageView.image = [NSImage imageWithGradientColors:@[self.barGradientColorLeftWell.color,self.barGradientColorRightWell.color] size:CGSizeMake(self.view.bounds.size.width, 30) cornerRadius:0];
            break;
        }
        default: {
            break;
        }
    }
}

- (IBAction)barStyleChanged:(NSSegmentedControl *)sender {
    
    self.navigationBar.barStyle = sender.selectedSegment;
    [self colorChanged:nil];
}

- (IBAction)barPositionChanged:(NSSegmentedControl *)sender {
    
    self.navigationBar.barPosition = sender.selectedSegment;
}

- (IBAction)separatorButtonClick:(NSButton *)sender {
    self.navigationBar.separator.hidden = !sender.isOnState;
}

- (IBAction)push:(id)sender {
    [self.navigationController pushViewController:[KKExampleViewController new] animated:YES];
}

- (IBAction)mellowStyleButtons:(NSButton *)sender {
    self.navigationBar.mellowStyleButtons = sender.isOnState;
}

@end

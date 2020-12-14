//
//  KKHUDViewController.m
//  KKCocoaCommon_Example
//
//  Created by LeungKinKeung on 2020/12/9.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKHUDViewController.h"
#import <KKCocoaCommon/KKCocoaCommon.h>

@interface KKHUDViewController ()
@property (weak) IBOutlet NSSegmentedControl *modePicker;
@property (weak) IBOutlet NSSegmentedControl *backgroundStylePicker;
@property (weak) IBOutlet NSSegmentedControl *addtoPicker;
@property (weak) IBOutlet NSButton *animationSwitch;
@property (weak) IBOutlet NSButton *squareSwitch;
@property (weak) IBOutlet NSTextField *paddingTextField;
@property (weak) IBOutlet NSTextField *marginTextField;
@property (weak) IBOutlet NSTextField *spacingTextField;
@property (weak) IBOutlet NSTextField *maxWidthTextField;
@property (weak) IBOutlet NSTextField *delayTextField;
@property (weak) IBOutlet NSTextField *titleTextField;
@property (weak) IBOutlet NSTextField *detailsTextField;

@end

@implementation KKHUDViewController

- (NSString *)title
{
    return @"HUD";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (IBAction)show:(id)sender {
    
    KKProgressHUDMode mode = self.modePicker.selectedSegment;
    
    id dest = nil;
    switch (self.addtoPicker.selectedSegment) {
        case 0: {
            dest = self.view;
            break;
        }
        case 1: {
            dest = self.view.window;
            break;
        }
        default: {
            break;
        }
    }
    
    NSString *title     = self.titleTextField.stringValue.length > 0 ? self.titleTextField.stringValue : nil;
    BOOL animated       = self.animationSwitch.state == NSControlStateValueOn;
    KKProgressHUD *hud  =
    [KKProgressHUD showHUDAddedTo:dest mode:mode title:title animated:animated];
    
    if (self.detailsTextField.stringValue.length > 0) {
        hud.detailsLabel.text = self.detailsTextField.stringValue;
    }
    switch (mode) {
        case KKProgressHUDModeCustomView: {
            NSImageView *imageView  = [NSImageView new];
            imageView.image         = [NSImage imageNamed:NSImageNameInfo];
            hud.customView          = imageView;
            break;
        }
        case KKProgressHUDModeDeterminate:
        case KKProgressHUDModeDeterminateHorizontalBar: {
            if (@available(macOS 10.12, *)) {
                [NSTimer scheduledTimerWithTimeInterval:0.2 repeats:YES block:^(NSTimer * _Nonnull timer) {
                    if (hud.progress >= 100) {
                        return;
                    }
                    double progress = hud.progress + 0.1;
                    [hud setProgress:progress animated:YES];
                }];
            }
            break;
        }
        default: {
            break;
        }
    }
    hud.style           = self.backgroundStylePicker.selectedSegment;
    hud.minimumMargin   = self.marginTextField.stringValue.doubleValue;
    hud.padding         = self.paddingTextField.stringValue.doubleValue;
    hud.square          = self.squareSwitch.state == NSControlStateValueOn;
    hud.preferredMaxLayoutWidth = self.maxWidthTextField.stringValue.doubleValue;
    hud.interitemSpacing        = self.spacingTextField.stringValue.doubleValue;
    
    [hud hideAnimated:animated afterDelay:self.delayTextField.stringValue.doubleValue];
}

@end

//
//  KKTextFieldViewController.m
//  KKCocoaCommon_Example
//
//  Created by v_ljqliang on 2020/12/17.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKTextFieldViewController.h"
#import <KKCocoaCommon/KKCocoaCommon.h>

@interface KKTextFieldViewController ()

@property (weak) IBOutlet KKTextField *textField;
@property (weak) IBOutlet NSSegmentedControl *alignmentSegmentedControl;
@property (weak) IBOutlet NSTextField *fontSizeTextField;
@property (weak) IBOutlet NSStepper *fontSizeStepper;
@property (weak) IBOutlet NSTextField *placeholderTextField;
@property (weak) IBOutlet NSColorWell *textColorWell;
@property (weak) IBOutlet NSColorWell *backgroundColorWell;
@property (weak) IBOutlet NSColorWell *insertionPointColorWell;
@property (weak) IBOutlet NSColorWell *placeholderColorWell;
@property (weak) IBOutlet NSColorWell *borderColorWell;

@property (weak) IBOutlet NSTextField *paddingLeftTextField;
@property (weak) IBOutlet NSTextField *paddingRightTextField;
@property (weak) IBOutlet NSTextField *cornerRadiusTextField;
@property (weak) IBOutlet NSTextField *borderWidthTextField;

@property (weak) IBOutlet NSButton *editableButton;
@property (weak) IBOutlet NSButton *secureTextEntryButton;

@end

@implementation KKTextFieldViewController

- (NSString *)title
{
    return @"Text Field";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    
    self.textField.padding =
    NSEdgeInsetsMake(0, self.paddingLeftTextField.stringValue.doubleValue, 0, self.paddingRightTextField.stringValue.doubleValue);
    self.textField.placeholder = self.placeholderTextField.stringValue;
    self.textField.cornerRadius = self.cornerRadiusTextField.doubleValue;
    self.textField.borderWidth = self.borderWidthTextField.doubleValue;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:NSTextDidChangeNotification
                                               object:nil];
}

- (void)textDidChange:(NSNotification *)notification
{
    NSText *text = notification.object;
    if (text == [self.paddingLeftTextField currentEditor] ||
        text == [self.paddingRightTextField currentEditor]) {
        self.textField.padding =
        NSEdgeInsetsMake(0, self.paddingLeftTextField.stringValue.doubleValue, 0, self.paddingRightTextField.stringValue.doubleValue);
    } else if (text == [self.cornerRadiusTextField currentEditor]) {
        self.textField.cornerRadius = text.string.doubleValue;
    } else if (text == [self.borderWidthTextField currentEditor]) {
        self.textField.borderWidth = text.string.doubleValue;
    } else if (text == [self.fontSizeTextField currentEditor]) {
        self.fontSizeStepper.intValue = text.string.intValue;
        self.textField.font = [NSFont systemFontOfSize:text.string.doubleValue];
    } else if (text == [self.placeholderTextField currentEditor]) {
        self.textField.placeholder = text.string;
    }
}

- (IBAction)alignmentDidChange:(NSSegmentedControl *)sender {
    [self.textField endEditing];
    switch (sender.selectedSegment) {
        case 1: {
            self.textField.textAlignment = NSTextAlignmentCenter;
            break;
        }
        case 2: {
            self.textField.textAlignment = NSTextAlignmentRight;
            break;
        }
        default: {
            self.textField.textAlignment = NSTextAlignmentLeft;
            break;
        }
    }
}

- (IBAction)fontSizeDidChange:(NSStepper *)sender {
    self.fontSizeTextField.stringValue = [NSString stringWithFormat:@"%d",sender.intValue];
    self.textField.font = [NSFont systemFontOfSize:sender.intValue];
}

- (IBAction)textColorDidChange:(NSColorWell *)sender {
    self.textField.textColor = sender.color;
}

- (IBAction)backgroundColorDidChange:(NSColorWell *)sender {
    self.textField.backgroundColor = sender.color;
}

- (IBAction)insertionPointColorDidChange:(NSColorWell *)sender {
    self.textField.insertionPointColor = sender.color;
}

- (IBAction)placeholderColorDidChange:(NSColorWell *)sender {
    self.textField.placeholderColor = sender.color;
}

- (IBAction)borderColorDidChange:(NSColorWell *)sender {
    self.textField.borderColor = sender.color;
}

- (IBAction)leftViewDidChange:(NSPopUpButton *)sender {
    switch (sender.indexOfSelectedItem) {
        case 1: {
            NSButton *button        = [NSButton new];
            button.image            = [NSImage imageNamed:NSImageNameRevealFreestandingTemplate];
            button.bezelStyle       = NSBezelStyleTexturedRounded;
            button.bordered         = YES;
            self.textField.leftView = button;
            break;
        }
        case 2: {
            NSImageView *view       = [NSImageView new];
            view.image              = [NSImage imageNamed:NSImageNameUser];
            self.textField.leftView = view;
            break;
        }
        default: {
            self.textField.leftView = nil;
            break;
        }
    }
}

- (IBAction)rightViewDidChange:(NSPopUpButton *)sender {
    switch (sender.indexOfSelectedItem) {
        case 1: {
            NSButton *button        = [NSButton new];
            button.image            = [NSImage imageNamed:NSImageNameRevealFreestandingTemplate];
            button.bezelStyle       = NSBezelStyleTexturedRounded;
            button.bordered         = YES;
            self.textField.rightView = button;
            break;
        }
        case 2: {
            NSImageView *view       = [NSImageView new];
            view.image              = [NSImage imageNamed:NSImageNameUser];
            self.textField.rightView = view;
            break;
        }
        default: {
            self.textField.rightView = nil;
            break;
        }
    }
}

- (IBAction)editableDidChange:(NSButton *)sender {
    self.textField.editable = sender.isOnState;
}

- (IBAction)secureTextEntryDidChange:(NSButton *)sender {
    self.textField.secureTextEntry = sender.isOnState;
}

    
@end

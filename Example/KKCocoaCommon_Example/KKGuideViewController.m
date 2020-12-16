//
//  KKGuideViewController.m
//  KKCocoaCommon_Example
//
//  Created by v_ljqliang on 2020/12/15.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKGuideViewController.h"
#import <KKCocoaCommon/KKCocoaCommon.h>

@interface KKGuideViewController ()

@property (weak) IBOutlet NSSegmentedControl *highlightShapeStyleSegmentedControl;
@property (weak) IBOutlet NSSegmentedControl *tipsBorderShapeStyleSegmentedControl;
@property (weak) IBOutlet NSSegmentedControl *tipsBorderLineFillStyleSegmentedControl;
@property (weak) IBOutlet NSSegmentedControl *leadingLineFillStyleSegmentedControl;
@property (weak) IBOutlet NSSegmentedControl *leadingLineCurveStyleSegmentedControl;

@property (weak) IBOutlet NSTextField *highlightPaddingTextField;
@property (weak) IBOutlet NSTextField *highlightCornerRadiusTextField;
@property (weak) IBOutlet NSTextField *tipsBorderPaddingTextField;
@property (weak) IBOutlet NSTextField *tipsBorderCornerRadiusTextField;
@property (weak) IBOutlet NSButton *customLineOffsetButton;
@property (weak) IBOutlet NSTextField *centerOffsetXTextField;
@property (weak) IBOutlet NSTextField *centerOffsetYTextField;
@property (weak) IBOutlet NSTextField *leadingLineWidthTextField;
@property (weak) IBOutlet NSTextField *borderLineWidthTextField;
@property (weak) IBOutlet NSColorWell *tintColorWell;
@property (weak) IBOutlet NSColorWell *backgroundColorWell;

@property (nonatomic, strong) KKGuideView *guideView;

@end

@implementation KKGuideViewController

- (NSString *)title
{
    return @"Guide View";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange:)
                                                 name:NSTextDidChangeNotification object:nil];
}

- (void)textDidChange:(NSNotification *)notification
{
    /*
    NSText *textField = notification.object;
    if (textField == [self.highlightPaddingTextField currentEditor]) {
        CGFloat value = textField.string.doubleValue;
        self.guideView.highlightPadding = NSEdgeInsetsMake(value, value, value, value);
    } else if (textField == [self.highlightCornerRadiusTextField currentEditor]) {
        self.guideView.highlightCornerRadius = textField.string.doubleValue;
    } else if (textField == [self.tipsBorderPaddingTextField currentEditor]) {
        CGFloat value = textField.string.doubleValue;
        self.guideView.tipsBorderPadding = NSEdgeInsetsMake(value, value, value, value);
    } else if (textField == [self.tipsBorderCornerRadiusTextField currentEditor]) {
        self.guideView.tipsBorderCornerRadius = textField.string.doubleValue;
    } else if (textField == [self.centerOffsetXTextField currentEditor] ||
               textField == [self.centerOffsetYTextField currentEditor]) {
        self.guideView.lineOffset =
        CGPointMake(self.centerOffsetXTextField.stringValue.doubleValue,
                    self.centerOffsetYTextField.stringValue.doubleValue);
    } else if (textField == [self.leadingLineWidthTextField currentEditor]) {
        self.guideView.leadingLineWidth = textField.string.doubleValue;
    } else if (textField == [self.borderLineWidthTextField currentEditor]) {
        self.guideView.borderLineWidth = textField.string.doubleValue;
    }
    */
}

- (IBAction)highlightShapeStyleDidChange:(NSSegmentedControl *)sender {
    self.guideView.highlightShapeStyle = sender.selectedSegment;
}

- (IBAction)tipsBorderShapeStyleDidChange:(NSSegmentedControl *)sender {
    self.guideView.tipsBorderShapeStyle = sender.selectedSegment;
}

- (IBAction)tipsBorderLineFillStyleDidChange:(NSSegmentedControl *)sender {
    self.guideView.tipsBorderLineFillStyle = sender.selectedSegment;
}

- (IBAction)leadingLineFillStyleDidChange:(NSSegmentedControl *)sender {
    self.guideView.leadingLineFillStyle = sender.selectedSegment;
}

- (IBAction)leadingLineCurveStyleDidChange:(NSSegmentedControl *)sender {
    self.guideView.leadingLineCurveStyle = sender.selectedSegment;
}

- (IBAction)tintColorDidChange:(NSColorWell *)sender {
    self.guideView.tintColor = sender.color;
}

- (IBAction)backgroundColorDidChange:(NSColorWell *)sender {
    self.guideView.backgroundColor = sender.color;
}

- (IBAction)customLineOffset:(NSButton *)sender {
    self.centerOffsetXTextField.enabled =
    self.centerOffsetYTextField.enabled = sender.isOnState;
}

- (IBAction)show:(NSButton *)sender {
    NSMutableArray <NSView *>*views = [NSMutableArray array];
    
    for (NSView *view in self.view.subviews) {
        if (arc4random_uniform(2)) {
            [views addObject:view];
        }
    }
    
    self.guideView =
    [KKGuideView showGuideViewAddedTo:self.view targetView:views.firstObject tips:[NSString stringWithFormat:@"%@",views.firstObject] completion:^(KKGuideView *guideView) {
        [views removeObjectAtIndex:0];
        if (views.count == 0) {
            [guideView removeFromSuperview];
            self.guideView = nil;
            return;
        }
        guideView.targetView        = views.firstObject;
        guideView.tipsLabel.text    = [NSString stringWithFormat:@"%@",views.firstObject];
    }];
    self.guideView.tipsLabel.font   = [NSFont fontWithName:@"HannotateSC-W5" size:18];
    
    CGFloat highlightPadding = self.highlightPaddingTextField.stringValue.doubleValue;
    self.guideView.highlightPadding = NSEdgeInsetsMake(highlightPadding, highlightPadding, highlightPadding, highlightPadding);
    self.guideView.highlightCornerRadius = self.highlightCornerRadiusTextField.stringValue.doubleValue;
    CGFloat tipsBorderPadding = self.tipsBorderPaddingTextField.stringValue.doubleValue;
    self.guideView.tipsBorderPadding = NSEdgeInsetsMake(tipsBorderPadding, tipsBorderPadding, tipsBorderPadding, tipsBorderPadding);
    self.guideView.tipsBorderCornerRadius = self.tipsBorderCornerRadiusTextField.stringValue.doubleValue;
    if (self.customLineOffsetButton.isOnState) {
        self.guideView.tipsViewCenterOffset =
        CGPointMake(self.centerOffsetXTextField.stringValue.doubleValue,
                    self.centerOffsetYTextField.stringValue.doubleValue);
    }
    self.guideView.leadingLineWidth     = self.leadingLineWidthTextField.stringValue.doubleValue;
    self.guideView.borderLineWidth      = self.borderLineWidthTextField.stringValue.doubleValue;
    self.guideView.tintColor            = self.tintColorWell.color;
    self.guideView.backgroundColor      = self.backgroundColorWell.color;
    self.guideView.leadingLineFillStyle = self.leadingLineFillStyleSegmentedControl.selectedSegment;
    self.guideView.tipsBorderShapeStyle = self.tipsBorderShapeStyleSegmentedControl.selectedSegment;
    self.guideView.leadingLineCurveStyle    = self.leadingLineCurveStyleSegmentedControl.selectedSegment;
    self.guideView.tipsBorderLineFillStyle  = self.tipsBorderLineFillStyleSegmentedControl.selectedSegment;
    self.guideView.tipsBorderCornerRadius   = self.tipsBorderCornerRadiusTextField.stringValue.doubleValue;
}

@end

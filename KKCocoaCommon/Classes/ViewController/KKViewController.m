//
//  KKViewController.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKViewController.h"

@interface KKViewController ()

@end

@implementation KKViewController

- (void)loadView
{
    if ([[NSBundle mainBundle] loadNibNamed:[self className] owner:nil topLevelObjects:nil]) {
        [super loadView];
    }
}

- (NSView *)view
{
    if (self.isViewLoaded == NO) {
        [super setView:[NSView new]];
        [self viewDidLoad];
    }
    return [super view];
}

- (CAGradientLayer *)gradientLayer
{
    if (_gradientLayer == nil) {
        _gradientLayer              = [CAGradientLayer layer];
        _gradientLayer.colors       = @[(id)[NSColor colorWithWhite:0.95 alpha:1].CGColor,(id)[NSColor colorWithWhite:0.8 alpha:1].CGColor];
        _gradientLayer.startPoint   = self.view.isFlipped ? CGPointMake(0, 0) : CGPointMake(0, 1);
        _gradientLayer.endPoint     = self.view.isFlipped ? CGPointMake(0, 1) : CGPointMake(0, 0);
        _gradientLayer.frame        = self.view.layer.bounds;
        self.view.wantsLayer        = YES;
        [self.view.layer addSublayer:_gradientLayer];
    }
    return _gradientLayer;
}

- (void)setGradientLayerColors:(NSArray<NSColor *> *)colors
{
    NSMutableArray *cgcolors = [NSMutableArray array];
    for (NSColor *color in colors) {
        id value = (__bridge id)color.CGColor;
        if (value) {
            [cgcolors addObject:value];
        }
    }
    if (cgcolors.count == 0) {
        return;
    }
    self.gradientLayer.colors = cgcolors;
}

- (void)viewDidLayout
{
    [super viewDidLayout];
    
    [NSAnimationContext beginGrouping];
    NSAnimationContext *ctx = [NSAnimationContext currentContext];
    ctx.duration            = 0;
    if (_gradientLayer) {
        _gradientLayer.frame = self.view.layer.bounds;
    }
    [NSAnimationContext endGrouping];
}


@end
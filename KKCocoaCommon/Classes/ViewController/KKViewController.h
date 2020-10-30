//
//  KKViewController.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@interface KKViewController : NSViewController

/// 背景渐变图层（如需要，直接[self gradientLayer]）
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

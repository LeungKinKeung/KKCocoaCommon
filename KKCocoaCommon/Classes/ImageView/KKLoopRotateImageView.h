//
//  KKLoopRotateImageView.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface KKLoopRotateImageView : NSControl

- (instancetype)initWithImage:(NSImage *)image;

- (instancetype)initWithImageNamed:(NSImageName)name;

- (instancetype)initWithTemplateImageNamed:(NSImageName)name;

- (instancetype)initWithTemplateImage:(NSImage *)image;

@property (nonatomic, readonly) NSImageView *imageView;

@property (nonatomic, readwrite) NSImageScaling imageScaling;

@end

NS_ASSUME_NONNULL_END

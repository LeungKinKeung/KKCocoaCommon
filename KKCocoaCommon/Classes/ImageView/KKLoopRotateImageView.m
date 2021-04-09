//
//  KKLoopRotateImageView.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKLoopRotateImageView.h"
#import "NSView+KKAnimation.h"

@interface KKLoopRotateImageView ()

@property (nonatomic, strong) NSImageView *imageView;

@end

@implementation KKLoopRotateImageView

- (instancetype)initWithImage:(NSImage *)image
{
    self = [super init];
    if (self) {
        self.imageView.image = image;
    }
    return self;
}

- (NSImageView *)imageView
{
    if (!_imageView) {
        _imageView = [NSImageView new];
        _imageView.imageScaling = NSImageScaleNone;
        [self addSubview:_imageView];
    }
    return _imageView;
}

- (instancetype)initWithImageNamed:(NSImageName)name
{
    return [self initWithImage:[NSImage imageNamed:name]];
}

- (instancetype)initWithTemplateImageNamed:(NSImageName)name
{
    NSImage *image = [NSImage imageNamed:name];
    image.template = YES;
    return [self initWithImage:image];
}

- (instancetype)initWithTemplateImage:(NSImage *)image
{
    image.template = YES;
    return [self initWithImage:image];
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldSize
{
    [super resizeWithOldSuperviewSize:oldSize];
    [self.layer removeAnimationForKey:[self className]];
}

- (void)updateTrackingAreas
{
    [super updateTrackingAreas];
    [self.imageView removeCAAnimationForKey:[self className]];
    [self.imageView addLoopRotateAnimationForKey:[self className]];
}

- (void)layout
{
    [super layout];
    
    self.imageView.frame = self.bounds;
}

- (NSSize)intrinsicContentSize
{
    return self.imageView.intrinsicContentSize;
}

- (void)setImageScaling:(NSImageScaling)imageScaling
{
    self.imageView.imageScaling = imageScaling;
}

- (NSImageScaling)imageScaling
{
    return self.imageView.imageScaling;
}

@end

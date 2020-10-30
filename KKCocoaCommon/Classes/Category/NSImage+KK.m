//
//  NSImage+KK.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "NSImage+KK.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreImage/CoreImage.h>
#import "NSBezierPath+KK.h"

@implementation NSImage (KK)

#pragma mark - CGImage
- (CGImageRef)CGImage
{
    return [self CGImageForProposedRect:NULL context:NULL hints:nil];
}

#pragma mark 实际大小
- (CGSize)CGImageSize
{
    return CGSizeMake(CGImageGetWidth(self.CGImage), CGImageGetHeight(self.CGImage));
}

- (void)setResizable:(BOOL)resizable
{
    if (resizable) {
        self.resizingMode   = NSImageResizingModeStretch;
        self.capInsets      = NSEdgeInsetsMake(self.size.height * 0.5, self.size.width * 0.5, self.size.height * 0.5, self.size.width * 0.5);
    } else {
        self.resizingMode   = NSImageResizingModeTile;
        self.capInsets      = NSEdgeInsetsMake(0, 0, 0, 0);
    }
}

- (BOOL)isResizable
{
    return self.resizingMode == NSImageResizingModeStretch;
}

+ (instancetype)imageWithSize:(NSSize)size retina:(BOOL)retina drawingHandler:(void (^)(CGContextRef context, CGFloat scale, CGRect dstRect))drawingHandler
{
    //创建bitmap
    CGFloat screenScale = MIN([[NSScreen deepestScreen] backingScaleFactor], 1);
    size_t width        = size.width * screenScale;
    size_t height       = size.height * screenScale;
    CGColorSpaceRef cs  = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmapRef  = CGBitmapContextCreate(nil, width, height, 8, 0, cs, kCGImageAlphaPremultipliedLast);
    if (drawingHandler) {
        drawingHandler(bitmapRef, screenScale, CGRectMake(0, 0, width, height));
    }
    //保存图像
    CGImageRef dstImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    return [[NSImage alloc] initWithCGImage:dstImage size:NSMakeSize(width, height)];
}

+ (instancetype)imageWithImage:(NSImage *)image size:(CGSize)size
{
    if (image == nil) {
        return nil;
    }
    CGFloat scale       = MIN([[NSScreen deepestScreen] backingScaleFactor], 1);
    NSSize newSize      = NSZeroSize;
    newSize.width       = size.width / scale;
    newSize.height      = size.height / scale;
    NSRect drawFrame    = NSMakeRect(0, 0, newSize.width, newSize.height);
    NSImageRep *sourceImageRep =
    [image bestRepresentationForRect:drawFrame
                            context:nil
                              hints:nil];
    
    NSImage *targetImage = [[NSImage alloc] initWithSize:newSize];
    [targetImage lockFocus];
    [sourceImageRep drawInRect:drawFrame];
    [targetImage unlockFocus];
    NSData *imageData = [targetImage TIFFRepresentation];
    return [[self alloc] initWithData:imageData];
}

+ (instancetype)imageWithGradientColors:(NSArray <NSColor *>*)colors size:(CGSize)size cornerRadius:(CGFloat)cornerRadius
{
    if (size.width == 0 || size.height == 0) {
        return nil;
    }
    NSMutableArray *cgcolors = [NSMutableArray array];
    for (NSColor *color in colors) {
        id value = (__bridge id)color.CGColor;
        if (value) {
            [cgcolors addObject:value];
        }
    }
    if (cgcolors.count == 0) {
        return nil;
    }
    CAGradientLayer *layer  = [CAGradientLayer layer];
    layer.frame             = CGRectMake(0, 0, size.width, size.height);
    layer.colors            = cgcolors;
    layer.startPoint        = CGPointMake(0.0, 0.0);
    layer.endPoint          = CGPointMake(1.0, 0.0);
    layer.cornerRadius      = cornerRadius;
    
    NSImage *image =
    [self imageWithSize:size flipped:YES drawingHandler:^BOOL(NSRect dstRect) {
        
        CGContextRef ctx = [NSGraphicsContext currentContext].CGContext;
        [layer renderInContext:ctx];
        
        return YES;
    }];
    return image;
}

+ (instancetype)imageWithBorderGradientColors:(NSArray <NSColor *>*)colors backgroundColor:(nullable NSColor *)backgroundColor size:(CGSize)size borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius
{
    if (size.width == 0 || size.height == 0) {
        return nil;
    }
    NSMutableArray *cgcolors = [NSMutableArray array];
    for (NSColor *color in colors) {
        id value = (__bridge id)color.CGColor;
        if (value) {
            [cgcolors addObject:value];
        }
    }
    if (cgcolors.count == 0) {
        return nil;
    }
    CGFloat spacing             = borderWidth * 0.5;
    NSBezierPath *bezierPath    = [NSBezierPath bezierPathWithRoundedRect:CGRectMake(spacing, spacing, size.width - borderWidth, size.height - borderWidth) xRadius:cornerRadius yRadius:cornerRadius];
    CGPathRef cgpath            = bezierPath.CGPath;
    CAShapeLayer *shapeLayer    = [CAShapeLayer new];
    shapeLayer.path             = cgpath;
    shapeLayer.lineWidth        = borderWidth;
    shapeLayer.fillColor        = nil;
    shapeLayer.strokeColor      = NSColor.whiteColor.CGColor;
    CGPathRelease(cgpath);
    
    CAGradientLayer *layer      = [CAGradientLayer layer];
    layer.frame                 = CGRectMake(0, 0, size.width, size.height);
    layer.colors                = cgcolors;
    layer.startPoint            = CGPointMake(0.0, 0.0);
    layer.endPoint              = CGPointMake(1.0, 0.0);
    layer.mask                  = shapeLayer;
    
    CALayer *calayer            = nil;
    if (backgroundColor) {
        calayer                 = [CALayer layer];
        calayer.frame           = CGRectMake(0, 0, size.width, size.height);
        calayer.backgroundColor = backgroundColor.CGColor;
        calayer.cornerRadius    = cornerRadius;
    }
    
    NSImage *image =
    [self imageWithSize:size flipped:YES drawingHandler:^BOOL(NSRect dstRect) {
        
        CGContextRef ctx = [NSGraphicsContext currentContext].CGContext;
        
        if (calayer) {
            [calayer renderInContext:ctx];
        }
        [layer renderInContext:ctx];
        
        return YES;
    }];
    return image;
}

+ (instancetype)imageWithBackgroundColor:(NSColor *)backgroundColor borderColor:(NSColor *)borderColor size:(CGSize)size borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius
{
    if (size.width == 0 || size.height == 0) {
        return nil;
    }
    
    CALayer *layer          = [CALayer layer];
    layer.frame             = CGRectMake(0, 0, size.width, size.height);
    layer.backgroundColor   = backgroundColor.CGColor;
    layer.cornerRadius      = cornerRadius;
    layer.borderColor       = borderColor.CGColor;
    layer.borderWidth       = borderWidth;
    
    NSImage *image =
    [self imageWithSize:size flipped:YES drawingHandler:^BOOL(NSRect dstRect) {
        
        CGContextRef ctx = [NSGraphicsContext currentContext].CGContext;
        [layer renderInContext:ctx];
        
        return YES;
    }];
    return image;
}

+ (instancetype)QRCodeWithString:(NSString *)string size:(CGFloat)size
{
    //创建过滤器
    CIFilter *filter        = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    //过滤器恢复默认
    [filter setDefaults];
    //给过滤器添加数据<字符串长度893>
    NSData *data            = [string dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    [filter setValue:data forKey:@"inputMessage"];
    //获取二维码过滤器生成二维码
    CIImage *ciimage        = [filter outputImage];
    
    //创建bitmap
    CGRect extent           = CGRectIntegral(ciimage.extent);
    CGColorSpaceRef cs      = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef  = CGBitmapContextCreate(nil, extent.size.width, extent.size.height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context      = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage  = [context createCGImage:ciimage fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    //保存图像
    CGImageRef cgimage      = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    NSImage *qrCodeImage    = [[NSImage alloc] initWithCGImage:cgimage size:NSMakeSize(extent.size.width, extent.size.height)];
    
    //生成高清图像
    CGFloat scale           = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    size_t width            = CGRectGetWidth(extent)*scale;
    size_t height           = CGRectGetHeight(extent)*scale;
    NSImage *scaledImage    =
    [NSImage imageWithSize:CGSizeMake(width, height) flipped:NO drawingHandler:^BOOL(NSRect dstRect) {
        
        CGContextRef ctx    = [NSGraphicsContext currentContext].CGContext;
        CGContextSetInterpolationQuality(ctx, kCGInterpolationNone);
        CGContextScaleCTM(ctx, scale, scale);
        [qrCodeImage drawInRect:extent];
        return YES;
    }];
    return scaledImage;
}

#pragma mark - 转换为JPEG数据
NSData * KKImageJPEGRepresentation(NSImage * image, CGFloat compressionQuality)
{
    if (image.isValid == NO) {
        return nil;
    }
    /*
     需要先调用 TIFFRepresentation，否则会报错误:
     ImageIO: finalize:2135: image destination must have at least one image
     CGImageDestinationFinalize failed for output type 'public.png'
     */
    NSData *imageData = [image TIFFRepresentation];
    
    NSBitmapImageRep *imageRep =
    [NSBitmapImageRep imageRepWithData:imageData];
    
    // 属性
    NSMutableDictionary *properties =
    [NSMutableDictionary dictionary];
    
    // 压缩率 0.0(Max) ~ 1.0(None) 仅JPEG可用
    NSNumber *compressionFactor = [NSNumber numberWithFloat:0.5];
    
    [properties setObject:compressionFactor
                   forKey:NSImageCompressionFactor];
    
    // 转为位图数据
    NSData *bitmapData =
    [imageRep representationUsingType:NSBitmapImageFileTypeJPEG
                           properties:properties];
    
    return bitmapData;
}

#pragma mark 转换为PNG数据
NSData * KKImagePNGRepresentation(NSImage * image)
{
    if (image.isValid == NO) {
        return nil;
    }
    
    NSData *imageData = [image TIFFRepresentation];
    
    NSBitmapImageRep *imageRep =
    [NSBitmapImageRep imageRepWithData:imageData];
    
    // 转为位图数据
    NSData *bitmapData =
    [imageRep representationUsingType:NSBitmapImageFileTypePNG
                           properties:@{}];
    
    return bitmapData;
}

@end

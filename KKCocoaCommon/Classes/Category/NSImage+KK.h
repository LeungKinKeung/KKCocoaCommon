//
//  NSImage+KK.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSImage (KK)

/// CGImage
@property (nonatomic, readonly) CGImageRef CGImage;
/// 实际大小
@property (nonatomic, readonly) CGSize CGImageSize;
/// 可不变形拉伸
@property (nonatomic, readwrite, getter=isResizable) BOOL resizable;

/// 生成图像
/// @param size 大小
/// @param retina 是否缩放
/// @param drawingHandler 绘制（scale：如果retina为YES，就返回当前的屏幕缩放系数）
+ (instancetype)imageWithSize:(NSSize)size retina:(BOOL)retina drawingHandler:(void (^)(CGContextRef context, CGFloat scale, CGRect dstRect))drawingHandler;

/// 缩放图像
+ (instancetype)imageWithImage:(NSImage *)image size:(CGSize)size;

/// 渐变图像
+ (instancetype)imageWithGradientColors:(NSArray <NSColor *>*)colors size:(CGSize)size cornerRadius:(CGFloat)cornerRadius;

/// 渐变边框图像
+ (instancetype)imageWithBorderGradientColors:(NSArray <NSColor *>*)colors backgroundColor:(nullable NSColor *)backgroundColor size:(CGSize)size borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius;

/// 边框图像
+ (instancetype)imageWithBackgroundColor:(NSColor *)backgroundColor borderColor:(NSColor *)borderColor size:(CGSize)size borderWidth:(CGFloat)borderWidth cornerRadius:(CGFloat)cornerRadius;

/// 二维码图像
+ (instancetype)QRCodeWithString:(NSString *)string size:(CGFloat)size;

/// 转换为JPEG数据
/// @param image 图像
/// @param compressionQuality 压缩率:0.0(Max) ~ 1.0(None)
OBJC_EXTERN NSData * KKImageJPEGRepresentation(NSImage * image, CGFloat compressionQuality);

/// 转换为PNG数据
OBJC_EXTERN NSData * KKImagePNGRepresentation(NSImage * image);

@end

NS_ASSUME_NONNULL_END

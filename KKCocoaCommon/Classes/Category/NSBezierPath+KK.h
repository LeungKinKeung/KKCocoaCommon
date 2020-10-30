//
//  NSBezierPath+KK.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSUInteger, KKRectCorner) {
    KKRectCornerTopLeft     = 1 << 0,
    KKRectCornerTopRight    = 1 << 1,
    KKRectCornerBottomLeft  = 1 << 2,
    KKRectCornerBottomRight = 1 << 3,
    KKRectCornerAllCorners  = ~0UL
};

@interface NSBezierPath (KK)

/// 此对象需要手动 CGPathRelease()
@property (nonatomic, readonly) CGPathRef CGPath;

/// 生成圆角的路径
+ (NSBezierPath *)bezierPathWithRoundedRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;

/// 生成指定圆角的路径
/// @param rect 要圆角的矩阵
/// @param corners 圆角
/// @param cornerRadii 半径
/// @param viewIsFlipped macOS坐标起点为左下角，iOS为左上角，一般填入NSView实例的isFlipped值
/// @param viewBounds 翻转坐标系的参照矩阵，假如viewIsFlipped为YES就传空
+ (NSBezierPath *)bezierPathWithRoundedRect:(CGRect)rect byRoundingCorners:(KKRectCorner)corners cornerRadii:(CGSize)cornerRadii viewIsFlipped:(BOOL)viewIsFlipped viewBounds:(CGRect)viewBounds;

/// 生成指定圆角的路径，NSView实例的isFlipped为NO且坐标为{0,0}时可用
+ (NSBezierPath *)bezierPathWithRoundedRect:(CGRect)rect byRoundingCorners:(KKRectCorner)corners cornerRadii:(CGSize)cornerRadii;

/// 添加线
- (void)addLineToPoint:(CGPoint)point;

/// 在里面使用CGPathRef，自动调用CGPathRelease()
- (void)CGPathBlock:(void(^)(CGPathRef CGPath))block;

@end

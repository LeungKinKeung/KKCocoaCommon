//
//  KKGuideView.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSUInteger, KKGuideViewShapeStyle) {
    KKGuideViewShapeStyleDefault,
    KKGuideViewShapeStyleCasual,
    KKGuideViewShapeStyleOval,
};

typedef NS_ENUM(NSUInteger, KKGuideViewLineCurveStyle) {
    KKGuideViewLineCurveStyleDefault,
    KKGuideViewLineCurveStyleCasual,
};

typedef NS_ENUM(NSUInteger, KKGuideViewLineFillStyle) {
    KKGuideViewLineFillStyleNone,
    KKGuideViewLineFillStyleDotted,
    KKGuideViewLineFillStyleSolid,
};

@interface KKGuideView : NSView

typedef void(^KKGuideViewCompletionBlock)(KKGuideView *guideView);

+ (instancetype)showGuideViewAddedTo:(NSView *)superview
                          targetView:(NSView *)targetView
                                tips:(NSString *)tips
                          completion:(KKGuideViewCompletionBlock)completion;

/// 需要指引的视图
@property (nonatomic, weak) NSView *targetView;
/// 提示文本标签
@property (nonatomic, strong) NSTextField *tipsLabel;
/// 自定义提示视图
@property (nonatomic, strong) NSView *customTipsView;
/// 高亮区域的样式
@property (nonatomic, assign) KKGuideViewShapeStyle highlightShapeStyle;
/// 高亮区域边框线填充样式
@property (nonatomic, assign) KKGuideViewLineFillStyle highlightBorderLineFillStyle;
/// 高亮区域内边距
@property (nonatomic, assign) NSEdgeInsets highlightPadding;
/// 高亮区域边框线边距
@property (nonatomic, assign) CGFloat highlightMargin;
/// 高亮区域圆角
@property (nonatomic, assign) CGFloat highlightCornerRadius;
/// 提示视图的边框形状样式
@property (nonatomic, assign) KKGuideViewShapeStyle tipsBorderShapeStyle;
/// 提示视图的边框线条填充样式
@property (nonatomic, assign) KKGuideViewLineFillStyle tipsBorderLineFillStyle;
/// 提示视图的边框内边距
@property (nonatomic, assign) NSEdgeInsets tipsBorderPadding;
/// 提示视图的边框圆角
@property (nonatomic, assign) CGFloat tipsBorderCornerRadius;
/// 引导线条填充样式
@property (nonatomic, assign) KKGuideViewLineFillStyle leadingLineFillStyle;
/// 引导线条曲线样式
@property (nonatomic, assign) KKGuideViewLineCurveStyle leadingLineCurveStyle;
/// 引导线条宽度
@property (nonatomic, assign) CGFloat leadingLineWidth;
/// tipsLabel/customTipsView相对于targetView的中心偏移值
@property (nonatomic, assign) CGPoint tipsViewCenterOffset;
/// 边框线条宽度
@property (nonatomic, assign) CGFloat borderLineWidth;
/// 内边距
@property (nonatomic, assign) CGFloat padding;
/// 线条、文本、边框着色，默认白色
@property (nonatomic, strong) NSColor *tintColor;
/// 背景色，默认0.7黑色
@property (nonatomic, strong) NSColor *backgroundColor;
/// 点击时移除此视图
@property (nonatomic, assign) BOOL removeFromSuperviewOnClick;
/// 点击了此视图，假如completionBlock == nil且removeFromSuperviewOnClick == NO，将不进行任何操作
@property (nonatomic, copy) KKGuideViewCompletionBlock completionBlock;
/// 刷新
- (void)refresh;

@end

typedef NS_ENUM(NSUInteger, KKViewPosition) {
    KKViewPositionOverlaps,
    KKViewPositionCenter = KKViewPositionOverlaps,
    KKViewPositionLeft,
    KKViewPositionTopLeft,
    KKViewPositionAbove,
    KKViewPositionTop = KKViewPositionAbove,
    KKViewPositionTopRigth,
    KKViewPositionRigth,
    KKViewPositionBottomRigth,
    KKViewPositionBelow,
    KKViewPositionBottom = KKViewPositionBelow,
    KKViewPositionBottomLeft,
};

@interface NSView (KKPosition)

+ (KKViewPosition)positionForView:(NSView *)view relativeToView:(NSView *)relativeView;

@end

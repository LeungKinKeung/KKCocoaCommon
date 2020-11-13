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

typedef NS_ENUM(NSUInteger, KKGuideViewLineStyle) {
    KKGuideViewLineStyleNone,
    KKGuideViewLineStyleDotted,
    KKGuideViewLineStyleSolid,
};

@interface KKGuideView : NSView

typedef void(^KKGuideViewCompletionBlock)(KKGuideView *guideView);

+ (instancetype)showGuideViewAddedTo:(NSView *)superview targetView:(NSView *)targetView tips:(NSString *)tips completion:(KKGuideViewCompletionBlock)completion;

/// 需要指引的视图
@property (nonatomic, weak) NSView *targetView;
/// 提示文本标签
@property (nonatomic, strong) NSTextField *tipsLabel;
/// 自定义提示视图
@property (nonatomic, strong) NSView *customTipsView;
/// 高亮区域的样式
@property (nonatomic, assign) KKGuideViewShapeStyle highlightShapeStyle;
/// 高亮区域边距
@property (nonatomic, assign) NSEdgeInsets highlightMargin;
/// 高亮区域圆角
@property (nonatomic, assign) CGFloat highlightCornerRadius;
/// 提示视图的边框形状样式
@property (nonatomic, assign) KKGuideViewShapeStyle tipsBorderShapeStyle;
/// 提示视图的边框线条样式
@property (nonatomic, assign) KKGuideViewLineStyle tipsBorderLineStyle;
/// 提示视图的边框边距
@property (nonatomic, assign) NSEdgeInsets tipsBorderMargin;
/// 提示视图的边框圆角
@property (nonatomic, assign) CGFloat tipsBorderCornerRadius;
/// 连接的线条样式
@property (nonatomic, assign) KKGuideViewLineStyle lineStyle;
/// 线条头部和尾部的偏移值
@property (nonatomic, assign) CGPoint lineOffset;
/// 线条宽度
@property (nonatomic, assign) CGFloat lineWidth;
/// 背景色，默认0.7黑色
@property (nonatomic, strong) NSColor *backgroundColor;
/// 点击时移除此视图
@property (nonatomic, assign) BOOL removeFromSuperviewOnClick;
/// 完成
@property (nonatomic, copy) KKGuideViewCompletionBlock completionBlock;
/// 刷新
- (void)refresh;

@end

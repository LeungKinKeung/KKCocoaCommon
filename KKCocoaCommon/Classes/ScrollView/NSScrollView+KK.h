//
//  NSScrollView+KK.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSScrollView (KK)

/// 向上滚动
- (void)scrollUp:(CGFloat)value animated:(BOOL)animated;
/// 向下滚动
- (void)scrollLow:(CGFloat)value animated:(BOOL)animated;
/// 滚动到顶部
- (void)scrollToTopUsingAnimation:(BOOL)animated;
/// 滚动到底部
- (void)scrollToBottomUsingAnimation:(BOOL)animated;
/// 调整垂直滚动条
- (void)adjustVerticalScroller;
/// 调整视图位置
- (void)adjustsContentViewBounds;

@end

NS_ASSUME_NONNULL_END

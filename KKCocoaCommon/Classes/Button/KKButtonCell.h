//
//  KKButtonCell.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/11/16.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface KKButtonCell : NSButtonCell

/// 内边距
@property (nonatomic, assign) NSEdgeInsets padding;
/// 间隔
@property (nonatomic, assign) CGFloat interitemSpacing;
/// 图片和标题的间隔
@property (nonatomic, readwrite) CGFloat spacingBetweenImageAndTitle;

@end

NS_ASSUME_NONNULL_END

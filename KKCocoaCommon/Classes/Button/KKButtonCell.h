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

/// 边距
@property (nonatomic, assign) NSEdgeInsets margin;
/// 间隔
@property (nonatomic, assign) CGFloat interitemSpacing;

@end

NS_ASSUME_NONNULL_END

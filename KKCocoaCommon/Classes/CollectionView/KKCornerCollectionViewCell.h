//
//  KKCornerCollectionViewCell.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSUInteger, KKCornerCollectionViewCellCorner) {
    KKCornerCollectionViewCellCornerNone,
    KKCornerCollectionViewCellCornerTop,
    KKCornerCollectionViewCellCornerMiddle,
    KKCornerCollectionViewCellCornerBottom,
    KKCornerCollectionViewCellCornerAll,
};

API_AVAILABLE(macos(10.11))
@interface KKCornerCollectionViewCell : NSCollectionViewItem

/// 圆角的位置
@property (nonatomic, assign) KKCornerCollectionViewCellCorner corner;

/// 圆角半径
@property (nonatomic, assign) CGFloat cornerRadius;

/// 边框颜色
@property (nonatomic, strong) NSColor *borderColor;

/// 边框粗细
@property (nonatomic, assign) CGFloat borderLineWidth;

/// 分隔线边距，默认{0, 14, 0, 14}
@property (nonatomic, assign) NSEdgeInsets separatorInset;

/// 裁剪圆角，一般在CollectionView背景为透明色时设为YES
@property (nonatomic, assign) BOOL masksToCorners;

/// 自动设置圆角
/// @param collectionView 所在的UICollectionView
/// @param indexPath 当前的indexPath
- (void)setCornersWithCollectionView:(NSCollectionView *)collectionView indexPath:(NSIndexPath *)indexPath;

@end

//
//  KKTextCollectionViewCell.h
//  KKCocoaCommon
//
//  Created by leungkinkeung on 2020/11/1.
//

#import <KKCocoaCommon/KKCocoaCommon.h>

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(macos(10.11))
@interface KKTextCollectionViewCell : KKCornerCollectionViewCell

@property (nonatomic, strong) NSTextField *titleLabel;
@property (nonatomic, strong) NSImageView *accessoryImageView;

@end

NS_ASSUME_NONNULL_END

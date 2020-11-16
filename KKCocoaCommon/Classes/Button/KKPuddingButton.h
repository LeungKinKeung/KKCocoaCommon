//
//  KKPuddingButton.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/11/16.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface KKPuddingButton : NSButton

/// 边距
@property (nonatomic, assign) NSEdgeInsets margin;
/// 图片和标题的上下/左右间隔，默认：7
@property (nonatomic, assign) CGFloat interitemSpacing;

@end

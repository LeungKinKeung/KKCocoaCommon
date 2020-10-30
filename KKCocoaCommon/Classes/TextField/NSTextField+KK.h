//
//  NSTextField+KK.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTextField (KK)

/// 文本
@property (readwrite , nonatomic) NSString *text;
/// 对齐
@property (readwrite , nonatomic) NSTextAlignment textAlignment;

/// 创建标签
+ (instancetype)label;

@end

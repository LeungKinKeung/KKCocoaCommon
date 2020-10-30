//
//  NSTextView+KK.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTextView (KK)

/// 文本
@property (readwrite , nonatomic) NSString *text;

/// 创建文本视图
+ (instancetype)textView;

@end

NS_ASSUME_NONNULL_END

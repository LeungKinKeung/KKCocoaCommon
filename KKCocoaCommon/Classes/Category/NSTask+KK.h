//
//  NSTask+KK.h
//  KKCocoaCommon
//
//  Created by v_ljqliang on 2020/11/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTask (KK)

+ (NSString *)runCommand:(NSString *)command;

@end

NS_ASSUME_NONNULL_END

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

+ (void)runCommand:(NSString *)command completion:(void(^)(NSString *result, NSString *error))completion;

+ (void)excuteTaskPath:(NSString *)path argvs:(NSArray *)argvs completion:(void(^)(NSString *result, NSString *error))completion;

@end

NS_ASSUME_NONNULL_END

//
//  KKDisplayLink.h
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef void(^KKDisplayLinkBlock)(void);

@interface KKDisplayLink : NSObject
{
    @protected
    NSTimeInterval _frameSecondInterval;
    int64_t _lastVideoTime;
    CVDisplayLinkRef _displayLink;
    dispatch_queue_t _callbackQueue;
}

/// 创建定时器
/// @param fps 每秒帧数
/// @param callbackQueue 回调队列
/// @param block 回调Block
+ (instancetype)displayLinkWithFramesPerSecond:(NSInteger)fps callbackQueue:(dispatch_queue_t)callbackQueue block:(KKDisplayLinkBlock)block;

/// 创建定时器，主线程回调
+ (instancetype)displayLinkWithFramesPerSecond:(NSInteger)fps block:(KKDisplayLinkBlock)block;

/// 启动
- (BOOL)start;
/// 暂停
- (BOOL)stop;

/// 刷新率：一般默认60hz、120hz，设为0就是不限制刷新率（跟随系统屏幕刷新率）
@property (nonatomic, assign) NSInteger framesPerSecond;
/// 运行中
@property (nonatomic, readonly) BOOL isRunning;
/// 回调
@property (nonatomic, copy) KKDisplayLinkBlock block;


@end

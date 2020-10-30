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
}

/// 创建定时器，主线程回调（其他线程回调很多BUG）
/// @param fps 每秒帧数(FPS)
/// @param block 回调
+ (instancetype)displayLinkWithFPS:(NSInteger)fps
                             block:(KKDisplayLinkBlock)block;

/// 启动
- (void)start;
/// 暂停
- (void)stop;

/// Frames Per Second：一般默认60hz、120hz，设为0就是不限制刷新率（跟随系统屏幕刷新率）
@property (nonatomic) NSInteger fps;
/// 运行中
@property (nonatomic, readonly) BOOL isRunning;
/// 回调
@property (nonatomic, copy) KKDisplayLinkBlock block;


@end

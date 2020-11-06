//
//  KKDisplayLink.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKDisplayLink.h"

@implementation KKDisplayLink

+ (instancetype)displayLinkWithFPS:(NSInteger)fps block:(KKDisplayLinkBlock)block
{
    if (block == nil) {
        NSLog(@"%@ create failed: block == nil",NSStringFromClass([self class]));
        return nil;
    }
    CGDirectDisplayID displayID     = CGMainDisplayID();
    CVDisplayLinkRef displayLink    = NULL;
    CVReturn result                 =
    CVDisplayLinkCreateWithCGDisplay(displayID, &displayLink);
    
    if (result != kCVReturnSuccess) {
        NSLog(@"Error:CVDisplayLinkCreateWithCGDisplay() Failed");
        return nil;
    }
    
    KKDisplayLink *link = [self new];
    link.block          = block;
    link.fps            = fps;
    
    result              =
    CVDisplayLinkSetOutputCallback(displayLink, renderCallback, (__bridge void *)link);
    
    if (result != kCVReturnSuccess) {
        NSLog(@"Error:CVDisplayLinkSetOutputCallback() Failed");
        return nil;
    }
    link->_displayLink = displayLink;
    
    return link;
}

static CVReturn renderCallback(CVDisplayLinkRef displayLink,
                               const CVTimeStamp *inNow,
                               const CVTimeStamp *inOutputTime,
                               CVOptionFlags flagsIn,
                               CVOptionFlags *flagsOut,
                               void *displayLinkContext)
{
    KKDisplayLink *context = (__bridge KKDisplayLink *)displayLinkContext;
    
    [context renderWithVideoTime:inNow->videoTime
                  videoTimeScale:inNow->videoTimeScale];
    
    return kCVReturnSuccess;
}

- (void)renderWithVideoTime:(int64_t)videoTime
             videoTimeScale:(int32_t)videoTimeScale
{
    // next videoTime - videoTime = 5481920
    // 间隔 (next videoTime - videoTime) / videoTimeScale = (1/60)
    // 间隔 5481920 / 328920000 = 0.016666423446431 (1/60)
    
    NSTimeInterval secondInterval = (double)(videoTime - _lastVideoTime) / videoTimeScale;
    if (secondInterval >= _frameSecondInterval) {
        _lastVideoTime = videoTime;
    } else {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isRunning && self.block) {
            self.block();
        }
    });
}

- (void)setFps:(NSInteger)fps
{
    _fps = MAX(fps, 0);
    _frameSecondInterval = (1.0 / _fps);
}

- (void)start
{
    if (_displayLink) {
        NSLog(@"Start %@ result:%d",NSStringFromClass([self class]),CVDisplayLinkStart(_displayLink));
    }
}

- (void)stop
{
    if (_displayLink && CVDisplayLinkIsRunning(_displayLink)) {
        NSLog(@"Stop %@ result:%d",NSStringFromClass([self class]),CVDisplayLinkStop(_displayLink));
    }
}

- (BOOL)isRunning
{
    return CVDisplayLinkIsRunning(_displayLink);
}

- (void)dealloc
{
    [self stop];
    NSLog(@"%@ dealloc",NSStringFromClass([self class]));
}

@end

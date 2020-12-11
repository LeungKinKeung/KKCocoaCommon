//
//  KKDisplayLink.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKDisplayLink.h"

@implementation KKDisplayLink

+ (instancetype)displayLinkWithFramesPerSecond:(NSInteger)fps callbackQueue:(dispatch_queue_t)callbackQueue block:(KKDisplayLinkBlock)block
{
    if (block == nil) {
        NSLog(@"%@ create failed: block can not be nil",NSStringFromClass([self class]));
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
    
    KKDisplayLink *link     = [self new];
    link.block              = block;
    link.framesPerSecond    = fps;
    link->_callbackQueue    = callbackQueue;
    
    result = CVDisplayLinkSetOutputCallback(displayLink, rendererOutputCallback, (__bridge void *)link);
    
    if (result != kCVReturnSuccess) {
        NSLog(@"Error:CVDisplayLinkSetOutputCallback() Failed");
        return nil;
    }
    link->_displayLink = displayLink;
    
    return link;
}

+ (instancetype)displayLinkWithFramesPerSecond:(NSInteger)fps block:(KKDisplayLinkBlock)block
{
    return [self displayLinkWithFramesPerSecond:fps callbackQueue:NULL block:block];
}

static CVReturn rendererOutputCallback(CVDisplayLinkRef displayLink,
                                       const CVTimeStamp *inNow,
                                       const CVTimeStamp *inOutputTime,
                                       CVOptionFlags flagsIn,
                                       CVOptionFlags *flagsOut,
                                       void *displayLinkContext)
{
    KKDisplayLink *context = (__bridge KKDisplayLink *)displayLinkContext;
    
    [context rendererOutputCallbackWithVideoTime:inNow->videoTime
                                  videoTimeScale:inNow->videoTimeScale];
    
    return kCVReturnSuccess;
}

- (void)rendererOutputCallbackWithVideoTime:(int64_t)videoTime
                             videoTimeScale:(int32_t)videoTimeScale
{
    NSTimeInterval secondInterval = (double)(videoTime - _lastVideoTime) / videoTimeScale;
    if (secondInterval >= _frameSecondInterval) {
        _lastVideoTime = videoTime;
    } else {
        return;
    }
    dispatch_queue_t queue = _callbackQueue ? _callbackQueue : dispatch_get_main_queue();
    dispatch_async(queue, ^{
        if (self.isRunning && self.block) {
            self.block();
        }
    });
}

- (void)setFramesPerSecond:(NSInteger)framesPerSecond
{
    _framesPerSecond = MAX(framesPerSecond, 0);
    _frameSecondInterval = (1.0 / _framesPerSecond);
}

- (BOOL)start
{
    if (_displayLink) {
        BOOL succeeded = CVDisplayLinkStart(_displayLink) == kCVReturnSuccess;
        //NSLog(@"Start %@ succeeded:%d",NSStringFromClass([self class]),succeeded);
        return succeeded;
    }
    return NO;
}

- (BOOL)stop
{
    if (_displayLink && CVDisplayLinkIsRunning(_displayLink)) {
        BOOL succeeded = CVDisplayLinkStop(_displayLink) == kCVReturnSuccess;
        //NSLog(@"Stop %@ succeeded:%d",NSStringFromClass([self class]),succeeded);
        if (succeeded) {
            _callbackQueue  = NULL;
            _displayLink    = NULL;
        }
        return succeeded;
    }
    return YES;
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

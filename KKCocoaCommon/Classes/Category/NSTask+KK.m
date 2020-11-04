//
//  NSTask+KK.m
//  KKCocoaCommon
//
//  Created by v_ljqliang on 2020/11/3.
//

#import "NSTask+KK.h"

@implementation NSTask (KK)

+ (NSString *)runCommand:(NSString *)command
{
    NSMutableArray *components = [[command componentsSeparatedByString:@" "] mutableCopy];
    
    if (components.count == 0) {
        return nil;
    }
    NSString *launchPath    = nil;
    NSString *path          = components.firstObject;
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        launchPath          = path;
    } else {
        NSArray *directorys = @[@"/usr/bin",@"/usr/sbin",@"bin",@"sbin"];
        for (NSString *directory in directorys) {
            NSString *filePath  = [directory stringByAppendingPathComponent:path];
            if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                launchPath      = filePath;
                break;
            }
        }
    }
    if (launchPath == nil) {
        launchPath          = path;
    }
    
    [components removeObjectAtIndex:0];
    
    // 初始化并设置shell路径
    NSTask *task = [[NSTask alloc] init];
    if (@available(macOS 10.13, *)) {
        [task setExecutableURL:[NSURL fileURLWithPath:launchPath]];
    } else {
        [task setLaunchPath:launchPath];
    }
    [task setArguments:components];
    
    // 新建输出管道作为Task的输出
    NSPipe *pipe = [NSPipe pipe];
    [task setStandardOutput:pipe];

    // 开始task
    NSFileHandle *file = [pipe fileHandleForReading];
    
    if (@available(macOS 10.13, *)) {
        NSError *error = nil;
        [task launchAndReturnError:&error];
        if (error) {
            NSLog(@"Run command error:%@",error);
            return error.localizedDescription;
        }
    } else {
        [task launch];
    }
    
    // 获取运行结果
    NSData *data        = [file readDataToEndOfFile];
    NSString *result    = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    return result;
}

@end

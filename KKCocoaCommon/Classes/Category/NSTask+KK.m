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
    NSFileHandle *outputHandle = [pipe fileHandleForReading];
    
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
    NSData *data        = [outputHandle readDataToEndOfFile];
    NSString *result    = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [outputHandle closeFile];
    
    return result;
}

+ (void)runCommand:(NSString *)command completion:(void(^)(NSString *result, NSString *error))completion
{
    NSMutableArray *components = [[command componentsSeparatedByString:@" "] mutableCopy];
    
    if (components.count == 0) {
        if (completion) {
            completion(nil, nil);
        }
        return;
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
    
    [self excuteTaskPath:launchPath argvs:components completion:completion];
}

+ (void)excuteTaskPath:(NSString *)path argvs:(NSArray *)argvs completion:(void(^)(NSString *result, NSString *error))completion
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        if (completion) {
             completion(nil, nil);
        }
        return;
    }
    NSString *outString;
    NSString *errorString;
    NSError *error;
    NSTask *task        = [[NSTask alloc] init];
    task.arguments      = argvs;
    NSPipe *outputPipe  = [[NSPipe alloc] init];
    NSPipe *errorPipe   = [[NSPipe alloc] init];
    [task setStandardError:errorPipe];
    [task setStandardOutput:outputPipe];
    [task waitUntilExit];
    
    if (@available(macOS 10.13, *)) {
        task.executableURL = [NSURL fileURLWithPath:path];
        [task launchAndReturnError:&error];
    } else {
        task.launchPath = path;
        [task launch];
    }
    
    NSFileHandle *outputHandle  = [outputPipe fileHandleForReading];
    NSFileHandle *errorHandle   = [errorPipe fileHandleForReading];
    NSData *outData             = [outputHandle readDataToEndOfFile];
    NSData *errorData           = [errorHandle readDataToEndOfFile];
    
    if (outData && outData.length > 0 ) {
        outString = [[NSString alloc] initWithData:outData encoding:NSUTF8StringEncoding];
    }
    if(errorData && errorData.length > 0) {
        errorString = [[NSString alloc] initWithData:errorData encoding:NSUTF8StringEncoding];
    }
    
    [outputHandle closeFile];
    [errorHandle closeFile];
    outputHandle    = nil;
    errorHandle     = nil;
    
    if (completion) {
        completion(outString, errorString);
    }
}

@end

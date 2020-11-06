//
//  NSIndexPath+KK.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "NSIndexPath+KK.h"

@implementation NSIndexPath (KK)

@dynamic section,row;

+ (instancetype)indexPathForRow:(NSInteger)row inSection:(NSInteger)section
{
    NSUInteger i[] = {section, row};
    return [NSIndexPath indexPathWithIndexes:i length:2];
}

- (NSInteger)section
{
    return [self indexAtPosition:0];
}

- (NSInteger)row
{
    return [self indexAtPosition:1];
}


@end

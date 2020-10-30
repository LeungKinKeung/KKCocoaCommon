//
//  KKCollectionViewCell.m
//  KKCocoaCommon
//
//  Created by LeungKinKeung on 2020/10/29.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKCollectionViewCell.h"

@interface KKCollectionViewCell ()

@end

@implementation KKCollectionViewCell

- (void)loadView
{
    if ([[NSBundle mainBundle] loadNibNamed:[self className] owner:nil topLevelObjects:nil]) {
        [super loadView];
    } else {
        self.view = [NSView new];
    }
}

@end

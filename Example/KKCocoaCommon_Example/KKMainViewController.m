//
//  KKMainViewController.m
//  KKCocoaCommon_Example
//
//  Created by leungkinkeung on 2020/11/1.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKMainViewController.h"

@interface KKMainViewController ()<NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSScrollView *scrollView;
@property (nonatomic, strong) NSCollectionView *collectionView;

@end

@implementation KKMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.layerBackgroundColor = NSColor.clearColor;
    __weak typeof(self) weakSelf = self;
    [self appearanceBlock:^(BOOL isLight) {
        NSArray *colors =
        isLight ?
        @[[NSColor colorWithWhite:1 alpha:1],[NSColor colorWithWhite:0.85 alpha:1]] :
        @[[NSColor colorWithWhite:0.2 alpha:1],[NSColor colorWithWhite:0 alpha:1]];
        [weakSelf setGradientLayerColors:colors];
    }];
    
    {
        NSCollectionView *view      = [NSCollectionView new];
        view.delegate               = self;
        view.dataSource             = self;
        view.selectable             = YES;
        view.backgroundColors       = @[NSColor.clearColor];
        view.collectionViewLayout   = [NSCollectionViewFlowLayout new];
        self.collectionView         = view;
        [view registerClass:[KKTextCollectionViewCell class] forItemWithIdentifier:@"KKTextCollectionViewCell"];
    }
    {
        NSScrollView *view      = [NSScrollView new];
        view.documentView       = self.collectionView;
        view.focusRingType      = NSFocusRingTypeNone;
        view.borderType         = NSNoBorder;
        view.backgroundColor    = NSColor.clearColor;
        view.drawsBackground    = NO;
        view.appearance         = [NSAppearance appearanceNamed:NSAppearanceNameVibrantLight];
        view.scrollerStyle      = NSScrollerStyleOverlay;
        self.scrollView         = view;
        [self.view addSubview:view];
        view.frame              = self.view.bounds;
        view.autoresizingMask   = NSViewHeightSizable | NSViewWidthSizable;
    }
}

- (void)viewDidLayout
{
    [super viewDidLayout];
    
    self.scrollView.frame =
    CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - 50);
}

#pragma mark - NSCollectionViewDataSource
- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 10;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    KKTextCollectionViewCell *cell = [collectionView makeItemWithIdentifier:@"KKTextCollectionViewCell" forIndexPath:indexPath];
    
    cell.titleLabel.text = [NSString stringWithFormat:@"Item:%ld",(long)indexPath.item];
    
    [cell setCornersWithCollectionView:collectionView indexPath:indexPath];
    
    return cell;
}

#pragma mark NSCollectionViewDelegate
- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
    
}

#pragma mark NSCollectionViewDelegate
- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(collectionView.bounds.size.width - 10 * 2, 80);;
}

- (CGFloat)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

@end

//
//  KKCollectionViewController.m
//  KKCocoaCommon_Example
//
//  Created by LeungKinKeung on 2020/12/14.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKCollectionViewController.h"
#import <KKCocoaCommon/KKCocoaCommon.h>

@interface KKCollectionViewController ()<NSCollectionViewDelegate, NSCollectionViewDataSource, NSCollectionViewDelegateFlowLayout, NSSplitViewDelegate>

@property (weak) IBOutlet NSSplitView *splitView;
@property (nonatomic, strong) NSScrollView *scrollView;
@property (nonatomic, strong) NSCollectionView *collectionView;
@property (weak) IBOutlet NSTextField *cornerRadiusTextField;
@property (weak) IBOutlet NSTextField *borderLineWidthTextField;
@property (weak) IBOutlet NSTextField *separatorInsetLeftTextField;
@property (weak) IBOutlet NSTextField *separatorInsetRightTextField;
@property (weak) IBOutlet NSColorWell *borderColorWell;
@property (weak) IBOutlet NSButton *masksToCornersButton;

@end

@implementation KKCollectionViewController

- (NSString *)title
{
    return @"Collection View";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.splitView setPosition:300 ofDividerAtIndex:0];
    self.splitView.delegate = self;
    
    NSView *parentView = [self.splitView.arrangedSubviews objectAtIndex:1];
    {
        NSScrollView *view      = [[NSScrollView alloc] initWithFrame:parentView.bounds];
        view.focusRingType      = NSFocusRingTypeNone;
        view.borderType         = NSNoBorder;
        view.backgroundColor    = NSColor.clearColor;
        view.drawsBackground    = NO;
        view.scrollerStyle      = NSScrollerStyleOverlay;
        view.autohidesScrollers = YES;
        view.automaticallyAdjustsContentInsets = NO;
        view.contentInsets      = NSEdgeInsetsMake(15, 0, 15, 0);
        self.scrollView         = view;
        [parentView addSubview:view];
        view.autoresizingMask   = NSViewWidthSizable | NSViewHeightSizable;
    }
    {
        NSCollectionView *view      = [NSCollectionView new];
        view.delegate               = self;
        view.dataSource             = self;
        view.selectable             = YES;
        view.backgroundColors       = @[NSColor.clearColor];
        view.collectionViewLayout   = [NSCollectionViewFlowLayout new];
        self.collectionView         = view;
        [view registerClass:[KKTextCollectionViewCell class] forItemWithIdentifier:[KKTextCollectionViewCell className]];
        
        self.scrollView.documentView = view;
    }
}

- (void)splitViewDidResizeSubviews:(NSNotification *)notification
{
    [self.collectionView.collectionViewLayout invalidateLayout];
}

#pragma mark - NSCollectionViewDataSource
- (NSInteger)collectionView:(NSCollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 20;
}

- (NSCollectionViewItem *)collectionView:(NSCollectionView *)collectionView itemForRepresentedObjectAtIndexPath:(NSIndexPath *)indexPath
{
    KKTextCollectionViewCell *cell =
    [collectionView makeItemWithIdentifier:[KKTextCollectionViewCell className] forIndexPath:indexPath];
    
    cell.titleLabel.text = [NSString stringWithFormat:@"Item:%ld",indexPath.item];
    
    [cell setCornersWithCollectionView:collectionView indexPath:indexPath];
    
    cell.masksToCorners  = self.masksToCornersButton.isOnState;
    cell.cornerRadius    = self.cornerRadiusTextField.stringValue.doubleValue;
    cell.borderColor     = self.borderColorWell.color;
    cell.borderLineWidth = self.borderLineWidthTextField.stringValue.doubleValue;
    cell.separatorInset  =
    NSEdgeInsetsMake(0, self.separatorInsetLeftTextField.stringValue.doubleValue,
                     0, self.separatorInsetRightTextField.stringValue.doubleValue);
    
    return cell;
}

#pragma mark NSCollectionViewDelegate
- (void)collectionView:(NSCollectionView *)collectionView didSelectItemsAtIndexPaths:(NSSet<NSIndexPath *> *)indexPaths
{
    
}

#pragma mark NSCollectionViewDelegate
- (NSSize)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //CGSize size = CGSizeMake(collectionView.bounds.size.width - 15 * 2, 50);
    CGSize size = CGSizeMake(self.scrollView.bounds.size.width - 15 * 2, 50);
    return size;
}

- (CGFloat)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout
    minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (CGFloat)collectionView:(NSCollectionView *)collectionView layout:(NSCollectionViewLayout*)collectionViewLayout
    minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (IBAction)apply:(id)sender {
    [self.collectionView reloadData];
}

@end

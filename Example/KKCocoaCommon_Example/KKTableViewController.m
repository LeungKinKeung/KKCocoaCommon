//
//  KKTableViewController.m
//  KKCocoaCommon_Example
//
//  Created by v_ljqliang on 2020/12/9.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKTableViewController.h"
#import <KKCocoaCommon/KKCocoaCommon.h>

@interface KKTableViewController ()<KKTableViewDelegate,KKTableViewDataSource>

@property (weak) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSSegmentedControl *tableViewStylePicker;
@property (weak) IBOutlet NSSegmentedControl *backgroundStylePicker;
@property (weak) IBOutlet NSSegmentedControl *selectionStylePicker;
@property (weak) IBOutlet NSTextField *insertSectionTextField;
@property (weak) IBOutlet NSTextField *insertRowTextField;
@property (weak) IBOutlet NSTextField *moveSrcSectionTextField;
@property (weak) IBOutlet NSTextField *moveSrcRowTextField;
@property (weak) IBOutlet NSTextField *moveDestSectionTextField;
@property (weak) IBOutlet NSTextField *moveDestRowTextField;
@property (weak) IBOutlet NSButton *allowsSelectionSwitch;
@property (weak) IBOutlet NSButton *allowsEmptySelectionSwitch;
@property (weak) IBOutlet NSButton *allowsMultipleSelectionSwitch;
@property (weak) IBOutlet NSButton *translucentSwitch;
@property (weak) IBOutlet NSButton *alwaysEmphasizedSelectionBackgroundSwitch;
@property (nonatomic, strong) NSMutableArray <NSMutableArray <NSString *>*>*datas;
@property (nonatomic, strong) NSMutableArray <NSString *>*headerTitles;
@property (nonatomic, strong) NSMutableArray <NSString *>*footerTitles;
@property (nonatomic, strong) KKTableView *tableView;

@end

@implementation KKTableViewController

- (NSString *)title
{
    return @"Table View";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.splitView setPosition:300 ofDividerAtIndex:0];
    
    self.datas = NSMutableArray.new;
    self.headerTitles = NSMutableArray.new;
    self.footerTitles = NSMutableArray.new;
    for (NSInteger section = 0; section < 3; section++) {
        NSInteger numberOfRows = section == 0 ? 2 : 3 ;// arc4random_uniform(10) + 10;
        NSMutableArray *strings = NSMutableArray.new;
        for (NSInteger row = 0; row < numberOfRows; row++) {
            [strings addObject:[NSString stringWithFormat:@"Title section:%ld row:%ld",section,row]];
        }
        [self.datas addObject:strings];
        [self.headerTitles addObject:[NSString stringWithFormat:@"HEADER:%ld",section]];
        [self.footerTitles addObject:[NSString stringWithFormat:@"footer:%ld",section]];
    }
    [self tableView];
}

- (KKTableView *)tableView
{
    if (_tableView == nil) {
        NSView *parentView = [self.splitView.arrangedSubviews objectAtIndex:1];
        _tableView  = [[KKTableView alloc] initWithFrame:parentView.bounds style:self.tableViewStylePicker.selectedSegment];
        _tableView.delegate     = self;
        _tableView.dataSource   = self;
        _tableView.translucent  = self.translucentSwitch.isOnState;
        //_tableView.solidBackgroundColor     = [NSColor whiteColor];
        _tableView.alwaysEmphasizedSelectionBackground  = self.alwaysEmphasizedSelectionBackgroundSwitch.isOnState;
        _tableView.allowsMultipleSelection  = self.allowsSelectionSwitch.isOnState;
        _tableView.allowsEmptySelection     = self.allowsEmptySelectionSwitch.isOnState;
        _tableView.allowsSelection          = self.allowsSelectionSwitch.isOnState;
        _tableView.selectionStyle           = self.selectionStylePicker.selectedSegment;
        _tableView.interiorBackgroundStyle  = self.backgroundStylePicker.selectedSegment;
        [_tableView registerClass:[KKTableViewCell class] forIdentifier:@"KKTableViewCell"];
        _tableView.autoresizingMask         = NSViewWidthSizable | NSViewHeightSizable;
        [parentView addSubview:_tableView];
    }
    return _tableView;
}

- (void)viewDidAppear
{
    [super viewDidAppear];
}

- (IBAction)tableViewStylePickerValueChanged:(NSSegmentedControl *)sender {
    [self.tableView removeFromSuperview];
    self.tableView = nil;
    [self tableView];
}

- (IBAction)backgroundStylePickerValueChanged:(NSSegmentedControl *)sender {
    self.tableView.interiorBackgroundStyle  = self.backgroundStylePicker.selectedSegment;
}

- (IBAction)selectionStylePickerValueChanged:(NSSegmentedControl *)sender {
    self.tableView.selectionStyle           = self.selectionStylePicker.selectedSegment;
}

- (IBAction)insert:(id)sender {
    
}

- (IBAction)moveTo:(id)sender {
    NSString *srcSection    = self.moveSrcSectionTextField.stringValue;
    NSString *srcRow        = self.moveSrcRowTextField.stringValue;
    NSString *destSection   = self.moveDestSectionTextField.stringValue;
    NSString *destRow       = self.moveDestRowTextField.stringValue;
    
    [self.tableView beginUpdates];
    if (srcRow.length == 0 || destRow.length == 0) {
        NSMutableArray *rows = [self.datas objectAtIndex:srcSection.intValue];
        [self.datas removeObjectAtIndex:srcSection.intValue];
        [self.datas insertObject:rows atIndex:destSection.intValue];
        
        NSString *headerTitle = [self.headerTitles objectAtIndex:srcSection.intValue];
        [self.headerTitles removeObjectAtIndex:srcSection.intValue];
        [self.headerTitles insertObject:headerTitle atIndex:destSection.intValue];
        
        NSString *footerTitle = [self.footerTitles objectAtIndex:srcSection.intValue];
        [self.footerTitles removeObjectAtIndex:srcSection.intValue];
        [self.footerTitles insertObject:footerTitle atIndex:destSection.intValue];
        
        [self.tableView moveSection:srcSection.intValue toSection:destSection.intValue];
    } else {
        NSIndexPath *indexPath      = [NSIndexPath indexPathForRow:srcRow.intValue inSection:srcSection.intValue];
        NSIndexPath *newIndexPath   = [NSIndexPath indexPathForRow:destRow.intValue inSection:destSection.intValue];
        
        NSMutableArray *rows        = [self.datas objectAtIndex:indexPath.section];
        NSMutableArray *newRows     = [self.datas objectAtIndex:newIndexPath.section];
        NSString *row               = [rows objectAtIndex:indexPath.row];
        [rows removeObjectAtIndex:indexPath.row];
        [newRows insertObject:row atIndex:newIndexPath.row];
        
        [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
    }
    [self.tableView endUpdates];
}

- (IBAction)sorting:(NSButton *)sender {
    self.tableView.sorting = !self.tableView.isSorting;
    sender.title = self.tableView.isSorting ? @"Cancel Sorting" : @"Sorting";
    [sender sizeToFit];
}

- (IBAction)removeSelectedRows:(id)sender {
    
    NSArray *indexPaths = self.tableView.indexPathsForSelectedRows;
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:NSTableViewAnimationSlideLeft];
    [self.tableView endUpdates];
}

- (IBAction)allowsSelection:(NSButton *)sender {
    self.tableView.allowsSelection = self.allowsSelectionSwitch.isOnState;
}

- (IBAction)allowsEmptySelection:(NSButton *)sender {
    self.tableView.allowsEmptySelection = self.allowsEmptySelectionSwitch.isOnState;
}

- (IBAction)allowsMultipleSelection:(NSButton *)sender {
    self.tableView.allowsMultipleSelection = self.allowsSelectionSwitch.isOnState;
}

- (IBAction)translucent:(NSButton *)sender {
    self.tableView.translucent = self.translucentSwitch.isOnState;
}

- (IBAction)alwaysEmphasizedSelectionBackground:(NSButton *)sender {
    self.tableView.alwaysEmphasizedSelectionBackground = self.alwaysEmphasizedSelectionBackgroundSwitch.isOnState;
}

#pragma mark - Table View Data Source / Delegate
- (NSInteger)numberOfSectionsInTableView:(KKTableView *)tableView
{
    return self.datas.count;
}

- (NSInteger)tableView:(KKTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.datas[section].count;
}

- (NSView *)tableView:(KKTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KKTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KKTableViewCell"];
    /*
    if (cell == nil) {
        cell = [[KKTableViewCell alloc] initWithStyle:KKTableViewCellStyleSubtitle reuseIdentifier:@"KKTableViewCell"];
    }
     */
    cell.imageView.image        = [NSImage imageNamed:NSImageNameFontPanel];
    cell.accessoryType          = KKTableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text         = self.datas[indexPath.section][indexPath.row];
    cell.detailTextLabel.text   = [NSString stringWithFormat:@"Detail section:%ld row:%ld",indexPath.section,indexPath.row];
    
    return cell;
}

/*
- (NSView *)tableView:(KKTableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSTextField *label = [NSTextField label];
    label.text = [NSString stringWithFormat:@"HEADER:%ld",section];
    // KKTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Header"];
    // cell.textLabel.text = [NSString stringWithFormat:@"HEADER:%ld",section];
    // return cell;
    return label;
}
 */

- (NSString *)tableView:(KKTableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.headerTitles[section];
}

- (NSString *)tableView:(KKTableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return self.footerTitles[section];
}

/*
- (CGFloat)tableView:(KKTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
*/

/*
- (NSArray<NSIndexPath *> *)tableView:(KKTableView *)tableView willSelectRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths
{
    if (self.tableView.isSorting) {
        return indexPaths;
    }
    if (tableView.selectionStyle == KKTableViewSelectionStyleDefault) {
        NSLog(@"Select section:%ld row:%ld",indexPaths.firstObject.section,indexPaths.firstObject.row);
        return nil;
    } else {
        return indexPaths;
    }
}
 */

- (void)tableView:(KKTableView *)tableView moveRowsAtIndexPaths:(NSArray<NSIndexPath *> *)sourceIndexPaths toIndexPath:(NSIndexPath *)destinationIndexPath
{
    NSMutableArray *sources     = [NSMutableArray array];
    for (NSIndexPath *indexPath in sourceIndexPaths) {
        NSMutableArray *section = self.datas[indexPath.section];
        NSString *string        = section[indexPath.row];
        [sources addObject:string];
        [section replaceObjectAtIndex:indexPath.row withObject:[NSNull null]];
    }
    NSMutableArray *destination = [self.datas objectAtIndex:destinationIndexPath.section];
    NSRange range = NSMakeRange(destinationIndexPath.row, sources.count);
    [destination insertObjects:sources atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
    
    for (NSIndexPath *indexPath in sourceIndexPaths) {
        NSMutableArray *from = self.datas[indexPath.section];
        [from removeObject:[NSNull null]];
    }
}

@end

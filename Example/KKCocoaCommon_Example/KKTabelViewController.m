//
//  KKTabelViewController.m
//  KKCocoaCommon_Example
//
//  Created by LeungKinKeung on 2020/11/6.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKTabelViewController.h"

@interface KKTabelViewController ()<KKTableViewDelegate,KKTableViewDataSource>

@property (nonatomic, strong) KKTableView *tableView;
@property (nonatomic, strong) NSMutableArray <NSMutableArray <NSString *>*>*datas;

@end

@implementation KKTabelViewController

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
    
    self.datas = NSMutableArray.new;
    for (NSInteger section = 0; section < 3; section++) {
        NSInteger numberOfRows = arc4random_uniform(10) + 10;
        NSMutableArray *strings = NSMutableArray.new;
        for (NSInteger row = 0; row < numberOfRows; row++) {
            [strings addObject:[NSString stringWithFormat:@"Title section:%ld row:%ld",section,row]];
        }
        [self.datas addObject:strings];
    }
    
    self.tableView  = [[KKTableView alloc] initWithFrame:CGRectZero style:KKTableViewStyleGrouped];
    self.tableView.delegate     = self;
    self.tableView.dataSource   = self;
    self.tableView.translucent  = NO;
    self.tableView.selectionBackgroundColors = @[NSColor.cyanColor,NSColor.blueColor];
    self.tableView.alwaysEmphasizedSelectionBackground  = YES;
    self.tableView.allowsMultipleSelection  = YES;
    self.tableView.allowsEmptySelection     = YES;
    self.tableView.allowsSelection          = YES;
    self.tableView.selectionStyle           = KKTableViewSelectionStyleDefault;
    
    if (self.tableView.isTranslucent) {
        self.tableView.interiorBackgroundStyle  = KKTableViewInteriorBackgroundStyleDefault;
        self.tableView.selectedImage            =
        [NSImage kktableViewSelectedImageWithTintColor:NSColor.alternateSelectedControlColor
                                       backgroundColor:NSColor.whiteColor
                                                  size:CGSizeMake(20, 20)];
    } else {
        self.tableView.interiorBackgroundStyle  = KKTableViewInteriorBackgroundStyleAlwaysNormal;
        self.tableView.selectionBackgroundColor = [NSColor colorWithWhite:0.5 alpha:0.1];
    }
    
    [self.tableView registerClass:[KKTableViewCell class]
                    forIdentifier:@"KKTableViewCell"];
    
//    [self.tableView registerClass:[KKTableViewCell class]
//                    forIdentifier:@"Header"];
    
    [self.view addSubview:self.tableView];
    
    if (@available(macOS 10.12, *)) {
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            self.tableView.tableHeaderView = [NSTextField labelWithString:@"!!!!header!!!"];
//        });
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            self.tableView.tableFooterView = [NSTextField labelWithString:@"!!!!footer!!!"];
//        });
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            self.tableView.tableFooterView = nil;
//        });
    }
    self.navigationBar.rightBarButtonItems = @[[NSButton imageButtonWithImage:[NSImage imageNamed:NSImageNameAddTemplate] target:self action:@selector(addBarButtonItemClick)],[NSButton imageButtonWithImage:[NSImage imageNamed:NSImageNameRemoveTemplate] target:self action:@selector(removeBarButtonItemClick)],[NSButton imageButtonWithImage:[NSImage imageNamed:NSImageNameListViewTemplate] target:self action:@selector(sortBarButtonItemClick)],[NSButton imageButtonWithImage:[NSImage imageNamed:NSImageNameMenuOnStateTemplate] target:self action:@selector(selectionButtonItemClick)]];
}

- (void)addBarButtonItemClick
{
    [self.tableView beginUpdates];
    NSMutableArray *list = [self.datas objectAtIndex:0];
    [list addObject:[NSString stringWithFormat:@"Title section:%d row:%ld",0,list.count]];
    [self.tableView insertRowAtIndexPath:[NSIndexPath indexPathForRow:list.count - 1 inSection:0] withRowAnimation:NSTableViewAnimationSlideLeft];
    [self.tableView endUpdates];
}

- (void)removeBarButtonItemClick
{
    [self.tableView beginUpdates];
    NSMutableArray *list = [self.datas objectAtIndex:0];
    [list removeLastObject];
    [self.tableView deleteRowAtIndexPath:[NSIndexPath indexPathForRow:list.count inSection:0] withRowAnimation:NSTableViewAnimationSlideRight];
    [self.tableView endUpdates];
}

- (void)sortBarButtonItemClick
{
    self.tableView.sorting = !self.tableView.isSorting;
    if (self.tableView.selectionStyle == KKTableViewSelectionStyleCheckmark) {
        [self.tableView deselectAll];
    }
    self.tableView.selectionStyle = self.tableView.isSorting ? KKTableViewSelectionStyleSystem : KKTableViewSelectionStyleDefault;
}

- (void)selectionButtonItemClick
{
    if (self.tableView.isSorting) {
        self.tableView.sorting = NO;
    }
    self.tableView.selectionStyle =
    self.tableView.selectionStyle != KKTableViewSelectionStyleCheckmark ?
    KKTableViewSelectionStyleCheckmark :
    KKTableViewSelectionStyleDefault;
    
    if (self.tableView.selectionStyle != KKTableViewSelectionStyleCheckmark) {
        [self.tableView deselectAll];
    }
}

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
    return [NSString stringWithFormat:@"HEADER:%ld",section];
}

- (NSString *)tableView:(KKTableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"footer:%ld",section];
}

/*
- (CGFloat)tableView:(KKTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
*/

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

- (void)viewDidAppear
{
    [super viewDidAppear];
    
    CGFloat barHeight           = self.navigationBar.frame.size.height;
    NSEdgeInsets contentInsets  = self.tableView.contentInsets;
    if (contentInsets.top != barHeight) {
        contentInsets.top = barHeight;
        contentInsets.bottom = 15;
        self.tableView.contentInsets = contentInsets;
    }
    self.tableView.automaticallyAdjustsContentInsets = NO;
}

- (void)viewDidLayout
{
    [super viewDidLayout];
    
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

- (BOOL)hasNavigationBar
{
    return YES;
}

- (void)navigationBarDidLoad
{
    self.navigationBar.barStyle = KKNavigationBarStyleBlur;
    self.navigationBar.titleLabel.text = @"Table View";
}

@end

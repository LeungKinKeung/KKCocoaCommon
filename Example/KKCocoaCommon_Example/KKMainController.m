//
//  KKMainController.m
//  KKCocoaCommon_Example
//
//  Created by LeungKinKeung on 2020/12/8.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKMainController.h"
#import <KKCocoaCommon/KKCocoaCommon.h>
#import "KKHUDViewController.h"
#import "KKTableViewController.h"
#import "KKCollectionViewController.h"
#import "KKExampleNavigationController.h"

@interface KKMenuItem : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger tag;

@end

@implementation KKMenuItem

@end

@interface KKMenu : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSMutableArray *menuItems;

@end

@implementation KKMenu

@end

@interface KKSidebarRowView : NSTableRowView

@end

@implementation KKSidebarRowView

- (NSBackgroundStyle)interiorBackgroundStyle
{
    return NSBackgroundStyleNormal;
}

- (BOOL)isEmphasized
{
    return NO;
}

@end

@interface KKSidebarOutlineView : NSOutlineView

@end

@implementation KKSidebarOutlineView

- (__kindof NSView *)makeViewWithIdentifier:(NSUserInterfaceItemIdentifier)identifier owner:(id)owner
{
    if ([identifier isEqualTo:NSOutlineViewDisclosureButtonKey]) {
        return nil;
    }
    return [super makeViewWithIdentifier:identifier owner:owner];
}

@end


@interface KKMainController () <NSToolbarDelegate, NSToolbarItemValidation, NSOutlineViewDelegate, NSOutlineViewDataSource>

@property (nonatomic, strong) KKViewController *sidebarViewController;
@property (nonatomic, strong) KKViewController *contentViewController;
@property (nonatomic, strong) NSMutableArray <KKMenu *>*menus;
@property (nonatomic, strong) NSScrollView *scrollView;
@property (nonatomic, strong) NSOutlineView *outlineView;

@end

@implementation KKMainController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *splitViewItems = NSMutableArray.new;
    if (@available(macOS 10.11, *)) {
        self.sidebarViewController      = [KKViewController new];
        NSSplitViewItem *sidebarItem    = [NSSplitViewItem sidebarWithViewController:self.sidebarViewController];
        sidebarItem.minimumThickness    = 150;
        sidebarItem.maximumThickness    = 250;
        sidebarItem.canCollapse         = NO;
        
        self.contentViewController      = [KKViewController new];
        NSSplitViewItem *contentItem    = [NSSplitViewItem contentListWithViewController:self.contentViewController];
        
        [splitViewItems addObject:sidebarItem];
        [splitViewItems addObject:contentItem];
        
    } else {
        self.sidebarViewController      = [KKViewController new];
        NSSplitViewItem *sidebarItem    = [NSSplitViewItem splitViewItemWithViewController:self.sidebarViewController];
        sidebarItem.canCollapse         = NO;
        
        self.contentViewController      = [KKViewController new];
        NSSplitViewItem *contentItem    = [NSSplitViewItem splitViewItemWithViewController:self.contentViewController];
        
        [splitViewItems addObject:sidebarItem];
        [splitViewItems addObject:contentItem];
    }
    self.splitViewItems = splitViewItems;
    
    // Sidebar菜单
    self.menus = NSMutableArray.new;
    
    {
        KKMenu *submenu         = [KKMenu new];
        submenu.title           = @"SIDEBAR TITLE";
        submenu.menuItems       = NSMutableArray.new;
        
        [submenu.menuItems addObject:[KKHUDViewController new]];
        [submenu.menuItems addObject:[KKTableViewController new]];
        [submenu.menuItems addObject:[KKCollectionViewController new]];
        [submenu.menuItems addObject:[KKNavigationRootController new]];
        
        for (NSViewController *viewController in submenu.menuItems) {
            [self.contentViewController addChildViewController:viewController];
            [self.contentViewController.view addSubview:viewController.view];
            viewController.view.frame               = self.contentViewController.view.bounds;
            viewController.view.autoresizingMask    = NSViewWidthSizable | NSViewHeightSizable;
            viewController.view.hidden              = YES;
        }
        [self.menus addObject:submenu];
    }
    
    {
        NSScrollView *scrollView            = [[NSScrollView alloc] initWithFrame:self.sidebarViewController.view.bounds];
        self.scrollView                     = scrollView;
        self.scrollView                     = scrollView;
        scrollView.hasVerticalScroller      = NO;
        scrollView.hasHorizontalScroller    = NO;
        scrollView.autohidesScrollers       = YES;
        scrollView.scrollerStyle            = NSScrollerStyleOverlay; // 滚动条盖在视图上
        scrollView.verticalScrollElasticity = YES;
        scrollView.automaticallyAdjustsContentInsets = NO;  // 假如不为NO，在NSScrollView重新布局时contentInsets会被清空
        scrollView.contentInsets            = NSEdgeInsetsMake(38, 0, 0, 0); // 需要在outlineView初始化之前设置否则无法立马生效，暂无更优解
        scrollView.drawsBackground          = NO;
        [self.sidebarViewController.view addSubview:scrollView];
        scrollView.autoresizingMask         = NSViewWidthSizable | NSViewHeightSizable;
    }
    {
        NSOutlineView *outlineView  = [[KKSidebarOutlineView alloc] initWithFrame:self.view.bounds];
        self.outlineView            = outlineView;
        NSTableColumn *columen      = [[NSTableColumn alloc] initWithIdentifier:[self className]];
        columen.resizingMask        = NSTableColumnAutoresizingMask; // 自动拉伸到最大宽度
        [outlineView addTableColumn:columen];
        columen.width               = self.view.bounds.size.width;
        outlineView.headerView      = nil;
        outlineView.floatsGroupRows = NO;
        outlineView.gridStyleMask   = NSTableViewGridNone;
        outlineView.intercellSpacing        = NSMakeSize(-20, 10);// 增加左边距和行高
        outlineView.allowsEmptySelection    = NO;
        outlineView.allowsMultipleSelection = NO;
        outlineView.focusRingType           = NSFocusRingTypeNone;// 不要高亮边框
        //outlineView.indentationMarkerFollowsCell    = NO;
        if (@available(macOS 10.11, *)) {
            outlineView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleRegular;
        } else {
            outlineView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleSourceList;
        }
        outlineView.allowsMultipleSelection = NO;
        outlineView.allowsEmptySelection    = NO;
        outlineView.delegate                = self;
        outlineView.dataSource              = self;
        outlineView.backgroundColor         = [NSColor clearColor];
        self.scrollView.documentView        = outlineView;
        
        // 展开所有行
        for (NSInteger i = 0; i < outlineView.numberOfRows; i++) {
            [outlineView expandItem:[outlineView itemAtRow:i]];
        }
        
        // 选中第一个
        [outlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:1] byExtendingSelection:NO];
        [self.contentViewController.childViewControllers objectAtIndex:0].view.hidden = NO;
    }
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return self.menus.count;
    }
    if ([self.menus containsObject:item]) {
        KKMenu *children = (KKMenu *)item;
        return children.menuItems.count;
    }
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (item == nil) {
        return [self.menus objectAtIndex:index];
    }
    if ([self.menus containsObject:item]) {
        KKMenu *children = (KKMenu *)item;
        return [children.menuItems objectAtIndex:index];
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if ([self.menus containsObject:item]) {
        return YES;
    }
    return NO;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    if ([self.menus containsObject:item]) {
        NSTextField *cell   =
        [outlineView makeViewWithIdentifier:@"ParentIdentifier" owner:outlineView];
        if (cell == nil) {
            cell            = [NSTextField label];
            cell.identifier = @"ParentIdentifier";
            cell.alphaValue = 0.6;
        }
        KKMenu *menu        = (KKMenu *)item;
        cell.stringValue    = menu.title;
        return cell;
    }
    if ([item isKindOfClass:[NSViewController class]]) {
        NSTextField *cell   =
        [outlineView makeViewWithIdentifier:@"ChildIdentifier" owner:outlineView];
        if (cell == nil) {
            cell            = [NSTextField label];
            cell.identifier = @"ChildIdentifier";
        }
        NSViewController *viewController = (NSViewController *)item;
        cell.stringValue    = viewController.title;
        return cell;
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    if ([self.menus containsObject:item]) {
        return NO;
    }
    if ([item isKindOfClass:[NSViewController class]]) {
        for (NSViewController *childViewController in self.contentViewController.childViewControllers) {
            childViewController.view.hidden         = YES;
        }
        NSViewController *selectedViewController    = item;
        selectedViewController.view.hidden          = NO;
        return YES;
    }
    return NO;
}

- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item
{
    NSUserInterfaceItemIdentifier identifier = [KKSidebarRowView className];
    KKSidebarRowView *rowView = [outlineView makeViewWithIdentifier:identifier owner:outlineView];
    if (rowView == nil) {
        rowView = [KKSidebarRowView new];
        rowView.identifier  = identifier;
    }
    return rowView;
} 

- (void)viewDidAppear
{
    [super viewDidAppear];
    // 设置顶部间隔
    self.scrollView.contentInsets = NSEdgeInsetsMake(self.view.window.contentView.frame.size.height - [self.view.window contentLayoutRect].size.height, 0, 0, 0);
}

@end

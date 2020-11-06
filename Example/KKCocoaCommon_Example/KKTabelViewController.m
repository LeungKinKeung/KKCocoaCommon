//
//  KKTabelViewController.m
//  KKCocoaCommon_Example
//
//  Created by v_ljqliang on 2020/11/6.
//  Copyright © 2020 LeungKinKeung. All rights reserved.
//

#import "KKTabelViewController.h"

@interface KKTabelViewController ()<KKTableViewDelegate,KKTableViewDataSource>

@property (nonatomic, strong) KKTableView *tableView;

@end

@implementation KKTabelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[KKTableView alloc] initWithFrame:CGRectZero style:KKTableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (NSInteger)numberOfSectionsInTableView:(KKTableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(KKTableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (NSView *)tableView:(KKTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KKTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KKTableViewCell"];
    if (cell == nil) {
        cell = [[KKTableViewCell alloc] initWithStyle:KKTableViewCellStyleValue1 reuseIdentifier:@"KKTableViewCell"];
    }
    cell.imageView.image        = [NSImage imageNamed:NSImageNameInfo];
    cell.accessoryType          = KKTableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text         = [NSString stringWithFormat:@"Title section:%ld row:%ld",indexPath.section,indexPath.row];
    cell.detailTextLabel.text   = [NSString stringWithFormat:@"Detail section:%ld row:%ld",indexPath.section,indexPath.row];
    
    return cell;
}

- (NSString *)tableView:(KKTableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Header title:%ld",section];
}

- (NSString *)tableView:(KKTableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Footer title:%ld",section];
}

//- (CGFloat)tableView:(KKTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 30;
//}


- (void)viewDidLayout
{
    [super viewDidLayout];
    
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.navigationBar.frame.size.height);
}

@end

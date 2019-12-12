//
//  FirmwareListController.m
//  FirmwareUpdate
//
//  Created by west on 16/9/20.
//  Copyright © 2016年 west. All rights reserved.
//
#import "DownLoadViewController.h"
#import "FirmwareListController.h"

@interface FirmwareListController ()<UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate> {
    NSMutableArray *_dataSource;
    UITableView *_table;
    
    NSArray *__cacheDataSource;
}

@end


@implementation FirmwareListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [FileManager createDirWithPath:DirectoryPath];
    _dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    [self drawUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
    [_table reloadData];
}

- (void)loadData {
    [_dataSource removeAllObjects];
    NSArray *directoryContents = [FileManager scanDirWithPath:DirectoryPath];
    [_dataSource addObjectsFromArray:directoryContents];
    __cacheDataSource = [_dataSource copy];
}

- (void)drawUI {
    self.title = @"Select Files";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"More" style:UIBarButtonItemStylePlain target:self action:@selector(moreFirmware)];
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    _table.backgroundColor = [UIColor whiteColor];
    _table.delegate = self;
    _table.dataSource = self;
    _table.tableHeaderView = [self uiSearchBar];
    [self.view addSubview:_table];
}

- (UISearchBar *)uiSearchBar {
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    searchBar.delegate = self;
    searchBar.showsCancelButton = YES;
    return searchBar;
}

- (void)moreFirmware {
    [self.navigationController pushViewController:[DownLoadViewController new] animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return FONT(44);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, cell.textLabel.frame.size.width + 100, cell.textLabel.frame.size.height);
    cell.textLabel.text = [_dataSource objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *path = [NSString stringWithFormat:@"%@/%@", DirectoryPath, [_dataSource objectAtIndex:indexPath.row]];
    if (_delegate && [_delegate respondsToSelector:@selector(selectFirmware:)]) {
        [_delegate selectFirmware:path];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSLog(@"%@",searchText);
    [_dataSource removeAllObjects];
    if ([searchText isEqualToString:@""] ||
        searchText == nil) {
        [_dataSource addObjectsFromArray:__cacheDataSource];
    }else {
       NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self contains [cd] %@",searchText];
       NSArray *arrays =  [[NSArray alloc] initWithArray:[__cacheDataSource filteredArrayUsingPredicate:predicate]];
        [_dataSource addObjectsFromArray:arrays];
    }
    [_table reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [searchBar endEditing:YES];
    [_dataSource addObjectsFromArray:__cacheDataSource];
    [_table reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

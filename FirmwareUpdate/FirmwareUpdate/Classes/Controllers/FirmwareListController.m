//
//  FirmwareListController.m
//  FirmwareUpdate
//
//  Created by west on 16/9/20.
//  Copyright © 2016年 west. All rights reserved.
//
#import "DownLoadViewController.h"
#import "FirmwareListController.h"

@interface FirmwareListController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_table;
    
    NSMutableArray *_dataSource;
}

@end

@implementation FirmwareListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [FileManager createDirWithPath:DirectoryPath];
    _dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    [self drawUI];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadData];
}

- (void)loadData
{
    [_dataSource removeAllObjects];
    NSArray *directoryContents = [FileManager scanDirWithPath:DirectoryPath];
    [_dataSource addObjectsFromArray:directoryContents];
}

- (void)drawUI
{
    self.title = @"选择固件";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"更多固件" style:UIBarButtonItemStylePlain target:self action:@selector(moreFirmware)];
    
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStylePlain];
    _table.backgroundColor = [UIColor whiteColor];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
}

- (void)moreFirmware {
    [self.navigationController pushViewController:[DownLoadViewController new] animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    }
    cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, cell.textLabel.frame.size.width + 100, cell.textLabel.frame.size.height);
    cell.textLabel.text = [_dataSource objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *path = [NSString stringWithFormat:@"%@/%@", DirectoryPath, [_dataSource objectAtIndex:indexPath.row]];
    if (_delegate && [_delegate respondsToSelector:@selector(selectFirmware:)]) {
        [_delegate selectFirmware:path];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

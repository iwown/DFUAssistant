//
//  DownLoadViewController.m
//  FirmwareUpdate
//
//  Created by 曹凯 on 2016/11/8.
//  Copyright © 2016年 west. All rights reserved.
//
#import "Toast.h"
#import "IVFirmwareModel.h"
#import "NetWorkHandle.h"
#import "DownLoadViewController.h"

@interface DownLoadViewController ()<UITableViewDelegate,UITableViewDataSource>


@property (nonatomic ,strong)UITableView *tableView;
@property (nonatomic ,strong)NSMutableArray *dataSource;
@end


@implementation DownLoadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"更多固件";
    _dataSource = [NSMutableArray arrayWithCapacity:0];
    NSArray *array = [NetWorkHandle selectFirmwareList];
    [_dataSource addObjectsFromArray:array];
    [self drawTableView];
    // Do any additional setup after loading the view.
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [Toast hideToastActivity];
}

- (void)drawTableView {
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    IVFirmwareModel *fModel = [_dataSource objectAtIndex:indexPath.row];
    cell.textLabel.text = fModel.model;
    cell.detailTextLabel.text = fModel.fwVersion;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    IVFirmwareModel *fModel = [_dataSource objectAtIndex:indexPath.row];
    NSString *download = fModel.downloadLink;
    NSString *firmName = [NSString stringWithFormat:@"%@_%@",fModel.model,[fModel.fwVersion stringByReplacingOccurrencesOfString:@"." withString:@"-"]];
    
    [Toast makeToastActivityWithViwa:@"正在下载..."];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(queue, ^{
        if (![self downloadWith:download andFirmwareName:firmName]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Toast makeToast:@"下载失败"];
                [Toast hideToastActivity];
            });
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [Toast hideToastActivity];
            [_dataSource removeObjectAtIndex:indexPath.row];
            [tableView reloadData];
        });
    });
}

- (BOOL)downloadWith:(NSString *)url andFirmwareName:(NSString *)fileName{
    
    NSString *fileType = [[url componentsSeparatedByString:@"."] lastObject];
    fileName = [[fileName stringByAppendingString:@"."] stringByAppendingString:fileType];
    NSString *fullPath = [DirectoryPath stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:fullPath]) {
        
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:url]];
        [fileManager createFileAtPath:fullPath contents:data attributes:nil];
        
        if ([[fileManager contentsAtPath:fullPath] length] == 0) {
            return NO;
        }
        else
        {
            NSLog(@"固件下载完成");
            return YES;
        }
    }
    else
    {
        NSLog(@"固件已存在");
        return YES;
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

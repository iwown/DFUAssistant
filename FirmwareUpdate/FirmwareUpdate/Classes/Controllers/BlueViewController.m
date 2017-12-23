//
//  BlueViewController.m
//  FirmwareUpdate
//
//  Created by 曹凯 on 2016/10/31.
//  Copyright © 2016年 west. All rights reserved.
//
#import "Defines.h"
#import "BluetoothManager.h"
#import "BlueViewController.h"
#import "DeviceStorage.h"

@interface BlueViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic ,strong)UITableView *tableView;
@property (nonatomic ,strong)NSMutableArray *dataSource;
@end

@implementation BlueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self drawTableView];
    
    self.manager = [[BluetoothManager alloc] init];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateDeviceList:)
                                                 name:DeviceStorageUpdated
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didConnectToDevice:)
                                                 name:BluetoothManagerConnectedToDevice
                                               object:nil];
    
    [self onRefresh];
    // Do any additional setup after loading the view.
}

- (void) didUpdateDeviceList:(NSNotification*)notification {
    [self.tableView reloadData];
}

- (void) didConnectToDevice:(NSNotification*)notification {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)drawTableView {
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    _dataSource = [DeviceStorage sharedInstance].devices;
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    GenericServiceManager *device = _dataSource[indexPath.row];
    cell.textLabel.text = device.deviceName;
    cell.detailTextLabel.text = NSLocalizedString(@"未绑定", nil);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    CBPeripheral *device = [[DeviceStorage sharedInstance] deviceForIndex:(int)indexPath.row];
    [[BluetoothManager getInstance] connectToDevice:device];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onRefresh {

    [self.manager startScanning];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.manager stopScanning];
    });
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

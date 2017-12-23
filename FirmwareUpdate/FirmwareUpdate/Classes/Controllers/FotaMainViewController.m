//
//  FotaMainViewController.m
//  FirmwareUpdate
//
//  Created by west on 2017/5/9.
//  Copyright © 2017年 west. All rights reserved.
//

#import "FotaMainViewController.h"
#import "MTKBleManager.h"

@interface FotaMainViewController ()<BleDiscoveryDelegate, BleConnectDlegate, UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *_dataArr;
    UITableView *_table;
}
@end

@implementation FotaMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Fota update";
    
    [self initParam];
    [self drawUI];
}

//- (void)registerScanningStateChangeDelegate:(id<BleScanningStateChangeDelegate>)scanStateChangeDelegate;
//- (void)registerBluetoothStateChangeDelegate:(id<BluetoothAdapterStateChangeDelegate>)bluetoothStateChangeDelegate;

- (void)initParam {
    [[MTKBleManager sharedInstance] registerDiscoveryDelgegate:self];
    [[MTKBleManager sharedInstance] registerConnectDelgegate:self];
    
    _dataArr = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)drawUI {
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]
                                   initWithTitle:@"Scan"
                                   style:UIBarButtonItemStylePlain
                                   target:self
                             action:@selector(rightBtnClick)];
    [self.navigationItem setRightBarButtonItem:item];
    
    UITableView *table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    [self.view addSubview:table];
    _table = table;
}

- (void)rightBtnClick{
    if ([[MTKBleManager sharedInstance] getScanningState] == 1) {
        [self stopScan];
    } else {
        [_dataArr removeAllObjects];
        [self startScan];
    }
}

- (void)startScan {
    [[MTKBleManager sharedInstance] startScanning];
}

- (void)stopScan {
    [[MTKBleManager sharedInstance] stopScanning];
}

- (void)connectPeripheral: (CBPeripheral *)peripheral {
    [[MTKBleManager sharedInstance] connectPeripheral:peripheral];
}

#pragma mark - BleDiscoveryDelegate
- (void) discoveryDidRefresh: (CBPeripheral *)peripheral {
//    NSLog(@"discoveryDidRefresh===========%@", peripheral);
//    
    [_dataArr addObject:peripheral];
    [_table reloadData];
}
- (void) discoveryStatePoweredOff {
    NSLog(@"discoveryStatePoweredOff");
}


#pragma mark - BleConnectDlegate
- (void) connectDidRefresh:(int)connectionState deviceName:(CBPeripheral*)peripheral {
    NSLog(@"connectDidRefresh======%d=====%@", connectionState, peripheral);
}
- (void) disconnectDidRefresh: (int)connectionState devicename: (CBPeripheral *)peripheral {
    NSLog(@"disconnectDidRefresh======%d=====%@", connectionState, peripheral);
}
- (void) retrieveDidRefresh: (NSArray *)peripherals {
    NSLog(@"retrieveDidRefresh===========%@", peripherals);
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArr.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"Cell"];
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    cell.textLabel.text = @"";
    cell.detailTextLabel.text = @"";
    
    CBPeripheral *peripheral = _dataArr[indexPath.row];
    cell.textLabel.text = peripheral.name;
    if (peripheral.state == CBPeripheralStateConnected) {
        cell.detailTextLabel.text = @"已连接";
    } else {
        cell.detailTextLabel.text = @"未连接";
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self stopScan];
    CBPeripheral *peripheral = _dataArr[indexPath.row];
    [self connectPeripheral:peripheral];
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

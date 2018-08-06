//
//  DeviceConectController.m
//  FirmwareUpdate
//
//  Created by west on 16/9/20.
//  Copyright © 2016年 west. All rights reserved.
//
#import "DeviceConectController.h"

NSString * const zgDfuServiceUUIDString = @"FE59";

@interface DeviceConectController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray      *peripherals;
    int                 _percentage;
    
    UITableView         *_table;
    NSMutableArray      *_dataSource;
    UILabel             *_label;
    UIView              *_coverView;
    BOOL                isRefresh;
}

@end

@implementation DeviceConectController

@synthesize bluetoothManager;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self performSelector:@selector(stopScanDevice) withObject:nil afterDelay:5.0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadData];
    [self drawUI];
}

- (void)loadData {
    _dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    dispatch_queue_t centralQueue = dispatch_queue_create("no.nordicsemi.ios.nrftoolbox", DISPATCH_QUEUE_SERIAL);
    bluetoothManager = [[CBCentralManager alloc]initWithDelegate:self queue:centralQueue];
}

- (void)drawUI {
    self.title = @"连接设备";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
    _table.backgroundColor = [UIColor whiteColor];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    _label.backgroundColor = [UIColor whiteColor];
    _label.text = @"设备";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return FONT(44);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    
    cell.textLabel.frame = CGRectMake(cell.textLabel.frame.origin.x, cell.textLabel.frame.origin.y, cell.textLabel.frame.size.width + 100, cell.textLabel.frame.size.height);
    CBPeripheral *peripheral = [_dataSource objectAtIndex:indexPath.row];
    
    cell.textLabel.text = peripheral.name;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CBPeripheral *peripheral = [_dataSource objectAtIndex:indexPath.row];
    if (_delegate && [_delegate respondsToSelector:@selector(centralManager:ConnectSuccessPeripheral:)]) {
        [_delegate centralManager:bluetoothManager ConnectSuccessPeripheral:peripheral];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return _label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}


#pragma mark - Central Manage Delegate
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    for (CBPeripheral *aPer in _dataSource) {
        if (peripheral == aPer) {
            return;
        }
    }
    [_dataSource addObject:peripheral];
    NSLog(@"%@", peripheral);
    NSLog(@"%@", _dataSource);
    dispatch_async(dispatch_get_main_queue(), ^{
        [_table reloadData];
    });
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBCentralManagerStateUnknown:
            NSLog(@">>>CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@">>>CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@">>>CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@">>>CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@">>>CBCentralManagerStatePoweredOff");
            break;
        case CBCentralManagerStatePoweredOn:
        {
            NSLog(@">>>CBCentralManagerStatePoweredOn");
            //开始扫描周围的外设
            CBUUID *aUuid = [CBUUID UUIDWithString:dfuServiceUUIDString];
            CBUUID *bUuid = [CBUUID UUIDWithString:zgDfuServiceUUIDString];
            NSArray *sIDs = @[aUuid, bUuid];
            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
            [central scanForPeripheralsWithServices:sIDs options:options];
          /*  dispatch_async(dispatch_get_main_queue(), ^{
                [self showActView];
            });*/
        }
            break;
        default:
            break;
    }
}

- (void)stopScanDevice {
    [bluetoothManager stopScan];
    [self actViewHidden];
    if ([_dataSource count] <= 0) {
        _label.text = @"无DFU状态的设备";
    }
    isRefresh = NO;
    [_table reloadData];
    
    if (self.autoUpgrading) {
        CBPeripheral *peripheral = _dataSource.firstObject;
        if (peripheral && [_delegate respondsToSelector:@selector(centralManager:ConnectSuccessPeripheral:)]) {
            [_delegate centralManager:bluetoothManager ConnectSuccessPeripheral:peripheral];
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            [NSThread sleepForTimeInterval:1];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

static const CGFloat CSToastActivityWidth       = 50.0;
- (void)showActView {
    [self actViewHidden];
    _coverView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _coverView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_coverView];
    
    UIView *actView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    actView.backgroundColor = [UIColor colorWithRed:0.88 green:0.88 blue:0.88 alpha:0.6];
    actView.center = _coverView.center;
    actView.layer.masksToBounds = YES;
    actView.layer.cornerRadius = 10;

    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"加载成功青蛙"]];
    [image setFrame:CGRectMake(25, 13, CSToastActivityWidth, CSToastActivityWidth+6)];
    [actView addSubview:image];
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = CGPointMake(10,90);
    [actView addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, 80, 20)];
    [lab setText:@"正在搜索中..."];
    [lab setTextAlignment:NSTextAlignmentRight];
    [lab setFont:[UIFont systemFontOfSize:12]];
    [lab setTextColor:[UIColor lightGrayColor]];
    [actView addSubview:lab];
    [_coverView addSubview:actView];
}

- (void)actViewHidden {
    if (_coverView) {
        for (UIView *view in _coverView.subviews) {
            [view removeFromSuperview];
        }
        [_coverView removeFromSuperview];
        _coverView = nil;
    }
}

- (void)reloadTable {
    if (isRefresh) {
        [_table reloadData];
        [self performSelector:@selector(reloadData) withObject:nil afterDelay:1.0];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  LightBlueViewController.m
//  FirmwareUpdate
//
//  Created by A$CE on 2018/8/2.
//  Copyright © 2018年 west. All rights reserved.
//
#define PB_CHARACTER_ID_WRITE          @"2E8C0003-2D91-5533-3117-59380A40AF8F"
#define Z4_CHARACTER_ID_WRITE          @"6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
#define CHARACTER_ID_WRITE             @"FF21"


#define PROBUFF_SERVICE_DFU_UUID       @"FE59"
#define PROBUFF_CHARACT_DFU_UUID       @"8EC90003-F315-4F60-9FB8-838830DAEA50"


#import <CoreBluetooth/CoreBluetooth.h>
#import "LightBlueViewController.h"

@interface LightBlueViewController ()<CBCentralManagerDelegate ,UITableViewDelegate ,UITableViewDataSource ,CBPeripheralDelegate>
{
    NSMutableArray      *peripherals;
    int                 _percentage;
    
    UITableView         *_table;
    UIButton            *_upgradeBtn;
    NSMutableArray      *_dataSource;
    UILabel             *_label;
    UIView              *_coverView;
    BOOL                isRefresh;
    
    CBPeripheral        *_writePeripheral;
    CBCharacteristic    *_writeCharacteristic;
    BOOL                _writeCharacteristicLock;
}
@property (nonatomic, strong)CBCentralManager *bluetoothManager;

@end

@implementation LightBlueViewController
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
    bluetoothManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
}

- (void)drawUI {
    self.title = @"Light Blue";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64) style:UITableViewStyleGrouped];
    _table.backgroundColor = [UIColor whiteColor];
    _table.delegate = self;
    _table.dataSource = self;
    [self.view addSubview:_table];
    
    _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    _label.backgroundColor = [UIColor whiteColor];
    _label.text = @"Device";
    
    [self drawUpgradeButton];
}

- (void)drawUpgradeButton {
    _upgradeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_upgradeBtn];
    [_upgradeBtn setFrame:CGRectMake(0.5*(SCREEN_WIDTH-FONT(120)), SCREEN_HEIGHT - FONT(180), FONT(120),FONT(40))];
    [_upgradeBtn setTitle:@"ENTRY DFU" forState:UIControlStateNormal];
    [_upgradeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_upgradeBtn setBackgroundColor:[UIColor colorWithRed:65/255.0 green:173/255.0 blue:229/255.0 alpha:0.6]];
    [[_upgradeBtn titleLabel] setFont:[UIFont systemFontOfSize:FONT(16)]];
    [_upgradeBtn addTarget:self action:@selector(dfuBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_upgradeBtn setHidden:YES];
    _upgradeBtn.layer.cornerRadius = FONT(20);
    _upgradeBtn.layer.masksToBounds = YES;
}

- (void)showUpgradeBtn {
    _table.hidden = YES;
    _upgradeBtn.hidden = NO;
}

- (void)dfuBtnClick {
    _upgradeBtn.backgroundColor = [UIColor colorWithRed:0xDD/255.0 green:0xDD/255.0 blue:0xDD/255.0 alpha:0.2];
    [self entryDFUState];
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
    [bluetoothManager connectPeripheral:peripheral options:nil];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return _label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40;
}

#pragma mark - Central Manage Delegate
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    if (RSSI.integerValue < -80 ||
        peripheral.name == nil ||
        [@"" isEqualToString:peripheral.name]) {
        return;
    }
    for (CBPeripheral *aPer in _dataSource) {
        if (peripheral == aPer) {
            return;
        }
    }
    [_dataSource addObject:peripheral];
    [_dataSource sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        CBPeripheral *run1 = obj1;
        CBPeripheral *run2 = obj2;
        NSInteger rssiA = run1.RSSI.integerValue;
        NSInteger rssiB = run2.RSSI.integerValue;
        return (rssiA < rssiB);
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_table reloadData];
    });
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    peripheral.delegate = self;
    [peripheral discoverServices:nil];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    switch (central.state) {
        case CBManagerStateUnknown:
            NSLog(@">>>CBManagerStateUnknown");
            break;
        case CBManagerStateResetting:
            NSLog(@">>>CBManagerStateResetting");
            break;
        case CBManagerStateUnsupported:
            NSLog(@">>>CBManagerStateUnsupported");
            break;
        case CBManagerStateUnauthorized:
            NSLog(@">>>CBManagerStateUnauthorized");
            break;
        case CBManagerStatePoweredOff:
            NSLog(@">>>CBManagerStatePoweredOff");
            break;
        case CBManagerStatePoweredOn:
        {
            NSLog(@">>>CBManagerStatePoweredOn");
            NSArray *peripheralsB = [central retrieveConnectedPeripheralsWithServices:[self searchServiceUUids]];
            [_dataSource addObjectsFromArray:peripheralsB];
            //开始扫描周围的外设
            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
            [central scanForPeripheralsWithServices:nil options:options];
        }
            break;
        default:
            break;
    }
}

- (NSArray *)searchServiceUUids {
    NSArray *uuids = @[@"FEF5", @"180D"];
    NSMutableArray *sIDs = [NSMutableArray arrayWithCapacity:0];
    for (NSString *str in uuids) {
        CBUUID *theService= [CBUUID UUIDWithString:str];
        [sIDs addObject:theService];
    }
    return sIDs;
}

- (void)stopScanDevice {
    [bluetoothManager stopScan];
    [self actViewHidden];
    if ([_dataSource count] <= 0) {
        _label.text = @"No Device Found";
    }
    isRefresh = NO;
    [_table reloadData];
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

#pragma mark- Delegate
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error {
    for (CBCharacteristic *ch in service.characteristics) {
        if (ch.properties == CBCharacteristicPropertyIndicate ||
            ch.properties == CBCharacteristicPropertyNotify) {
            NSLog(@"%s :\n%@",__FUNCTION__ ,ch);
            [peripheral setNotifyValue:YES forCharacteristic:ch];
        }else if ((ch.properties&CBCharacteristicPropertyWrite) > 0 ||
                  (ch.properties&CBCharacteristicPropertyWriteWithoutResponse) > 0) {
            if (_writeCharacteristicLock) {
                return;
            }
            
            _writePeripheral = peripheral;
            _writeCharacteristic = ch;
            if ([ch.UUID.UUIDString isEqualToString:PROBUFF_CHARACT_DFU_UUID]) {
                _writeCharacteristic = ch;
                _writeCharacteristicLock = YES;
            }
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForDescriptor:(CBDescriptor *)descriptor error:(NSError *)error {}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSLog(@"%s",__FUNCTION__);
    if (characteristic.isNotifying != YES) {
        return;
    }
    _writePeripheral = peripheral;
    if ([characteristic.UUID.UUIDString isEqualToString:PROBUFF_CHARACT_DFU_UUID]) {
        [NSThread sleepForTimeInterval:3];
        [self writeUpgradeCmdA];
    }else {
        [self showUpgradeBtn];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if ([characteristic.UUID.UUIDString isEqualToString:PROBUFF_CHARACT_DFU_UUID]) {
        [NSThread sleepForTimeInterval:0.2];
        [self writeUpgradeCmdB];
        [NSThread sleepForTimeInterval:0.2];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)entryDFUState {
    if ([_writeCharacteristic.UUID isEqual:[CBUUID UUIDWithString:Z4_CHARACTER_ID_WRITE]]) {
        NSString *str = @"0600811001000000000000000000000000000000";
        NSData *data = [self stringToByte:str];
        [_writePeripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
    }
    else if ([_writeCharacteristic.UUID isEqual:[CBUUID UUIDWithString:CHARACTER_ID_WRITE]]) {
        NSString *str = @"21ff0300";
        NSData *data = [self stringToByte:str];
        [_writePeripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
    }
    else if ([_writeCharacteristic.UUID isEqual:[CBUUID UUIDWithString:PROBUFF_CHARACT_DFU_UUID]]) {
        [self deviceUpgrade];
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deviceUpgrade {
    [_writePeripheral setNotifyValue:YES forCharacteristic:_writeCharacteristic];
}

- (void)writeUpgradeCmdA {
    NSLog(@"%s",__func__);
    NSString *str = @"02084466753236383230";
    NSData *dataA = [self stringToByte:str];
    [_writePeripheral writeValue:dataA forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (void)writeUpgradeCmdB {
    NSLog(@"%s",__func__);
    NSString *str = @"01";
    NSData *dataB = [self stringToByte:str];
    [_writePeripheral writeValue:dataB forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

- (NSData*)stringToByte:(NSString*)string {
    NSString *hexString = [[string uppercaseString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([hexString length]%2!=0) {
        return nil;
    }
    
    Byte tempbyt[1]={0};
    NSMutableData* bytes=[NSMutableData data];
    for(int i=0;i<[hexString length];i++) {
        unichar hex_char1 = [hexString characterAtIndex:i];
        ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;
        //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16;
        //// A 的Ascll - 65
        else return nil;
        i++;
        unichar hex_char2 = [hexString characterAtIndex:i];
        ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9') int_ch2 = (hex_char2-48);
        //// 0 的Ascll - 48
        else if(hex_char2 >= 'A' && hex_char2 <='F') int_ch2 = hex_char2-55;
        //// A 的Ascll - 65
        else return nil;
        tempbyt[0] = int_ch1+int_ch2;
        ///将转化后的数放入Byte数组里
        [bytes appendBytes:tempbyt length:1];
    }
    return bytes;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

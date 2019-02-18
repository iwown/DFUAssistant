//
//  EPOViewController.m
//  FirmwareUpdate
//
//  Created by A$CE on 2018/8/2.
//  Copyright © 2018年 west. All rights reserved.
//
#import <BLEMidAutumn/AutumnHeader.h>
#import <IVBaseKit/IVBaseKit.h>
#import "BtNotify.h"
#import "YSProgressView.h"
#import "EPOViewController.h"

@interface EPOViewController ()<CBCentralManagerDelegate ,UITableViewDelegate ,UITableViewDataSource ,CBPeripheralDelegate ,SPC_NotifyCustomDelegate>
{
    NSMutableArray      *peripherals;
    int                 _percentage;
    
    UITableView         *_table;
    UIButton            *_upgradeBtn;
    NSMutableArray      *_dataSource;
    UILabel             *_label;
    UIView              *_coverView;
    BOOL                isRefresh;
    
    YSProgressView      *_epoProgress;
    UILabel             *_stateLabel;
    NSInteger           _count_pack;
    
    CBPeripheral        *_writePeripheral;
    CBCharacteristic    *_writeCharacteristic;
}
@property (nonatomic, strong)CBCentralManager *bluetoothManager;

@end

@implementation EPOViewController

@synthesize bluetoothManager;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self performSelector:@selector(stopScanDevice) withObject:nil afterDelay:5.0];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initParams];
    [self drawUI];
}

- (void)initParams {
    _dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    bluetoothManager = [[CBCentralManager alloc]initWithDelegate:self queue:nil];
    [[BtNotify sharedInstance] registerCustomDelegate:self];
}

static NSString *const kDOGPReadCharUUIDString = @"00002aa0-0000-1000-8000-00805f9b34fb";
static NSString *const kDOGPWriteCharUUIDString = @"00002aa1-0000-1000-8000-00805f9b34fb";
- (void)setBTNotifyParamsIfNeed {
    
    CBPeripheral *p = _writePeripheral;
    
    CBCharacteristic *wCh = nil;
    CBCharacteristic *rCh = nil;
    for (CBService *s in p.services) {
        if (![s.UUID isEqual:[CBUUID UUIDWithString:PEDOMETER_WATCH_SERVICE_UUID]]) {
            continue;
        }
        for (CBCharacteristic *c in s.characteristics) {
            if ([c.UUID isEqual:[CBUUID UUIDWithString:kDOGPWriteCharUUIDString]]) {
                wCh = c;
            }else if ([c.UUID isEqual:[CBUUID UUIDWithString:kDOGPReadCharUUIDString]]) {
                rCh = c;
            }
        }
    }
    if (!wCh && !rCh) {
        return;
    }
    [[BtNotify sharedInstance] setGattParameters:p writeCharacteristic:wCh readCharacteristic:rCh];
    [[BtNotify sharedInstance] updateConnectionState:CBPeripheralStateConnected];
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
    _label.text = @"设备";
    
    [self drawUpgradeButton];
}

- (void)drawUpgradeButton {
    
    _epoProgress = [[YSProgressView alloc] initWithFrame:CGRectMake(0.5 * (SCREEN_WIDTH - 236), SCREEN_HEIGHT * 0.48, 236, 10)];
    _epoProgress.hidden = YES;
    [self.view addSubview:_epoProgress];

    _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT * 0.48 + 15, SCREEN_WIDTH, 40)];
    _stateLabel.textAlignment = NSTextAlignmentCenter;
    _stateLabel.backgroundColor = [UIColor whiteColor];
    _stateLabel.text = @"初始化已完成";
    [self.view addSubview:_stateLabel];
    _stateLabel.hidden = YES;
    
    _upgradeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_upgradeBtn];
    [_upgradeBtn setFrame:CGRectMake(0.5*(SCREEN_WIDTH-FONT(120)), SCREEN_HEIGHT - FONT(180), FONT(120),FONT(40))];
    [_upgradeBtn setTitle:@"UPDATE EPO" forState:UIControlStateNormal];
    [_upgradeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_upgradeBtn setBackgroundColor:[UIColor colorWithRed:65/255.0 green:173/255.0 blue:229/255.0 alpha:0.6]];
    [[_upgradeBtn titleLabel] setFont:[UIFont systemFontOfSize:FONT(16)]];
    [_upgradeBtn addTarget:self action:@selector(dfuBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_upgradeBtn setHidden:YES];
    _upgradeBtn.layer.cornerRadius = FONT(20);
    _upgradeBtn.layer.masksToBounds = YES;
}

- (void)showUpdateUIReady {
    _table.hidden = YES;
    _upgradeBtn.hidden = NO;
    _stateLabel.hidden = NO;
    _epoProgress.hidden = NO;
    [_epoProgress updateProgress:0 color:[UIColor orangeColor]];
}

- (void)showUpdateProgress:(NSInteger)percent {
    NSLog(@"%s:%ld",__func__,(long)percent);
    CGFloat pro = percent * 0.01;
    [_stateLabel setText:[NSString stringWithFormat:@"%ld %%",(long)percent]];
    [_epoProgress updateProgress:pro color:[UIColor orangeColor]];
}

- (void)showUpdateUIFail {
    [_stateLabel setText:@"Upgrading Failed, Please Back"];
    [_epoProgress updateProgress:0 color:[UIColor orangeColor]];
}

- (void)showUpdateUIComplete {
    [_stateLabel setText:@"Upgraded Complete"];
    [_epoProgress updateProgress:1 color:[UIColor orangeColor]];
}

- (void)dfuBtnClick {
    [self requestForEpoUdate];
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
            //开始扫描周围的外设
            CBUUID *aUuid = [CBUUID UUIDWithString:PEDOMETER_WATCH_SERVICE_UUID];
            CBUUID *bUuid = [CBUUID UUIDWithString:PEDOMETER_MTK_SERVICE_UUID];
            NSArray *sIDs = @[aUuid, bUuid];
            NSArray *peripheralsB = [bluetoothManager retrieveConnectedPeripheralsWithServices:sIDs];
            [_dataSource addObjectsFromArray:peripheralsB];
            
            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
            [central scanForPeripheralsWithServices:sIDs options:options];
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
        _label.text = @"No Device";
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
            _writePeripheral = peripheral;
            _writeCharacteristic = ch;
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error {
    NSLog(@"%s",__FUNCTION__);
    if (characteristic.isNotifying != YES) {
        return;
    }
    _writePeripheral = peripheral;
    [self setBTNotifyParamsIfNeed];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"%@",characteristic.value);
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kDOGPReadCharUUIDString]]) { //MTK
        NSError *error = nil;
        [[BtNotify sharedInstance] handleReadReceivedData:characteristic error:error];
    }else if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:PEDOMETER_NEW_CHARACT_TEST]]) {
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"%@",characteristic.value);
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:kDOGPWriteCharUUIDString]]) { //MTK
        NSError *error = nil;
        [[BtNotify sharedInstance] handleWriteResponse:characteristic error:error];
    }
}

- (void)requestForEpoUdate {
    
    if ([_writeCharacteristic.UUID isEqual:[CBUUID UUIDWithString:PEDOMETER_NEW_CHARACT_SET_UUID]]) {
        NSString *str = @"21ff65020101";
        NSData *data = [self stringToByte:str];
        [_writePeripheral writeValue:data forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithoutResponse];
    }
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

#pragma mark- BTNotifyDelegate
-(void)onReadyToSend:(BOOL)ready {
    NSLog(@"%s:%d",__func__,ready);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showUpdateUIReady];
    });
}

-(void)onDataArrival:(NSString *)receiver arrivalData:(NSData *)data {
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%s:%@ data: %@ - String: %@",__func__,receiver,data,dataStr);
    if ([dataStr isEqualToString:@"epo_download"]) {
        [self epoUpdateStart];
    }
}

static const int TOTAL_PACK = 218;
-(void)onProgress:(NSString *)sender
      newProgress:(float)progress {
    NSLog(@"%s:%@,%f",__func__,sender,progress);
    if ([sender isEqualToString:@"epo_update_data"]) {
        _count_pack ++;
        int per = (int)(_count_pack * 100 /TOTAL_PACK);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showUpdateProgress:per];
        });
    }else if ([sender isEqualToString:@"epo_update_md5"]){
        _count_pack = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showUpdateUIComplete];
        });
    }
}

#pragma mark -EPO
- (dispatch_queue_t)bleQueue {
    static dispatch_queue_t _bleQueue = nil;
    if (_bleQueue == nil) {
        _bleQueue = dispatch_queue_create("ble-central-mtk-epo-queue", 0);}
    return _bleQueue;
}

static int DATA_LEN = 1024;
#define EPO_URL [NSURL URLWithString:@"https://search.iwown.com/epo_download/EPO_GPS_3_1.DAT"]
#define EPO_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"EPO_GPS_3_1.dat"]
#define EPO_PATH_TMP [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"EPO_GPS_3_1_tmp.dat"]
#define EPO_DATE @"EPO_DATE_MARK"

- (void)epoUpdateStart {
    
    if (![self downlaodEpoFile]) {
        return;
    }
    dispatch_async([self bleQueue], ^{
        
        NSString* pathEpo = EPO_PATH;
        NSData* dataEpo = [[NSData alloc] initWithContentsOfFile:pathEpo];
        
        int datatemplength = (int)dataEpo.length;
        int packageLength = datatemplength/DATA_LEN + (datatemplength%DATA_LEN>0?1:0);
        NSString *str = [NSString stringWithFormat:@"%d",packageLength];
        NSData *dataInt = [str dataUsingEncoding:NSUTF8StringEncoding];
        
        int responeBegan = [[BtNotify sharedInstance] send:@"epo_update_data" receiver:@"epo_update_data" dataAction:0 dataToSend:dataInt needProgress:YES sendPriority:SPC_PRIORITY_NORMAL];
        if (responeBegan > 0) {
            NSLog(@"ERROR: send start epo_update_data: %d %d-%@-%@",responeBegan,datatemplength,str,dataInt);
            return;
        }
        [NSThread sleepForTimeInterval:0.8];
        
        int cicleNum = 0;
        for (int i =0; i<dataEpo.length; i += DATA_LEN) {
            
            NSRange range = NSMakeRange(i, DATA_LEN);
            if (i + DATA_LEN > dataEpo.length) {
                range = NSMakeRange(i, dataEpo.length - i);
            }
            NSData *subData = [dataEpo subdataWithRange:range];
            int respone = [[BtNotify sharedInstance] send:@"epo_update_data" receiver:@"epo_update_data" dataAction:1 dataToSend:subData needProgress:YES sendPriority:SPC_PRIORITY_NORMAL];
            if (respone > 0) {
                NSLog(@"ERROR: send epo_update_data :%d count:%d cicleNum:%d",respone,i,++cicleNum);
                return;
            }
            NSLog(@"send epo_update_data :%d count:%d cicleNum:%d",respone,i,++cicleNum);
            [NSThread sleepForTimeInterval:0.08];
        }
        [NSThread sleepForTimeInterval:0.8];
        
        int responeEnd = [[BtNotify sharedInstance] send:@"epo_update_data" receiver:@"epo_update_data" dataAction:2 dataToSend:[@"end" dataUsingEncoding:NSUTF8StringEncoding] needProgress:YES sendPriority:SPC_PRIORITY_NORMAL];
        if (responeEnd > 0) {
            NSLog(@"ERROR: send end epo_update_data: %d ",responeEnd);
            return;
        }
        NSLog(@"send end epo_update_data: %d",responeEnd);
        [NSThread sleepForTimeInterval:3];
        NSString *md5Data = [BKUtils getFileMD5WithPath:pathEpo];
        int response = [[BtNotify sharedInstance] send:@"epo_update_md5" receiver:@"epo_update_md5" dataAction:1 dataToSend:[md5Data dataUsingEncoding:NSUTF8StringEncoding] needProgress:YES sendPriority:SPC_PRIORITY_NORMAL];
        if (response > 0) {
            NSLog(@"ERROR: send epo_update_md5: %d ",response);
            return;
        }
        NSLog(@"send epo_update_md5: %d ",response);
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:EPO_DATE];
    });
}

- (BOOL)downlaodEpoFile {
  /*  NSDate *epoDate = [[NSUserDefaults standardUserDefaults] objectForKey:EPO_DATE];
    NSDate *theDate = [NSDate date];
    
    if ([theDate timeIntervalSinceDate:epoDate] < 24 * 3600) { //24小时 内不重复下载升级文件
        return NO;
    }*/
    
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:EPO_URL options:NSDataReadingMappedIfSafe error:&error];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:EPO_PATH_TMP contents:data attributes:nil];
    if (error || data.length == 0) {
        NSLog(@"epo download failure : %@",error);
        return NO;
    }
    
    if (![fileManager fileExistsAtPath:EPO_PATH]) {
        [fileManager moveItemAtPath:EPO_PATH_TMP toPath:EPO_PATH error:&error];
        if (error) {
            return NO;
        }
    }else { //存在，比较md5
       /* NSString *md5Epo = [BKUtils getFileMD5WithPath:EPO_PATH];
        NSString *md5EpoTmp = [BKUtils getFileMD5WithPath:EPO_PATH_TMP];
        if (epoDate && [md5Epo isEqualToString:md5EpoTmp]) { //epoDate 存在表示上一次升级成功
            return NO; //same file ,needn't update
        }*/
        [fileManager removeItemAtPath:EPO_PATH error:nil];
        [fileManager moveItemAtPath:EPO_PATH_TMP toPath:EPO_PATH error:&error];
        if (error) {
            return NO;
        }
    }
    return YES;
}

- (void)dealloc {
    [[BtNotify sharedInstance] unregisterCustomDelegate:self];
}

@end

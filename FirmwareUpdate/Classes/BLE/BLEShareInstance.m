//
//  BLEShareInstance.m
//  ZLYIwown
//
//  Created by 曹凯 on 15/11/16.
//  Copyright © 2015年 Iwown. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>
#import "BtNotify.h"
#import "BLEShareInstance.h"

//通知
NSString *const kNOTICE_DEVICE_SYNC_END                 = @"notice_device_sync_end";
NSString *const kNOTICE_SYNC_TODAY_SUMMARY_END          = @"notice_sync_29end";
NSString *const kNOTICE_SYNC_TWODAYSDATAEND             = @"notice_sync_twodaysdataend";
NSString *const kNOTICE_SYNC_HEART_RATE_END             = @"notice_sync_heartrate_end";

typedef enum {
    Sch_write = 1,
    Sch_read = 2,
    Sch_readInfo = 3,
    Sch_close = 4,
    Sch_clear = 5,
}sch_cmd_type;

typedef void(^scaleSuccess)(id response);
typedef void(^scaleFailure)(id response);

static BLEShareInstance *shareBLEInstance = nil;
@interface BLEShareInstance ()<SPC_NotifyCustomDelegate>

@property (nonatomic,strong)NSMutableArray *needSetArr;

@end

@implementation BLEShareInstance
{
    //Discovered device
    NSMutableArray        *_deviceArray;

    sch_cmd_type          _schType;
    ZRSchedule            *_schedule;
    NSInteger             _timeOutCount; //日程超时次数
    
    scaleSuccess          _scaleBLESuccessful;
    scaleFailure          _scaleBLEFailure;
    BOOL                  _scaleBLETimeout;
    
    NSInteger             _lightCount;
    
    BLEAutumn             *_bleautumn;
}

+ (BLEShareInstance *)shareInstance {
    @synchronized(shareBLEInstance) {
        if (!shareBLEInstance) {
            shareBLEInstance = [[BLEShareInstance alloc]init];
        }
    }
    return shareBLEInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _bleautumn = [BLEAutumn midAutumn:BLEProtocol_Any];
        _bleautumn.discoverDelegate = self;
        _bleautumn.connectDelegate = self;
        _deviceArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

+ (id<BLESolstice>)bleSolstice {
    return [BLEShareInstance shareInstance].solstice;
}

- (BLEProtocol)bleProtocol {
    return [_bleautumn getBleProtocolType];
}

#pragma mark -device&&state
- (void)scanDevice {
    [_deviceArray removeAllObjects];
    [_bleautumn startScan];
}

- (void)stopScan {
    [_bleautumn stopScan];
}

- (NSArray *)getDevices {
    [_deviceArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        ZRBlePeripheral *run1 = obj1;
        ZRBlePeripheral *run2 = obj2;
        NSInteger rssiA = run1.RSSI.integerValue;
        NSInteger rssiB = run2.RSSI.integerValue;
        return (rssiA < rssiB);
    }];
    return _deviceArray;
}

- (void)unConnectDevice {
    
    self.deviceInfo = nil;
    [[ZRDeviceInfo defaultDeviceInfo] updateDeviceInfo:nil];
    self.solstice = nil;
    [_bleautumn unbind];
}

- (void)connectDevice:(ZRBlePeripheral *)device {
    NSLog(@"=================== %p == %@",device,device);
    [_bleautumn bindDevice:device];
}

- (BOOL)isBinded {
    if (self.state == kBLEstateDisConnected) {
        return NO;
    }
    return YES;
}

- (BOOL)isConnected {
    if (self.state == kBLEstateDidConnected) {
        return YES;
    }
    return NO;
}

- (void)setBLEState:(BOOL)connectted {
    DFUPlatform dPlatform = [self.deviceInfo platformForDfu];
    if (connectted) {
        self.state = kBLEstateDidConnected;
        //update BtNotify state
        if (dPlatform == DFUPlatformMtk) {
            [[BtNotify sharedInstance] updateConnectionState:CBPeripheralStateConnected];
        }
    }else {
        if ([_bleautumn isBound]) {
            self.state = kBLEstateBindUnConnected;
        }else {
            self.state = kBLEstateDisConnected;
        }
        //update BtNotify state
        if (dPlatform == DFUPlatformMtk) {
            [[BtNotify sharedInstance] updateConnectionState:CBPeripheralStateDisconnected];
        }
    }
}

- (CBPeripheral *)getConnectedPeriphral {
    return [[BLEShareInstance bleSolstice] getConnectedPeriphral];
}

#pragma mark- BTNotifyDelegate
- (void)initBtNotifyIfNeed {
    [[BtNotify sharedInstance] registerCustomDelegate:self];
}

-(void)onReadyToSend:(BOOL)ready {
    NSLog(@"%s:%d",__func__,ready);
}

-(void)onDataArrival:(NSString *)receiver arrivalData:(NSData *)data {
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"----data arrived %s:%@ data: %@ - String: %@",__func__,receiver,data,dataStr);
}

-(void)onProgress:(NSString *)sender
      newProgress:(float)progress {
    NSLog(@"%s:%@ : %f",__func__,sender,progress);
}

- (void)responseOfMTKBtNotifyData:(CBCharacteristic *)cbc {
    NSError *error = nil;
    [[BtNotify sharedInstance] handleReadReceivedData:cbc error:error];
    NSLog(@"%s:%@ \nERROR:%@",__func__,cbc,error);
}

- (void)responseOfMTKBtWriteData:(CBCharacteristic *)cbc {
    NSError *error = nil;
    [[BtNotify sharedInstance] handleWriteResponse:cbc error:error];
    NSLog(@"%s:%@ \nERROR:%@",__func__,cbc,error);
}

- (void)requestForStartEpoUpdate {

    [[BLEShareInstance bleSolstice] startEpoUpgrade];
}

- (void)updateEpoLocation:(CLLocation *)location {

    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger time = [zone secondsFromGMTForDate:location.timestamp];
    NSInteger timeZone = time/3600;
    float latitude = location.coordinate.latitude;
    float longitude = location.coordinate.longitude;
    float altitude = location.altitude;
    ZRGnssParam *gp = [[ZRGnssParam alloc] init];
    gp.timeZone = timeZone;
    gp.latitude = latitude;
    gp.longitude = longitude;
    gp.altitude = altitude;
    [[BLEShareInstance bleSolstice] setGNSSParameter:gp];
}
#pragma mark - blelib3Delegate
- (void)centralManagerStatePoweredOn {
}
- (void)centralManagerStatePoweredOff {
}
- (void)solsticeDidDisConnectWithDevice:(ZRBlePeripheral *)device andError:(NSError *)error {
    NSLog(@"%s",__FUNCTION__);
    [self setBLEState:NO];
}

- (void)solsticeDidConnectDevice:(ZRBlePeripheral *)device {
    NSLog(@"%s \n\n",__FUNCTION__);
    [self setBLEState:YES];
    self.solstice = [_bleautumn solstice];
    [_bleautumn registerSolsticeEquinox:self];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"k_deviceDidConnected" object:device];
    });
}

- (void)solsticeDidFailToConnectDevice:(ZRBlePeripheral *)device andError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
    });
}

- (void)solsticeDidDiscoverDeviceWithMAC:(ZRBlePeripheral *)iwDevice {

    if (iwDevice.RSSI.integerValue < -80) {
        return;
    }
    NSString *iwdName = iwDevice.uuidString;
    for (ZRBlePeripheral *zrble in _deviceArray) {
        if ([iwdName isEqualToString:zrble.uuidString]) {
            return;
        }
    }
    [_deviceArray addObject:iwDevice];
}

- (void)solsticeStopScan {
    NSLog(@"%s",__func__);
}

- (NSString *)bleLogPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *foldPath = [documentDirectory stringByAppendingFormat:@"/ble"];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    formatter.calendar = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [formatter setDateFormat:@"yyyy-MM-dd"]; //每天保存一个新的日志文件中
    NSString *dateStr = [formatter stringFromDate:[NSDate date]];
    NSString *logFilePath = [foldPath stringByAppendingFormat:@"/BLE_%@.txt",dateStr];
    return logFilePath;
}

- (void)responseOfConnectStateError {
    [_bleautumn cancelConnect];
    [_bleautumn reConnectDevice];
}

#pragma mark - 
#pragma mark - ble action
- (void)setBLEParameterAfterConnect {
    NSLog(@"%s",__func__);
}

- (void)readRequiredInfoAfterConnect {
    NSLog(@"%s",__func__);
    [self getDeviceInfo];
    NSLog(@"---getDeviceInfo");
    [self getBatteryInfo];
    NSLog(@"---getBatteryInfo");
}

#pragma -mark 心率
//固件升级
- (void)deviceFWUpdate {
    [[BLEShareInstance bleSolstice] deviceUpgrade];
}

- (void)debindFromSystem {}

- (void)getDeviceInfo {
    [[BLEShareInstance bleSolstice] readDeviceInfo];
}

- (void)getBatteryInfo {
    [[BLEShareInstance bleSolstice] readDeviceBattery];
}

#pragma mark - 设备设置回调
- (void)readResponseFromDevice:(ZRReadResponse *)response {
    switch (response.cmdResponse) {
        case CMD_RESPONSE_DEVICE_GET_INFORMATION:
        {
            ZRDeviceInfo *deviceInfo = response.data;
            [self updateDeviceInfo:deviceInfo];
        }
            break;
        case CMD_RESPONSE_DEVICE_GET_BATTERY:
        {
            ZRDeviceInfo *deviceInfo = response.data;
            [self updateBattery:deviceInfo];
        }
            break;
        default:
            break;
    }
}

- (void)updateDeviceInfo:(ZRDeviceInfo *)deviceInfo{
    self.deviceInfo = deviceInfo;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNOTICE_DEVICE_UPDATE" object:deviceInfo];
    });
}

- (void)updateBattery:(ZRDeviceInfo *)deviceInfo{
    self.deviceInfo = deviceInfo;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"kNOTICE_BATTERY_UPDATE" object:deviceInfo];
    });
}

@end

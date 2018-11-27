//
//  DFUViewController.m
//  ZLingyi
//
//  Created by Jackie on 15/1/13.
//  Copyright (c) 2015年 Jackie. All rights reserved.
//
#define DFU_MODEl_IDENTIFIER  @"com.zeroner.dfumode"

/*
 * 进入手环升级页面前
 * 1.蓝牙打开
 * 2.手环连接
 * 3.判断固件是否可为升级，
 * 4.电量足够
 
 * 进入页面后
 * 1.判断固件是TI还是Nordic的
 * 1.1.如果是TI的，直接跳到升级
 * 1.2.如果是Nordic的，判断hex文件是否存在
 * 1.2.1.不存在开始下载hex文件，存在就直接跳到升级

 * 点击升级
 * 1.设置升级模式
 * 2.如果为TI，根据返回结果直接显示升级完成，同时提示用户检查邮件
 * 2.如果为Nordic，查找升级设备
 * 3.升级
 * 4.升级完成删除hex文件
 * 5.升级完跳转到主界面
 * dfuServiceUUIDString
 */
typedef enum{
    DFUErrorNull = 0,
    DFUErrorNoDevice,
    DFUErrorConnectTimeOut,
    DFUErrorSuccess , //no error ,connect success
    DFUErrorUnknow ,

}DFUError;
#import "UploadFirmwareUpdateInfoApi.h"
#import "DownloadFirmwareUpdateInfoApi.h"
#import "FUHandle.h"
#import "DFUViewController.h"
#import "DFUHelper.h"
#import "ScannedPeripheral.h"

@interface DFUViewController () <DFUOperationsDelegate,CBCentralManagerDelegate>
{
    DFUOperations       *_dfuOperations;

    NSMutableArray      *peripherals;
    int                 _percentage;
    
    DfuFirmwareTypes    _dfuFWType;
    DFUHelper           *_dfuHelper;
    
    DFUError            _dfuError;
    BOOL                _error_State;
}

@end

@implementation DFUViewController

@synthesize bluetoothManager;

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    if (self.isDFU) {
        self.tabBarController.tabBar.hidden = NO;
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didUpdateCenterState:) name:@"didUpdateCenterState" object:nil];
    [self setupParam];
    if (self.isDFU) {
        [self requestInfoForDFUHelper];
    }else {
        [self requestForCheckDFU];
    }
}

- (void)signOffDelegate {
    
    [super signOffDelegate];
    [_dfuOperations cancelDFU];
    _dfuOperations.dfuDelegate = nil;
    bluetoothManager.delegate = nil;
}

- (void)dealloc {
    NSLog(@"%s",__func__);
    _dfuOperations.dfuDelegate = nil;
    bluetoothManager.delegate = nil;
}

- (void)setupParam {
    
    PACKETS_NOTIFICATION_INTERVAL = 10;
    _dfuOperations = [[DFUOperations alloc] initWithDelegate:self];
    _dfuHelper = [[DFUHelper alloc]initWithData:_dfuOperations];
    
    dispatch_queue_t centralQueue = dispatch_queue_create("no.nordicsemi.ios.nrftoolbox", DISPATCH_QUEUE_SERIAL);
    bluetoothManager = [[CBCentralManager alloc]initWithDelegate:self queue:centralQueue];
    _percentage = 0;
}

#pragma mark - Action
- (void)udBtnClicked:(id)sender {
    
    [super udBtnClicked:sender];
    switch (self.state) {
        case DFUState_Retry:    //升级
        {
            [self startToScan];
        }
            break;
        case DFUState_Waiting:  //等待
            
            break;
        case DFUState_DownLoadFial: //下载固件失败
        {
            //重新下载
            [self nordicDownloadFirmware];
        }
            break;
        case DFUState_Helper:        //升级助手
        {
            [self entryUpgradeView];
            [self nordicDownloadFirmware];
        }
            break;
        case DFUState_SaveInfo:
        {
        }
            break;
        default:
            break;
    }
}

- (void)prepareDFUUpgrade {
    
    [super prepareDFUUpgrade];
    id content = self.fwContent; 
    if (!content) {
        [self updateUINoNeed];
        return;
    }
    NSString *fwUrl = [content objectForKey:@"download_link"];
    NSString *fwModel = [content objectForKey:@"model"];
    NSString *macAddr = [content objectForKey:@"mac_address"];
    if (!fwUrl || !macAddr || !fwModel) {
        [self updateUINoNeed];
        return;
    }
    
    _fwUrl = fwUrl;
    [self nordicDownloadFirmware];
}

- (void)nordicDownloadFirmware {
    
    [self downloadFirmware:^{
        [self unzipDFUFileIfNeed];
        [self startDFUUpgrade];
    }];
}

- (void)startDFUUpgrade {
    
    NSTimeInterval timeInterval = 0;
    if (!_isDFU) {
        [[BLEShareInstance shareInstance] debindFromSystem];
        [[BLEShareInstance shareInstance] deviceFWUpdate];
        timeInterval = 5;
    }
 
    [self performSelector:@selector(startToScan) withObject:nil afterDelay:timeInterval];
}

- (void)startToScan {
    
    [self updateUIWaiting];
    _dfuError = DFUErrorNull;
    _error_State = NO;
    [self scanForPeripherals:YES];
    [self performSelector:@selector(deviceConectTimeOut) withObject:nil afterDelay:20.0];
}

- (BOOL)updateStateAfterConnectDevice {
    
    if (_error_State) {
        return NO;
    }
    _dfuError = DFUErrorSuccess;
    return YES;
}

- (NSArray *)servicesSids {
    
    NSArray *sIDs = [NSArray arrayWithObjects:[CBUUID UUIDWithString:dfuServiceUUIDString], nil];
    return sIDs;
}
/*!
 * @brief Starts scanning for peripherals with rscServiceUUID
 * @param enable If YES, this method will enable scanning for bridge devices, if NO it will stop scanning
 * @return 0 if success, -1 if Bluetooth Manager is not in CBCentralManagerStatePoweredOn state.
 */
- (int)scanForPeripherals:(BOOL)enable {
    if (bluetoothManager.state != CBManagerStatePoweredOn) {
        return -1;
    }

    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        if (enable) {
            if (self->peripherals == nil) {
                self->peripherals = [NSMutableArray arrayWithCapacity:5];
            }
            else
            {
                [self->peripherals removeAllObjects];
            }
            
            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
            
            self->_dfuError = DFUErrorNoDevice;
            [self->bluetoothManager setDelegate:self];
            [self->bluetoothManager scanForPeripheralsWithServices:[self servicesSids] options:options];
        }else {
            [self->bluetoothManager stopScan];
        }
    });
    return 0;
}

#pragma mark - Central Manage Delegate
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    // Scanner uses other queue to send events. We must edit UI in the main queue
        // Add the sensor to the list and reload deta set
    ZRBlePeripheral *sensor = [[ZRBlePeripheral alloc] initWith:peripheral andAdvertisementData:advertisementData andRSSINumber:RSSI];
    _dfuFWType = APPLICATION;
    NSLog(@"%@",peripheral.name);
    if (peripheral.name != nil) {
        if ([peripheral.name isEqualToString:@"I5+-DFU"]) {
            _dfuFWType = BOOTLOADER;
        }
        [NSThread sleepForTimeInterval:3.0];
    }
    
    if (![peripherals containsObject:sensor])
    {
        [peripherals addObject:sensor];
    }
    else
    {
        sensor = [peripherals objectAtIndex:[peripherals indexOfObject:sensor]];
        sensor.RSSI = RSSI;
    }
    
    NSLog(@"didDiscoverPeripheral: %@, %@",advertisementData,peripheral);
    [self performSelectorOnMainThread:@selector(scanForPeripherals:) withObject:(id)NO waitUntilDone:YES];

    _dfuError = DFUErrorConnectTimeOut;
    [self startDfuWithPeripheral:peripheral];
}

- (void)startDfuWithPeripheral:(CBPeripheral *)peril {
    if (_dfuOperations){
        [_dfuOperations setCentralManager:bluetoothManager];
        [_dfuOperations connectDevice:peril];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    if (central.state == CBManagerStatePoweredOff) {
        [self updateUIFail];
    }
}

#pragma mark - DfuHelper
- (void)requestInfoForDFUHelper {
    
    self.state = DFUState_Helper;
    NSDictionary *fwInfo = (NSDictionary *)[self localSaveModel];
    if (![fwInfo.class isSubclassOfClass:[NSDictionary class]]) {
        self.state = DFUState_Return;
        [self updateUINoData];
        return;
    }
    NSString *url = fwInfo[@"url"];
    BOOL fileExist = [[FUHandle handle] dfuFileIsExist:url];
    if (url && fileExist) { //model 和url有值，且文件存在于本地
        self.state = DFUState_Helper;
        [self updateCheckDFU];
        _fwUrl = url;
        [self unzipDFUFileIfNeed]; //已有升级文件和model，解压
        return;
    }
    [self downloadSaveFWInfo];
}

- (id)localSaveModel {
    
    id dfuInfo = [[NSUserDefaults standardUserDefaults] objectForKey:DFU_MODEl_IDENTIFIER];
    return dfuInfo;
}

- (void)downloadSaveFWInfo {
    
    DownloadFirmwareUpdateInfoApi *api = [[DownloadFirmwareUpdateInfoApi alloc] initWithUid:@"10000"];
    __weak typeof(self) weakself = self;
    [api sendRequestWithCompletionBlockWithSuccess:^(__kindof IWBasicRequest * _Nonnull request) {
        DownloadFirmwareUpdateInfoApi *res = (DownloadFirmwareUpdateInfoApi *)request;
        [weakself saveFwInfoDownloadSuccesful:res];
    } failure:^(__kindof IWBasicRequest * _Nonnull request) {
        [weakself performSelectorOnMainThread:@selector(prepareNoUpdateView) withObject:nil waitUntilDone:YES];
    }];
}

- (void)saveFwInfoDownloadSuccesful:(DownloadFirmwareUpdateInfoApi *)res {
    
    int retCode = [res.responseJSONObject[@"retCode"] intValue];
    if (retCode == 0) {
        _fwUrl = res.url;
        self.state = DFUState_Helper;
        [self performSelectorOnMainThread:@selector(updateCheckDFU) withObject:nil waitUntilDone:YES];
    }else if (retCode == 60001) {
        [self performSelectorOnMainThread:@selector(updateUINoData) withObject:nil waitUntilDone:YES];
    }else if (retCode == 10001 ) {
        [self updateUINoData];
    }else {
        [self performSelectorOnMainThread:@selector(prepareNoUpdateView) withObject:nil waitUntilDone:YES];
    }
}

- (void)unzipDFUFileIfNeed {

    NSString *fullPath = [[FUHandle handle] getFWPath];
    if ([fullPath hasSuffix:@".hex"]) {
        return;
    }
    [self onFileSelected:[NSURL URLWithString:fullPath]];
}

- (NSURL *)getZipFileUrl {

    NSString *fullPath = [[FUHandle handle] getFWPath];
    if ([fullPath hasSuffix:@".hex"]) {
        return nil;
    }
    return [NSURL URLWithString:fullPath];
}

-(void)onFileSelected:(NSURL *)url {
    //处理下载的文件
    _dfuHelper.selectedFileURL = url;
    if (_dfuHelper.selectedFileURL) {
        NSString *selectedFileName = [[url path]lastPathComponent];
        NSData *fileData = [NSData dataWithContentsOfURL:url];
        _dfuHelper.selectedFileSize = fileData.length;
        
        NSString *extension = [selectedFileName substringFromIndex: [selectedFileName length] - 3];
        if ([extension isEqualToString:@"zip"]) {
            _dfuHelper.isSelectedFileZipped = YES;
            _dfuHelper.isManifestExist = NO;
            [_dfuHelper unzipFiles:_dfuHelper.selectedFileURL];
        } else {
            _dfuHelper.isSelectedFileZipped = NO;
        }
    }else {
        NSLog(@"File does not exist");
    }
}

- (void)updateFW {
    NSLog(@"%s",__FUNCTION__);
    if (_dfuFWType != APPLICATION) {
        return;
    }
    
    NSString *firmwareURL = [[FUHandle handle] getFWPath];
    
    [_dfuOperations performDFUOnFile:[NSURL fileURLWithPath:firmwareURL] firmwareType:_dfuFWType];
}

- (void)updateFWWithVersion {
    NSLog(@"%s",__FUNCTION__);
    if (_dfuFWType != APPLICATION) {
        return;
    }
    
    [_dfuOperations performDFUOnFileWithMetaData:_dfuHelper.applicationURL firmwareMetaDataURL:_dfuHelper.applicationMetaDataURL firmwareType:_dfuFWType];
}

- (void)didUpdateCenterState:(BOOL)powerOn {
    if (!powerOn) {
        [self updateUIFail];
    }else {
        [self updateUIReady];
    }
}

#pragma mark DFUOperations delegate methods
- (void)deviceConectTimeOut {

    if (!_error_State) {
        _error_State = YES;
    }

    switch (_dfuError) {
        case DFUErrorNull:
            break;
        case DFUErrorNoDevice:
        {
            NSDictionary *failState = [self getStateParams:@"找不到升级模式下的设备" andDFUState:DFUState_Retry];
            [self updateUIState:failState];
        }
            break;
        case DFUErrorConnectTimeOut:
        {
            NSDictionary *failState = [self getStateParams:@"超时，请重试"  andDFUState:DFUState_Retry];
            [self updateUIState:failState];
        }
            break;
        case DFUErrorSuccess:
            
            break;
        case DFUErrorUnknow:
        {
            NSDictionary *failState = [self getStateParams:@"未知错误" andDFUState:DFUState_Return];
            [self updateUIState:failState];
        }
            break;
            
        default:
            break;
    }
}

- (void)onDeviceConnected:(CBPeripheral *)peripheral {
    NSLog(@"%s %@",__func__,peripheral.name);
    if (_error_State) {
        return;
    }
    _dfuError = DFUErrorSuccess;
    [self updateFW];
}

- (void)onDeviceConnectedWithVersion:(CBPeripheral *)peripheral{
    NSLog(@"onDeviceConnectedWithVersion %@",peripheral.name);
    if (_error_State) {
        return;
    }
    _dfuError = DFUErrorSuccess;
    [self updateFWWithVersion];
}

- (void)onDeviceDisconnected:(CBPeripheral *)peripheral {
    NSLog(@"device disconnected %@",peripheral.name);
}

- (void)onReadDFUVersion:(int)version{
    NSLog(@"onReadDFUVersion %i",version);
}

- (void)onDFUStarted {
    NSLog(@"onDFUStarted");
}

- (void)onDFUCancelled {
    NSLog(@"onDFUCancelled");
}

- (void)onSoftDeviceUploadStarted {
    NSLog(@"onSoftDeviceUploadStarted");
}

- (void)onSoftDeviceUploadCompleted {
    NSLog(@"onSoftDeviceUploadCompleted");
}

- (void)onBootloaderUploadStarted {
    NSLog(@"onBootloaderUploadStarted");
}

- (void)onBootloaderUploadCompleted {
    NSLog(@"onBootloaderUploadCompleted");
}

- (void)onTransferPercentage:(int)percentage {
    NSLog(@"******onTransferPercentage %d",percentage);
    if (_percentage == percentage) {
        return;
    }
    _percentage = percentage;
    [self updateUIPercent:percentage];
}

- (void)onSuccessfulFileTranferred {
    NSLog(@"OnSuccessfulFileTransferred");
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self->_dfuFWType == BOOTLOADER) {
        }else if (self->_dfuFWType == APPLICATION) {
            [self finallySuccessful];
        }
    });
}

- (void)onError:(NSString *)errorMessage {
    NSLog(@"OnError %@",errorMessage);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUIFail];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end

//
//  DFUViewController.m
//  ZLingyi
//
//  Created by Jackie on 15/1/13.
//  Copyright (c) 2015年 Jackie. All rights reserved.
//

/*
 * 进入手环升级页面前
 * 1.蓝牙打开
 * 2.手环连接
 * 3.判断固件是否可为升级，
 * 4.电量大于50%
 
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
#import "IVNetHeader.h"
#import <IVBaseKit/IVBaseKit.h>
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
    
    NSDictionary        *_saveInfoDict;
    NSString            *_cfName;
}

@end

@implementation DFUViewController

@synthesize bluetoothManager;

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.isDFU) {
        self.tabBarController.tabBar.hidden = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupParam];
    if (self.isDFU) {
        [self requestInfoForDFUHelper];
    }else {
        [self requestForCheckDFU:DFUDevice_Bracelet];
    }
}

- (void)signOffDelegate {
    [_dfuOperations cancelDFU];
    _dfuOperations.dfuDelegate = nil;
    bluetoothManager.delegate = nil;
}

- (void)setupParam
{
    PACKETS_NOTIFICATION_INTERVAL = 10;
    _dfuOperations = [[DFUOperations alloc] initWithDelegate:self];
    _dfuHelper = [[DFUHelper alloc]initWithData:_dfuOperations];
    
    dispatch_queue_t centralQueue = dispatch_queue_create("no.nordicsemi.ios.nrftoolbox", DISPATCH_QUEUE_SERIAL);
    bluetoothManager = [[CBCentralManager alloc]initWithDelegate:self queue:centralQueue];
    _percentage = 0;
}

#pragma mark - Action
- (void)udBtnClicked:(id)sender
{
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
            [self saveDFUModel];
        }
            break;
        case DFUState_Start:
        {
            
        }
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
    if (!fwUrl) {
        [self updateUINoNeed];
        return;
    }
    NSString *uid = [[FUHandle shareInstance].delegate fuHandleParamsUid];
    _saveInfoDict = @{@"uid":uid,@"mac":macAddr,@"url":fwUrl,@"model":fwModel};
    [self saveDFUModel];
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
        [[BLELib3 shareInstance] debindFromSystem];
        [[BLELib3 shareInstance] deviceUpdate];
        timeInterval = 5;
        NSString *model = _fwModel;
        if ([model hasPrefix:@"I5+"]) {
            timeInterval = 2.0;
        }
    }
 
    [self performSelector:@selector(startToScan) withObject:nil afterDelay:timeInterval];
}

- (void)startToScan
{
    [self updateUIWaiting];
    _dfuError = DFUErrorNull;
    _error_State = NO;
    [self scanForPeripherals:YES];
    [self performSelector:@selector(deviceConectTimeOut) withObject:nil afterDelay:20.0];
}

/*!
 * @brief Starts scanning for peripherals with rscServiceUUID
 * @param enable If YES, this method will enable scanning for bridge devices, if NO it will stop scanning
 * @return 0 if success, -1 if Bluetooth Manager is not in CBCentralManagerStatePoweredOn state.
 */
- (int) scanForPeripherals:(BOOL)enable
{
    if (bluetoothManager.state != CBCentralManagerStatePoweredOn)
    {
        return -1;
    }

    // Scanner uses other queue to send events. We must edit UI in the main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        if (enable)
        {
            if (peripherals == nil) {
                peripherals = [NSMutableArray arrayWithCapacity:5];
            }
            else
            {
                [peripherals removeAllObjects];
            }
            
            NSArray *sIDs = [NSArray arrayWithObjects:[CBUUID UUIDWithString:dfuServiceUUIDString], nil];
            NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], CBCentralManagerScanOptionAllowDuplicatesKey, nil];
            
            _dfuError = DFUErrorNoDevice;
            [bluetoothManager setDelegate:self];
            [bluetoothManager scanForPeripheralsWithServices:sIDs options:options];
        }
        else
        {
            [bluetoothManager stopScan];
        }
    });
    
    return 0;
}

#pragma mark - Central Manage Delegate
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // Scanner uses other queue to send events. We must edit UI in the main queue
        // Add the sensor to the list and reload deta set
    ScannedPeripheral* sensor = [ScannedPeripheral initWithPeripheral:peripheral rssi:RSSI.intValue];
    _dfuFWType = APPLICATION;
    NSLog(@"%@",peripheral.name);
    if (peripheral.name != nil) {
        if ([peripheral.name isEqualToString:@"I5+-DFU"]) {
            _dfuFWType = BOOTLOADER;
        }else {
            _cfName = [self getFWNameByPeripheral:peripheral];
        }
        [NSThread sleepForTimeInterval:3.0];
    }
    
    if (_cfName && ![_cfName containsString:_fwModel]) {
        return;
    }
    
    if (![peripherals containsObject:sensor])
    {
        [peripherals addObject:sensor];
    }
    else
    {
        sensor = [peripherals objectAtIndex:[peripherals indexOfObject:sensor]];
        sensor.RSSI = RSSI.intValue;
    }
    
    NSLog(@"didDiscoverPeripheral: %@, %@",advertisementData,peripheral);
    [self performSelectorOnMainThread:@selector(scanForPeripherals:) withObject:(id)NO waitUntilDone:YES];

    _dfuError = DFUErrorConnectTimeOut;
    if (_dfuOperations){
        [_dfuOperations setCentralManager:bluetoothManager];
        [_dfuOperations connectDevice:peripheral];
    }
}

- (NSString *)getFWNameByPeripheral:(CBPeripheral *)peripheral
{
    NSString *cfname = nil;
    if ([peripheral.name isEqualToString:@"I5+-DFU"]) {
        
    }else if ([peripheral.name hasPrefix:@"I5+"]) { //默认i5+5，无i5+5，则为i5+3
        cfname = @"I5+5.hex";
        if (![BKUtils isFileExist:cfname]) {
            cfname = @"I5+3.hex";
        }
    }else if ([peripheral.name hasPrefix:@"I7S-"]) { //默认i7s2,无i7s2，则为i7s
        cfname = @"I7S2.zip";
        if (![BKUtils isFileExist:cfname]) {
            cfname = @"I7S.zip";
        }
    }else if ([peripheral.name hasPrefix:@"V6"]) {
        cfname = @"V6.zip";
    }else if ([peripheral.name hasPrefix:@"R1"]) {
        cfname = @"R100.zip";
    }else if ([peripheral.name hasPrefix:@"5P"]) {
        cfname = @"I5PR.zip";
    }else if ([peripheral.name hasPrefix:@"I6"]) {
        cfname = @"I6.zip";
    }
    return cfname;
}

-(void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    if (central.state == CBCentralManagerStatePoweredOn) {
        [self scanForPeripherals:NO];
    }
}

#pragma mark - DfuHelper
- (void)requestInfoForDFUHelper {
    
    self.state = DFUState_Helper;
    NSString *model = nil;
    NSString *url = nil;
    id obj = [self localSaveModel];
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *fwInfo = (NSDictionary *)obj;
        model = fwInfo[@"model"];
        url = fwInfo[@"url"];
    }
    BOOL fileExist = [self dfuFileIsExist:model];
    if (model && url && fileExist) { //model 和url有值，且文件存在于本地
        self.state = DFUState_Helper;
        [self updateCheckDFU];
        _fwModel = model;
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
    
    IVHttpRequest *request = [IVHttpRequest requestWithService:SERVICE_DEVICE api:API_DOWNLOAD_FWINFO parameters:@{@"uid":[[FUHandle shareInstance].delegate fuHandleParamsUid]}];
    [IVHttpClient sendAsyncGetRequest:request completion:^(id responseObj, NSError *error) {
        if (error) {
            [self updateUINoData];
        }else if (isSuccess(responseObj)){
            _fwUrl = responseObj[@"url"];
            _fwModel = responseObj[@"model"];
            self.state = DFUState_Helper;
            [self updateCheckDFU];
        }else if (errorId(responseObj) == IVSERVICE_ERROR_NoData) {
            [self updateUINoData];
        }else {
            [self prepareNoUpdateView];
        }
    }];
}

- (void)saveDFUModel{
    __weak typeof(self) weakSelf = self;
    [self saveDFUModel:_saveInfoDict andSavedSuccessful:^{
        _fwModel = _saveInfoDict[@"model"];
        _fwUrl = _saveInfoDict[@"url"];
        [weakSelf nordicDownloadFirmware];
    }];
}

static NSString *DFU_MODEl_IDENTIFIER = @"com.lingyi.dfumode";
- (void)saveDFUModel:(NSDictionary *)saveInfo andSavedSuccessful:(void(^)())successful{

    [self updateUISaveInfo];
    [[NSUserDefaults standardUserDefaults] setObject:saveInfo forKey:DFU_MODEl_IDENTIFIER];
    
    NSDictionary *params = saveInfo;
    IVHttpRequest *request = [IVHttpRequest requestWithService:SERVICE_DEVICE api:API_UPLOAD_FWINFO parameters:params];
    NSDictionary *failState = [self getStateParams:NSLocalizedString(@"保存信息失败", @"保存信息失败") andDFUState:DFUState_SaveInfo];
    
    [IVHttpClient sendAsyncPostRequest:request completion:^(id responseObj, NSError *error) {
        if (isSuccess(responseObj)){
            [self updateUIReady];
            successful();
        }
        else{
            [self updateUIState:failState];
        }
    }];
}

- (void)unzipDFUFileIfNeed {
    
    NSString *model = _fwModel;
    //i5+使用非.zip格式文件，不需要解压
    if (!model || [model hasPrefix:@"I5+"]) {
        return;
    }

    NSString *fullPath = [[FUHandle shareInstance] getFWPathFromModel:model];
    [self onFileSelected:[NSURL URLWithString:fullPath]];
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
        [Utility showAlert:NSLocalizedString(@"所选文件不存在", nil)];
    }
}

- (void)updateFW {
    NSLog(@"%s",__FUNCTION__);
    if (_dfuFWType != APPLICATION) {
        return;
    }
    
    NSString *firmwareURL = [[FUHandle shareInstance] getFWPathFromModel:_fwModel];
    
    [_dfuOperations performDFUOnFile:[NSURL fileURLWithPath:firmwareURL] firmwareType:_dfuFWType];
}

- (void)updateFWWithVersion
{
    NSLog(@"%s",__FUNCTION__);
    if (_dfuFWType != APPLICATION) {
        return;
    }
    
    [_dfuOperations performDFUOnFileWithMetaData:_dfuHelper.applicationURL firmwareMetaDataURL:_dfuHelper.applicationMetaDataURL firmwareType:_dfuFWType];
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
            NSDictionary *failState = [self getStateParams:NSLocalizedString(@"未找到可升级设备", nil) andDFUState:DFUState_Retry];
            [self updateUIState:failState];
        }
            break;
        case DFUErrorConnectTimeOut:
        {
            NSDictionary *failState = [self getStateParams:NSLocalizedString(@"连接超时，请重试", @"连接超时，请重试") andDFUState:DFUState_Retry];
            [self updateUIState:failState];
        }
            break;
        case DFUErrorSuccess:
            
            break;
        case DFUErrorUnknow:
        {
            NSDictionary *failState = [self getStateParams:NSLocalizedString(@"未知错误，请联系客服", @"未知错误，请联系开发者") andDFUState:DFUState_Return];
            [self updateUIState:failState];
        }
            break;
            
        default:
            break;
    }
}

-(void)onDeviceConnected:(CBPeripheral *)peripheral
{
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

- (void)onDeviceDisconnected:(CBPeripheral *)peripheral
{
    NSLog(@"device disconnected %@",peripheral.name);
}

-(void)onReadDFUVersion:(int)version{
    NSLog(@"onReadDFUVersion %i",version);
}

- (void)onDFUStarted
{
    NSLog(@"onDFUStarted");
}

- (void)onDFUCancelled
{
    NSLog(@"onDFUCancelled");
}

- (void)onSoftDeviceUploadStarted
{
    NSLog(@"onSoftDeviceUploadStarted");
}

- (void)onSoftDeviceUploadCompleted
{
    NSLog(@"onSoftDeviceUploadCompleted");
}

- (void)onBootloaderUploadStarted
{
    NSLog(@"onBootloaderUploadStarted");
}

- (void)onBootloaderUploadCompleted
{
    NSLog(@"onBootloaderUploadCompleted");
}

- (void)onTransferPercentage:(int)percentage
{
    NSLog(@"******onTransferPercentage %d",percentage);
    if (_percentage == percentage)
    {
        return;
    }
    _percentage = percentage;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateUIPercent:percentage];
    });
}

- (void)onSuccessfulFileTranferred
{
    NSLog(@"OnSuccessfulFileTransferred");
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_dfuFWType == BOOTLOADER) {
            [self deleteBootloader];
            _dfuFWType = APPLICATION;
            [self updateUIWaiting];
            [self performSelector:@selector(udBtnClicked:) withObject:(id)_udBtn afterDelay:5.0];
        }
        else if (_dfuFWType == APPLICATION)
        {
            [self finallySuccessful];
        }
    });
}

- (void)onError:(NSString *)errorMessage
{
    NSLog(@"OnError %@",errorMessage);

    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancle];
        [self presentViewController:alert animated:YES completion:nil];
        [self updateUIFail];
    });
}

- (void)dealloc{
    _dfuOperations.dfuDelegate = nil;
    bluetoothManager.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end

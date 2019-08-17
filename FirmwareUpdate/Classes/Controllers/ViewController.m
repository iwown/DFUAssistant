//
//  ViewController.m
//  FirmwareUpdate
//
//  Created by west on 16/9/19.
//  Copyright © 2016年 west. All rights reserved.
//

#import "ViewController.h"

#import "FirmwareListController.h"

#import "DeviceConectController.h"

#import "PercentView.h"

#import "SSZipArchive.h"


@interface ViewController ()<FirmwareListControllerDelegate, DeviceConectControllerDelegate, SSZipArchiveDelegate>
{
    UILabel             *_nameLabel;
    UILabel             *_sizeLabel;
    UILabel             *_typeLabel;
    UILabel             *_deviceLabel;
    NSString            *_selectUrlString;
    
    DFUOperations       *_dfuOperations;
    DFUHelper           *_dfuHelper;
    DfuFirmwareTypes    _dfuFWType;
    
    CBPeripheral        *_peripheral;
    int                 _percentage;
    
    NSInteger           _canDFUType;
    
    PercentView         *_percentView;
    
    UIButton            *_upgradeBtn;
    UIView              *_coverView;
    
    BOOL                __StartByAutoCycle;
}

@end

@implementation ViewController

@synthesize bluetoothManager;
- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self loadData];
    [self drawUI];
}

- (void)loadData {
    _dfuOperations = [[DFUOperations alloc] initWithDelegate:self];
    _dfuHelper = [[DFUHelper alloc] initWithData:_dfuOperations];
    _dfuFWType = APPLICATION;
    _percentage = 0;
}

- (void)drawUI {
    self.title = @"DFU";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIView *firmwareView = [[UIView alloc] initWithFrame:CGRectMake(40, 100, SCREEN_WIDTH - 80, 200)];
    firmwareView.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1.0];
    firmwareView.userInteractionEnabled = YES;
    [self.view addSubview:firmwareView];
    
    _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH - 100, 30)];
    _nameLabel.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1.0];
    _nameLabel.text = @"Name:";
    [firmwareView addSubview:_nameLabel];
    
    _sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, SCREEN_WIDTH - 100, 30)];
    _sizeLabel.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1.0];
    _sizeLabel.text  =@"Size:";
    [firmwareView addSubview:_sizeLabel];
    
    _typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 110, SCREEN_WIDTH - 100, 30)];
    _typeLabel.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1.0];
    _typeLabel.text = @"Type:";
    [firmwareView addSubview:_typeLabel];
    
    _deviceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 150, SCREEN_WIDTH - 100, 50)];
    _deviceLabel.backgroundColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1.0];
    _deviceLabel.text = @"Device:";
    [firmwareView addSubview:_deviceLabel];
    
    UIButton *selectFirmwareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectFirmwareBtn.frame = CGRectMake((SCREEN_WIDTH - 140) / 2, SCREEN_HEIGHT - 230, 140, 30);
    selectFirmwareBtn.backgroundColor = [UIColor whiteColor];
    [selectFirmwareBtn setTitle:@"Select Files" forState:UIControlStateNormal];
    [selectFirmwareBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [selectFirmwareBtn addTarget:self action:@selector(selectFirmWare) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:selectFirmwareBtn];
    
    UIButton *selectDeviceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectDeviceBtn.frame = CGRectMake((SCREEN_WIDTH - 140) / 2, SCREEN_HEIGHT - 170, 140, 30);
    selectDeviceBtn.backgroundColor = [UIColor whiteColor];
    [selectDeviceBtn setTitle:@"Scan Device" forState:UIControlStateNormal];
    [selectDeviceBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [selectDeviceBtn addTarget:self action:@selector(selectDevice) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:selectDeviceBtn];
    
    UIButton *upgradeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    upgradeBtn.frame = CGRectMake((SCREEN_WIDTH - 140) / 2, SCREEN_HEIGHT - 110, 140, 30);
    upgradeBtn.backgroundColor = [UIColor whiteColor];
    [upgradeBtn setTitle:@"Upgrade" forState:UIControlStateNormal];
    [upgradeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [upgradeBtn addTarget:self action:@selector(upgradeDevice) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:upgradeBtn];
    _upgradeBtn = upgradeBtn;
}

- (void)selectFirmWare {
    FirmwareListController *con = [[FirmwareListController alloc] init];
    con.delegate = self;
    [self.navigationController pushViewController:con animated:YES];
}

- (void)selectDevice {
    DeviceConectController *con = [[DeviceConectController alloc] init];
    con.autoUpgrading = __StartByAutoCycle;
    con.uuids = self.uuids;
    con.delegate = self;
    [self.navigationController pushViewController:con animated:YES];
}

- (void)upgradeDevice {
    if ([_selectUrlString length] <= 0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Message" message:@"Please choose a firmware files" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self.navigationController presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    if (!_canDFUType) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Message" message:@"Please connect the DFU device" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [self.navigationController presentViewController:alertController animated:YES completion:nil];
        return;
    }
    
    if (_canDFUType == 1) {
        [_dfuOperations performDFUOnFile:[NSURL fileURLWithPath:_selectUrlString] firmwareType:_dfuFWType];
    }
    else if (_canDFUType == 2) {
        [_dfuOperations performDFUOnFileWithMetaData:_dfuHelper.applicationURL firmwareMetaDataURL:_dfuHelper.applicationMetaDataURL firmwareType:_dfuFWType];
    }
}

- (void)handleUrlString:(NSString *)urlString {
    NSArray *array = [urlString componentsSeparatedByString:@"/"];
    _nameLabel.text = [NSString stringWithFormat:@"Name: %@", array.lastObject];
    array = [urlString componentsSeparatedByString:@"."];
    _typeLabel.text = [NSString stringWithFormat:@"Type: %@", array.lastObject];
    float size = [FileManager fileSizeAtPath:urlString];
    _sizeLabel.text = [NSString stringWithFormat:@"Size: %.2f", size];
    _selectUrlString = urlString;
    [self onFileSelected:[NSURL URLWithString:urlString]];
}

- (void)updateUIPercent:(NSInteger)percentage {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_percentView.percent = percentage;
    });
}

- (void)updateUIStart {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self drawPercentView];
    });
}

- (void)updateUIComplete {
    _canDFUType = 0;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removePercentView];
    });
}

- (void)updateUIFail {
    
}

#pragma mark - FirmwareListControllerDelegate
- (void)selectFirmware:(NSString *)path {
    [self handleUrlString:path];
}

#pragma mark -  DfuHelper
- (void)onFileSelected:(NSURL *)url {
    NSLog(@"onFileSelected");
    _dfuHelper.selectedFileURL = url;
    if (_dfuHelper.selectedFileURL) {
        NSLog(@"selectedFile URL %@",_dfuHelper.selectedFileURL);
        NSString *selectedFileName = [[url path] lastPathComponent];
        NSData *fileData = [NSData dataWithContentsOfURL:url];
        _dfuHelper.selectedFileSize = fileData.length;
        NSLog(@"fileSelected %@",selectedFileName);
        
        //get last three characters for file extension
        NSString *extension = [selectedFileName substringFromIndex: [selectedFileName length] - 3];
        NSLog(@"selected file extension is %@",extension);
        if ([extension isEqualToString:@"zip"]) {
            NSLog(@"this is zip file");
            _dfuHelper.isSelectedFileZipped = YES;
            _dfuHelper.isManifestExist = NO;
            [_dfuHelper unzipFiles:_dfuHelper.selectedFileURL];
            if (!_dfuHelper.applicationURL) {
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Message" message:@"Zip file error" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
                [alertController addAction:cancelAction];
                [self.navigationController presentViewController:alertController animated:YES completion:nil];
            }
        }
        else {
            _dfuHelper.isSelectedFileZipped = NO;
        }
    }
    else {
        [Utility showAlert:@"Selected file not exist!"];
    }
    
    NSLog(@"%@\n%@", _dfuHelper.applicationURL, _dfuHelper.applicationMetaDataURL);
}

- (void)startDfuWithPeripheral:(CBPeripheral *)peril {
    [_dfuOperations setCentralManager:bluetoothManager];
    [_dfuOperations connectDevice:_peripheral];
}

- (void)cycleUpgrading {
    if (!self.autoUpgrading) {
        return;
    }
    __StartByAutoCycle = self.autoUpgrading;
    [self selectDevice];
}

#pragma mark - DeviceConectControllerDelegate
- (void)centralManager:(CBCentralManager *)centralManager ConnectSuccessPeripheral:(CBPeripheral *)peripheral {
    _peripheral = peripheral;
    bluetoothManager = centralManager;
    _deviceLabel.text = [NSString stringWithFormat:@"Device: %@", _peripheral.name];
    if (_peripheral && bluetoothManager) {
        [self startDfuWithPeripheral:_peripheral];
    }
}

#pragma mark - DFUOperations delegate methods
- (void)onDeviceConnected:(CBPeripheral *)peripheral {
    NSLog(@"onDeviceConnected %@",peripheral.name);
    _canDFUType = 1;
}

- (void)onDeviceConnectedWithVersion:(CBPeripheral *)peripheral{
    NSLog(@"onDeviceConnectedWithVersion %@",peripheral.name);
    _canDFUType = 2;
}

- (void)onDeviceDisconnected:(CBPeripheral *)peripheral {
    NSLog(@"device disconnected %@",peripheral.name);
    _canDFUType = 0;
}

-(void)onReadDFUVersion:(int)version {
    NSLog(@"onReadDFUVersion %i",version);
}

- (void)onDFUStarted {
    NSLog(@"onDFUStarted");
    [self updateUIStart];
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
    [self updateUIComplete];
}

- (void)onError:(NSString *)errorMessage {
    NSLog(@"OnError %@",errorMessage);
}

- (void)drawPercentView {
    [self removePercentView];
    _percentView = [[PercentView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _percentView.backgroundColor = [UIColor colorWithRed:80 / 255.0 green:80 / 255.0 blue:80 / 255.0 alpha:0.4];
    [self.view addSubview:_percentView];
}

- (void)removePercentView {
    if (_percentView) {
        for (UIView *view in _percentView.subviews) {
            [view removeFromSuperview];
        }
        [_percentView removeFromSuperview];
        _percentView = nil;
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

- (void)dealloc {
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


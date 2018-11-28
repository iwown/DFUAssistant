//
//  DUViewController.m
//  FirmwareUpdate
//
//  Created by 曹凯 on 2016/11/7.
//  Copyright © 2016年 west. All rights reserved.
//
#import "PercentView.h"
#import "BlueViewController.h"
#import "DUViewController.h"
#import "Defines.h"
#import "BluetoothManager.h"
#import "DeviceStorage.h"
#import "FirmwareListController.h"

#define UIALERTVIEW_TAG_REBOOT 1
@interface DUViewController ()<UITableViewDelegate,UITableViewDataSource,FirmwareListControllerDelegate>
@property (nonatomic ,strong)PercentView *percentView;
@property (nonatomic ,strong)UITableView *tableView;
@property (nonatomic ,strong)NSArray *titleArray;
@property (nonatomic ,strong)NSMutableArray *valueArray;

@property (nonatomic ,strong)GenericServiceManager *device;
@property (nonatomic ,strong)NSString *firmwareURL;
@end

@implementation DUViewController
@synthesize blockSize;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"SOUTA升级";
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didConnectToDevice:)
                                                 name:BluetoothManagerConnectedToDevice
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateValueForCharacteristic:)
                                                 name:GenericServiceManagerDidReceiveValue
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didSendValueForCharacteristic:)
                                                 name:GenericServiceManagerDidSendValue
                                               object:nil];
    [self initParam];
    [self initUI];
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self name:GenericServiceManagerDidReceiveValue object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:GenericServiceManagerDidSendValue object:nil];
}

- (void)initParam {
    self.titleArray = @[@"设备名称",@"Model nr.",@"Firmware",@"版本"];
    self.valueArray = [NSMutableArray arrayWithCapacity:0];
    [self.valueArray addObjectsFromArray:@[@"",@"",@"",@""]];
}

- (void)setupParam {
    self.memoryType = MEM_TYPE_SUOTA_SPI;
    self.spiMOSIAddress = 1;
    self.spiMISOAddress = 2;
    self.spiCSAddress = 5;
    self.spiSCKAddress = 0;
    self.blockSize = 240;
    self.memoryBank = 0;
    
    CBPeripheral *peripheral = self.device.device;
    manager = [[SUOTAServiceManager alloc] initWithDevice:peripheral];
    [manager discoverServices];

    storage = [ParamaterStorage getInstance];
    storage.manager = manager;
}

- (void)initUI {
    self.view.backgroundColor = [UIColor whiteColor];
    [self drawTableView];
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

- (void)didConnectToDevice:(NSNotification*)notification {
    self.device = [GenericServiceManager getInstanceForDevice:notification.object];
    [self.valueArray replaceObjectAtIndex:0 withObject:self.device.deviceName];
    [self.tableView reloadData];
    [self setupParam];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)drawTableView {
    
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-164) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    [self.tableView setTableFooterView:({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(SCREEN_WIDTH*0.25, 20, SCREEN_WIDTH*0.5, 60)];
        [btn setBackgroundColor:[UIColor colorWithRed:92/255.0 green:193/255.0 blue:147/255.0 alpha:1]];
        [btn setTitle:@"升级" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(startForDFU) forControlEvents:UIControlEventTouchUpInside];
        [btn.layer setMasksToBounds:YES];
        [btn.layer setCornerRadius:5];
        [view addSubview:btn];
        view;
    })];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
  
    if (indexPath.row == 3) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.textLabel.text = _titleArray[indexPath.row];
    cell.detailTextLabel.text = _valueArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self.navigationController pushViewController:[BlueViewController new] animated:YES];
    }else if (indexPath.row == 1) {
        [self.valueArray replaceObjectAtIndex:1 withObject:[self getSoutaName]];
        [tableView reloadData];
    }else if (indexPath.row == 2) {
        FirmwareListController *con = [[FirmwareListController alloc] init];
        con.delegate = self;
        [self.navigationController pushViewController:con animated:YES];
    }
}

- (void)startForDFU {
    if (!self.firmwareURL || !self.device) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"找不到设备或文件，无法升级" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
        [alert show];
        return;
    }
    step = 1;
    [self doStep];
    [self updateUIWaiting];
}

- (void)selectFirmware:(NSString *)path {
    NSArray *array = [path componentsSeparatedByString:@"/"];
    [_valueArray replaceObjectAtIndex:2 withObject:[array lastObject]];
    [self.tableView reloadData];
    
    self.firmwareURL = path;
    storage.file_url = [NSURL fileURLWithPath:path];
    
    [manager notification:[manager IntToCBUUID:SPOTA_SERVICE_UUID] characteristicUUID:[CBUUID UUIDWithString:SPOTA_SERV_STATUS_UUID] p:manager.device on:YES];
}

- (void)updateUIAferComplete {
  
}

- (void)updateUIWaiting {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self drawPercentView];
    });
}

- (void)updateUIPercent:(NSInteger)percentage {
    _percentView.percent = percentage;
}

static int nameIndex = 0;
- (NSString *)getSoutaName {
    nameIndex ++;
    NSArray *arr = @[@"I6HR",@"I6"];
    int index = nameIndex%(arr.count);
    return arr[index];
}

#pragma mark SUOTA
- (void)debug:(NSString*)message {
    NSLog(@"%@", message);
}

- (void) appendChecksum {
    uint8_t crc_code = 0;
    
    const char *bytes = [fileData bytes];
    for (int i = 0; i < [fileData length]; i++) {
        crc_code ^= bytes[i];
    }
    
    [self debug:[NSString stringWithFormat:@"Checksum for file: %#4x", crc_code]];
    
    [fileData appendBytes:&crc_code length:sizeof(uint8_t)];
}

- (void) didUpdateValueForCharacteristic: (NSNotification*)notification {
    CBCharacteristic *characteristic = (CBCharacteristic*) notification.object;
    if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:SPOTA_SERV_STATUS_UUID]]) {
        char value;
        [characteristic.value getBytes:&value length:sizeof(char)];
        
        NSString *message = [self getErrorMessage:value];
        [self debug:message];
        
        if (expectedValue != 0) {
            // Check if value equals the expected value
            if (value == expectedValue) {
                // If so, continue with the next step
                step = nextStep;
                
                expectedValue = 0; // Reset
                
                [self doStep];
            } else {
                // Else display an error message
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alertView show];
                
                expectedValue = 0; // Reset
                [autoscrollTimer invalidate];
            }
        }
    }
}

- (void) didSendValueForCharacteristic: (NSNotification*)notification {
    if (step) {
        [self doStep];
    }
}

- (void) doStep {
    [self debug:[NSString stringWithFormat:@"*** Next step: %d", step]];
    
    switch (step) {
            case 1: {
                // Step 1: Set memory type
                
                step = 0;
                expectedValue = 0x10;
                nextStep = 2;
                
                int _memDevData = (self.memoryType << 24) | (self.memoryBank & 0xFF);
                [self debug:[NSString stringWithFormat:@"Sending data: %#10x", _memDevData]];
                NSData *memDevData = [NSData dataWithBytes:&_memDevData length:sizeof(int)];
                [manager writeValue:[manager IntToCBUUID:SPOTA_SERVICE_UUID] characteristicUUID:[CBUUID UUIDWithString:SPOTA_MEM_DEV_UUID] p:manager.device data:memDevData];
                break;
            }
            
            case 2: {
                // Step 2: Set memory params
                int _memInfoData;
                if (self.memoryType == MEM_TYPE_SUOTA_SPI) {
                    _memInfoData = (self.spiMISOAddress << 24) | (self.spiMOSIAddress << 16) | (self.spiCSAddress << 8) | self.spiSCKAddress;
                } else if (self.memoryType == MEM_TYPE_SUOTA_I2C) {
                    _memInfoData = (self.i2cAddress << 16) | (self.i2cSCLAddress << 8) | self.i2cSDAAddress;
                }else { //Useless condition
                    _memInfoData = 0;
                }
                [self debug:[NSString stringWithFormat:@"Sending data: %#10x", _memInfoData]];
                NSData *memInfoData = [NSData dataWithBytes:&_memInfoData length:sizeof(int)];
                
                step = 3;
                [manager writeValue:[manager IntToCBUUID:SPOTA_SERVICE_UUID] characteristicUUID:[CBUUID UUIDWithString:SPOTA_GPIO_MAP_UUID] p:manager.device data:memInfoData];
                break;
            }
            
            case 3: {
                // Load patch data
                [self debug:[NSString stringWithFormat:@"Loading data from %@", [storage.file_url absoluteString]]];
                fileData = [[NSData dataWithContentsOfURL:storage.file_url] mutableCopy];
                [self appendChecksum];
                [self debug:[NSString stringWithFormat:@"Size: %d", (int) [fileData length]]];
                
                // Step 3: Set patch length
                chunkSize = 20;
                blockStartByte = 0;
                
                step = 4;
                [self doStep];
                break;
            }
            
            case 4: {
                // Set patch length
                //UInt16 blockSizeLE = (blockSize & 0xFF) << 8 | (((blockSize & 0xFF00) >> 8) & 0xFF);
                
                //            [self debug:[NSString stringWithFormat:@"Sending data: %#6x", blockSize]];
                NSData *patchLengthData = [NSData dataWithBytes:&blockSize length:sizeof(UInt16)];
                
                step = 5;
                
                [manager writeValue:[manager IntToCBUUID:SPOTA_SERVICE_UUID] characteristicUUID:[CBUUID UUIDWithString:SPOTA_PATCH_LEN_UUID] p:manager.device data:patchLengthData];
                //[manager readValue:[manager IntToCBUUID:SPOTA_SERVICE_UUID] characteristicUUID:[CBUUID UUIDWithString:SPOTA_PATCH_LEN_UUID] p:manager.device];
                break;
            }
            
            case 5: {
                // Send current block in chunks of 20 bytes
                step = 0;
                expectedValue = 0x02;
                nextStep = 5;
                
                int dataLength = (int) [fileData length];
                int chunkStartByte = 0;
                
                while (chunkStartByte < blockSize) {
                    
                    // Check if we have less than current block-size bytes remaining
                    int bytesRemaining = blockSize - chunkStartByte;
                    if (bytesRemaining < chunkSize) {
                        chunkSize = bytesRemaining;
                    }
                    
                    [self debug:[NSString stringWithFormat:@"Sending bytes %d to %d (%d/%d) of %d", blockStartByte + chunkStartByte, blockStartByte + chunkStartByte + chunkSize, chunkStartByte, blockSize, dataLength]];
                    
                    double progress = (double)(blockStartByte + chunkStartByte + chunkSize) / (double)dataLength;
                    NSInteger percent = progress*100;
                    [self updateUIPercent:percent];
                    // Step 4: Send next n bytes of the patch
                    char bytes[chunkSize];
                    [fileData getBytes:bytes range:NSMakeRange(blockStartByte + chunkStartByte, chunkSize)];
                    NSData *byteData = [NSData dataWithBytes:&bytes length:sizeof(char)*chunkSize];
                    
                    // On to the chunk
                    chunkStartByte += chunkSize;
                    
                    // Check if we are passing the current block
                    if (chunkStartByte >= blockSize) {
                        // Prepare for next block
                        blockStartByte += blockSize;
                        
                        int bytesRemaining = dataLength - blockStartByte;
                        if (bytesRemaining == 0) {
                            nextStep = 6;
                            
                        } else if (bytesRemaining < blockSize) {
                            blockSize = bytesRemaining;
                            nextStep = 4; // Back to step 4, setting the patch length
                        }
                    }
                    
                    [manager writeValueWithoutResponse:[manager IntToCBUUID:SPOTA_SERVICE_UUID] characteristicUUID:[CBUUID UUIDWithString:SPOTA_PATCH_DATA_UUID] p:manager.device data:byteData];
                }
                
                break;
            }
            
            case 6: {
                // Send SUOTA END command
                step = 0;
                expectedValue = 0x02;
                nextStep = 7;
                
                int suotaEnd = 0xFE000000;
                [self debug:[NSString stringWithFormat:@"Sending data: %#10x", suotaEnd]];
                NSData *suotaEndData = [NSData dataWithBytes:&suotaEnd length:sizeof(int)];
                [manager writeValue:[manager IntToCBUUID:SPOTA_SERVICE_UUID] characteristicUUID:[CBUUID UUIDWithString:SPOTA_MEM_DEV_UUID] p:manager.device data:suotaEndData];
                break;
            }
            
            case 7: {
                // Wait for user to confirm reboot
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"升级完成", @"Device has been updated") message:NSLocalizedString(@"为了保证所有功能正常使用，请在“设置”->“蓝牙”中忽略设备，并在设备重启后重新绑定连接",@"Do you wish to reboot the device?") delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", @"NO") otherButtonTitles:NSLocalizedString(@"OK", @"Yes, reboot"), nil];
                [alert setTag:UIALERTVIEW_TAG_REBOOT];
                [alert show];
                break;
            }
            
            case 8: {
                // Go back to overview of devices
                [self updateUIAferComplete];
                break;
            }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [autoscrollTimer invalidate];
    
    if (alertView.tag == UIALERTVIEW_TAG_REBOOT) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            // Send reboot signal to device
            step = 8;
            int suotaEnd = 0xFD000000;
            [self debug:[NSString stringWithFormat:@"Sending data: %#10x", suotaEnd]];
            NSData *suotaEndData = [NSData dataWithBytes:&suotaEnd length:sizeof(int)];
            [manager writeValue:[manager IntToCBUUID:SPOTA_SERVICE_UUID] characteristicUUID:[CBUUID UUIDWithString:SPOTA_MEM_DEV_UUID] p:manager.device data:suotaEndData];
            [self updateUIAferComplete];
        }
    }
}


- (NSString*) getErrorMessage:(SPOTA_STATUS_VALUES)status {
    NSString *message;
    
    switch (status) {
            case SPOTAR_SRV_STARTED:
            message = @"Valid memory device has been configured by initiator. No sleep state while in this mode";
            break;
            
            case SPOTAR_CMP_OK:
            message = @"SPOTA process completed successfully.";
            break;
            
            case SPOTAR_SRV_EXIT:
            message = @"Forced exit of SPOTAR service.";
            break;
            
            case SPOTAR_CRC_ERR:
            message = @"Overall Patch Data CRC failed";
            break;
            
            case SPOTAR_PATCH_LEN_ERR:
            message = @"Received patch Length not equal to PATCH_LEN characteristic value";
            break;
            
            case SPOTAR_EXT_MEM_WRITE_ERR:
            message = @"External Mem Error (Writing to external device failed)";
            break;
            
            case SPOTAR_INT_MEM_ERR:
            message = @"Internal Mem Error (not enough space for Patch)";
            break;
            
            case SPOTAR_INVAL_MEM_TYPE:
            message = @"Invalid memory device";
            break;
            
            case SPOTAR_APP_ERROR:
            message = @"Application error";
            break;
            
            // SUOTAR application specific error codes
            case SPOTAR_IMG_STARTED:
            message = @"SPOTA started for downloading image (SUOTA application)";
            break;
            
            case SPOTAR_INVAL_IMG_BANK:
            message = @"Invalid image bank";
            break;
            
            case SPOTAR_INVAL_IMG_HDR:
            message = @"Invalid image header";
            break;
            
            case SPOTAR_INVAL_IMG_SIZE:
            message = @"Invalid image size";
            break;
            
            case SPOTAR_INVAL_PRODUCT_HDR:
            message = @"Invalid product header";
            break;
            
            case SPOTAR_SAME_IMG_ERR:
            message = @"Same Image Error";
            break;
            
            case SPOTAR_EXT_MEM_READ_ERR:
            message = @"Failed to read from external memory device";
            break;
            
        default:
            message = @"Unknown error";
            break;
    }
    
    return message;
}

@end

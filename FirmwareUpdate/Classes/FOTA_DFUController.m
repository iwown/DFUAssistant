//
//  FOTA_DFUController.m
//  FirmwareUpdate
//
//  Created by A$CE on 2017/9/20.
//  Copyright © 2017年 west. All rights reserved.
//
#import "BtNotify.h"
#import "FUHandle.h"
#import "BLEShareInstance.h"
#import "FOTA_DFUController.h"

@interface FOTA_DFUController ()<SPC_NotifyFotaDelegate>
{
    BOOL _timeOutFlag;
}
@end

@implementation FOTA_DFUController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[BLEShareInstance shareInstance] initBtNotifyIfNeed];
    [self setBTNotifyParamsIfNeed];
    [self checkReadyForSetFota];
}

- (void)checkReadyForSetFota {
    
    BOOL isReady = [[BtNotify sharedInstance] isReadyToSend];
    if (isReady) {
        [self requestForCheckDFU];
        _timeOutFlag = YES;
    }else {
        [self performSelector:@selector(checkReadyForSetFota) withObject:nil afterDelay:1.5];
    }
}

- (void)startDFUUpgrade {
    
    NSString *firmwareURL = [[FUHandle handle] getFWPath];
    NSLog(@"firmwair URL %@",firmwareURL);
    [[BtNotify sharedInstance] registerFotaDelegate:self];
    BOOL isReady = [[BtNotify sharedInstance] isReadyToSend];
    
    NSData* data = [[NSData alloc] initWithContentsOfFile:firmwareURL];
    int response = [[BtNotify sharedInstance] sendFotaData:SPC_FBIN_FOTA_UPDATE firmwareData:data];
    
    NSLog(@"isReadyToSend: %d : %d",isReady,response);
    if (isReady == 1 && response != SPC_ERROR_CODE_NOT_HANDSHAKE_DONE) {
        [self updateUIWaiting];
        [self performSelector:@selector(isFotaUpgradeTimeOut) withObject:nil afterDelay:15];
    }else {
        [self updateUIFail];
    }
}

- (void)prepareDFUUpgrade {
    [super prepareDFUUpgrade];
    NSDictionary *content = self.fwContent;
    if (!content) {
        [self updateUINoNeed];
        return;
    }
    NSString *fwURL = [content objectForKey:@"download_link"];
    
    if (!fwURL) {
        [self updateUINoNeed];
        return;
    }
    _fwUrl = fwURL;
    
    __weak typeof(self) weakself = self;
    [self downloadFirmware:^{
        [weakself startDFUUpgrade];
    }];
}

-(void)onFotaProgress:(float)progress {
    
    if (_timeOutFlag) {_timeOutFlag = NO;}
    
    int pencent = (int)(progress * 100);
    if(pencent == 100) {
        [self updateUIAferComplete];
        [self newCompleteAnimationView];
    }else{
        [self updateUIPercent:pencent];
    }
}

- (void)udBtnClicked:(id)sender {
    [super udBtnClicked:sender];
    switch (self.state) {
        case DFUState_Retry:    //升级
        {
            [self startDFUUpgrade];
        }
            break;
        default:
            break;
    }
}

- (void)isFotaUpgradeTimeOut {
    if (!_timeOutFlag) {return;}
    [self updateUIFail];
}

static NSString *const kDOGPReadCharUUIDString = @"00002aa0-0000-1000-8000-00805f9b34fb";
static NSString *const kDOGPWriteCharUUIDString = @"00002aa1-0000-1000-8000-00805f9b34fb";
- (void)setBTNotifyParamsIfNeed {
    
    CBPeripheral *p = [[BLEShareInstance shareInstance] getConnectedPeriphral];
    
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

//
//  FOTA_DFUController.m
//  FirmwareUpdate
//
//  Created by A$CE on 2017/9/20.
//  Copyright © 2017年 west. All rights reserved.
//

#import "FUHandle.h"
#import "BtNotify.h"
#import "FOTA_DFUController.h"

@interface FOTA_DFUController ()<NotifyFotaDelegate>

@end

@implementation FOTA_DFUController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self requestForCheckDFU:DFUDevice_Bracelet];
    // Do any additional setup after loading the view.
}

- (void)startDFUUpgrade {
    NSString *firmwareURL = [[FUHandle shareInstance] getFWPathFromModel:_fwModel];
    NSLog(@"firmwair URL %@",firmwareURL);
    [[BtNotify sharedInstance] registerFotaDelegate:self];
    BOOL isReady = [[BtNotify sharedInstance] isReadyToSend];
    
//    NSString* path = [[NSBundle mainBundle] pathForResource:@"F1_Firmware" ofType:@"bin"];
    NSData* data = [[NSData alloc] initWithContentsOfFile:firmwareURL];
    int response = [[BtNotify sharedInstance] sendFotaData:FBIN_FOTA_UPDATE firmwareData:data];
    
    NSLog(@"isReadyToSend: %d : %d",isReady,response);
    [self updateUIWaiting];
}

- (void)prepareDFUUpgrade {
    [super prepareDFUUpgrade];
    NSDictionary *content = self.fwContent;
    if (!content) {
        [self updateUINoNeed];
        return;
    }
    NSString *fwURL = [content objectForKey:@"download_link"];
    NSString *fwModel = [content objectForKey:@"model"];
    
    if (!fwURL || !fwModel) {
        return;
    }
    _fwModel = fwModel;
    _fwUrl = fwURL;
    [self downloadFirmware:^{
        [self startDFUUpgrade];
    }];
}

-(void)onFotaProgress:(float)progress {
    int pencent = (int)(progress * 100);
    [self updateUIPercent:pencent];
    if(pencent == 100) {
        [self updateUIAferComplete];
    }
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

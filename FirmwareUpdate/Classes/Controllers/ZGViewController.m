//
//  ZGViewController.m
//  FirmwareUpdate
//
//  Created by A$CE on 2018/8/2.
//  Copyright © 2018年 west. All rights reserved.
//

#import "ZGViewController.h"
#import <iOSDFULibrary/iOSDFULibrary-Swift.h>

@interface ZGViewController ()<DFUProgressDelegate,DFUServiceDelegate,LoggerDelegate>
{
    NSURL *_zipUrl;
}
@end

@implementation ZGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)onFileSelected:(NSURL *)url {
    _zipUrl = url;
}

- (void)startDfuWithPeripheral:(CBPeripheral *)peril {
    
    NSURL *url = _zipUrl;
    if (!url) {
        [self updateUIFail];
        return;
    }
    //create a DFUFirmware object using a NSURL to a Distribution Packer(ZIP)
    DFUFirmware *selectedFirmware = [[DFUFirmware alloc] initWithUrlToZipFile:url];// or
    //Use the DFUServiceInitializer to initialize the DFU process.
    DFUServiceInitiator *initiator = [[DFUServiceInitiator alloc] initWithCentralManager:self.bluetoothManager target:peril];
    DFUServiceInitiator *seInitiator = [initiator withFirmware:selectedFirmware];
    // Optional:
    // initiator.forceDfu = YES/NO; // default NO
    // initiator.packetReceiptNotificationParameter = N; // default is 12
    initiator.logger = self; // - to get log info
    initiator.delegate = self; // - to be informed about current state and errors
    initiator.progressDelegate = self; // - to show progress bar
    // initiator.peripheralSelector = ... // the default selector is used
    
    DFUServiceController *controller = [initiator start];
    NSLog(@"%@ === %@",seInitiator,controller);
}

#pragma mark- delegate
- (void)dfuProgressDidChangeFor:(NSInteger)part
                          outOf:(NSInteger)totalParts
                             to:(NSInteger)progress
     currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond {
    NSLog(@"%s :%ld/%ld---progress: %ld",__FUNCTION__,(long)part,(long)totalParts,(long)progress);
    [self updateUIPercent:progress];
}

/*
 DFUStateConnecting = 0,
 DFUStateStarting = 1,
 DFUStateEnablingDfuMode = 2,
 DFUStateUploading = 3,
 DFUStateValidating = 4,
 DFUStateDisconnecting = 5,
 DFUStateCompleted = 6,
 DFUStateAborted = 7,*/
- (void)dfuStateDidChangeTo:(enum DFUState)state {
    NSLog(@"%s :%ld",__FUNCTION__,(long)state);
    switch (state) {
        case DFUStateConnecting:
        {
            [self updateUIStart];
        }
            break;
        case DFUStateCompleted:
        {
            [self updateUIComplete];
            [self cycleUpgrading];
        }
        case DFUStateAborted:
        {
            [self updateUIFail];
        }
        default:
            break;
    }
}

- (void)dfuError:(enum DFUError)error didOccurWithMessage:(NSString * _Nonnull)message {
    NSLog(@"%s: %ld , %@",__FUNCTION__,(long)error,message);
}

- (void)logWith:(enum LogLevel)level message:(NSString * _Nonnull)message {
    NSLog(@"%s,level:%ld ,%@",__FUNCTION__,(long)level,message);
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

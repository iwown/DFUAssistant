//
//  ZGDFUController.m
//  linyi
//
//  Created by A$CE on 2017/11/9.
//  Copyright © 2017年 com.kunekt.healthy. All rights reserved.
//

#import "ZGDFUController.h"
#import <iOSDFULibrary/iOSDFULibrary-Swift.h>

NSString * const zg_dfuServiceUUIDString = @"FE59";

@interface ZGDFUController ()<DFUProgressDelegate,DFUServiceDelegate,LoggerDelegate>

@end

@implementation ZGDFUController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)startDFUUpgrade {
    
    NSTimeInterval timeInterval = 0;
    if (!self.isDFU) {
        [[BLEShareInstance shareInstance] deviceFWUpdate];
        timeInterval = 5;
    }
    
    [self performSelector:@selector(startToScan) withObject:nil afterDelay:timeInterval];
}

- (NSArray *)servicesSids {
    NSArray *sIDs = [NSArray arrayWithObjects:[CBUUID UUIDWithString:zg_dfuServiceUUIDString], nil];
    return sIDs;
}

- (void)startDfuWithPeripheral:(CBPeripheral *)peril {

    NSURL *url = [self getZipFileUrl];
    if (!url) {
        [self updateUIFail];
        return;
    }
    //create a DFUFirmware object using a NSURL to a Distribution Packer(ZIP)
    DFUFirmware *selectedFirmware = [[DFUFirmware alloc] initWithUrlToZipFile:url];
    //Use the DFUServiceInitializer to initialize the DFU process.
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    DFUServiceInitiator *initiator = [[DFUServiceInitiator alloc] initWithQueue:mainQueue delegateQueue:mainQueue progressQueue:mainQueue loggerQueue:mainQueue];
    DFUServiceInitiator *seInitiator = [initiator withFirmware:selectedFirmware];
    initiator.logger = self; // - to get log info
    initiator.delegate = self; // - to be informed about current state and errors
    initiator.progressDelegate = self; // - to show progress bar
    DFUServiceController *controller = [initiator startWithTarget:peril];
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
            [self updateStateAfterConnectDevice];
        }
            break;
        case DFUStateCompleted:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self updateUIAferComplete];
                [self newCompleteAnimationView];
            });
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
}

@end

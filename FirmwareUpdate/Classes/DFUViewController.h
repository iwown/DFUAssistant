//
//  DFUViewController.h
//  ZLingyi
//
//  Created by Jackie on 15/1/13.
//  Copyright (c) 2015年 Jackie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseDFUController.h"
#import "BLEShareInstance.h"

@interface DFUViewController : BaseDFUController

@property (strong, nonatomic) CBCentralManager *bluetoothManager;
@property (nonatomic,assign)BOOL isDFU;

- (NSArray *)servicesSids;
- (void)startDfuWithPeripheral:(CBPeripheral *)peril;
- (NSURL *)getZipFileUrl;
- (void)startToScan;
- (BOOL)updateStateAfterConnectDevice;
@end

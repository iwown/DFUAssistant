//
//  ViewController.h
//  FirmwareUpdate
//
//  Created by west on 16/9/19.
//  Copyright © 2016年 west. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DFUHelper.h"

@interface ViewController : UIViewController<DFUOperationsDelegate>

@property (strong, nonatomic) CBCentralManager *bluetoothManager;

@property (assign, nonatomic) BOOL autoUpgrading;
@property (strong, nonatomic) NSArray <CBUUID *>*uuids;

- (void)handleUrlString:(NSString *)urlString;

- (void)onFileSelected:(NSURL *)url;
- (void)startDfuWithPeripheral:(CBPeripheral *)peril;
- (void)cycleUpgrading;

- (void)updateUIPercent:(NSInteger)percentage;
- (void)updateUIStart;
- (void)updateUIComplete;
- (void)updateUIFail;


@end


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

- (void)handleUrlString:(NSString *)urlString;

@end


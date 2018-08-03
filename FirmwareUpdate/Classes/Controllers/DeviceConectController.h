//
//  DeviceConectController.h
//  FirmwareUpdate
//
//  Created by west on 16/9/20.
//  Copyright © 2016年 west. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreBluetooth/CoreBluetooth.h>
#import "DFUHelper.h"

@protocol DeviceConectControllerDelegate <NSObject>

@optional

- (void)centralManager:(CBCentralManager *)centralManager ConnectSuccessPeripheral:(CBPeripheral *)peripheral;

@end


@interface DeviceConectController : UIViewController<CBCentralManagerDelegate>

@property (nonatomic, strong)CBCentralManager *bluetoothManager;
@property (nonatomic, assign)BOOL autoUpgrading;

@property (nonatomic, unsafe_unretained)id<DeviceConectControllerDelegate> delegate;

@end

//
//  MTKBlePeripheralManager.h
//  Mediatek SmartDevice
//
//  Created by user on 14-9-3.
//  Copyright (c) 2014年 Mediatek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "VolumeController.h"
#import "AlertService.h"

@interface MTKBlePeripheralManager : NSObject

+ (id) sharedInstance;
-(void) stopFmpAlert;
@property (nonatomic) BOOL isConnected;

@end

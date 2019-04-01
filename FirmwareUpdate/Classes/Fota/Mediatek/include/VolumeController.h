//
//  VolumeController.h
//  Mediatek SmartDevice
//
//  Created by user on 14-9-1.
//  Copyright (c) 2014年 Mediatek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <MediaPlayer/MediaPlayer.h>

extern NSString *kVolumeControlServiceUUID;
extern NSString *kVolumeControlCharacteristicUUID;

@interface VolumeController : NSObject

+ (id) getVolumeContorllerInstance: (CBPeripheralManager *)peripheralManagerInit;
- (void) addService;
- (void) volumeControl: (int8_t)cmd;
//-(void)removeService;

@property (nonatomic) BOOL isConnected;
@property (nonatomic) CBPeripheralManager *peripheralManager;
@property (nonatomic) CBMutableCharacteristic *volumeControlCharacteristic;
@end

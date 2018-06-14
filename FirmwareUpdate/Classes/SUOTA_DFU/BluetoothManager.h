//
//  BluetoothManager.h
//  Bluetooth
//
//  Created by Martijn Houtman on 1/21/13.
//  Copyright (c) 2013 Martijn Houtman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

extern NSString * const BluetoothManagerReceiveDevices;
extern NSString * const BluetoothManagerConnectingToDevice;
extern NSString * const BluetoothManagerConnectedToDevice;
extern NSString * const BluetoothManagerDisconnectedFromDevice;

@interface BluetoothManager : NSObject <CBCentralManagerDelegate> {
    CBCentralManager *manager;
    CBUUID *mainServiceUUID;
    NSMutableArray *knownPeripherals;
}

@property BOOL bluetoothReady;
@property (nonatomic, retain) CBPeripheral *device;

+ (id) getInstance;
+ (void) destroyInstance;

+ (UInt16) swap:(UInt16)s;

- (void) connectToDevice: (CBPeripheral*) device;
- (void) disconnectDevice;

- (void) startScanning;
- (void) stopScanning;

- (void) centralManagerDidUpdateState:(CBCentralManager *)central;
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI;
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral;
- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error;
- (void) centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals;
- (void) centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals;

@end

//
//  BluetoothManager.m
//  Bluetooth
//
//  Created by Martijn Houtman on 1/21/13.
//  Copyright (c) 2013 Martijn Houtman. All rights reserved.
//

#import "BluetoothManager.h"
#import "Defines.h"
#import "DeviceStorage.h"

NSString * const BluetoothManagerReceiveDevices         = @"BluetoothManagerReceiveDevices";
NSString * const BluetoothManagerConnectingToDevice     = @"BluetoothManagerConnectingToDevice";
NSString * const BluetoothManagerConnectedToDevice      = @"BluetoothManagerConnectedToDevice";
NSString * const BluetoothManagerDisconnectedFromDevice = @"BluetoothManagerDisconnectedFromDevice";

static BluetoothManager *instance;

@implementation BluetoothManager

@synthesize bluetoothReady, device;

+ (id) getInstance {
    return instance;
}

+ (void) destroyInstance {
    instance = nil;
}

- (id) init {
    self = [super init];
    if (self) {
        manager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];
        UInt16 cx = [BluetoothManager swap:SPOTA_SERVICE_UUID];
        NSData *cdx = [[NSData alloc] initWithBytes:(char *)&cx length:2];
        mainServiceUUID = [CBUUID UUIDWithData:cdx];
        knownPeripherals = [[NSMutableArray alloc] init];
        instance = self;
    }
    
    return self;
}

- (void) connectToDevice: (CBPeripheral*) _device {
    self.device = _device;
    
    NSDictionary *options = @{CBConnectPeripheralOptionNotifyOnDisconnectionKey: @TRUE};
    
    //if (![device isConnected])
        [manager connectPeripheral:_device options:options];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothManagerConnectingToDevice object:_device];
}

- (void) disconnectDevice {
    if (self.device.state != CBPeripheralStateConnected) {
        return;
    }
    [manager cancelPeripheralConnection:self.device];
}

- (void) startScanning {
    if (!self.bluetoothReady) {
        NSLog(@"Bluetooth not yet ready, trying again in a few seconds...");
        [self performSelector:@selector(startScanning) withObject:nil afterDelay:1.0];
        return;
    }
    
    
    NSLog(@"Started scanning for devices ...");
    
    knownPeripherals = [[NSMutableArray alloc] init];
    [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothManagerReceiveDevices object:knownPeripherals];
    
    // We would also like to support HomeKit products, as they possibly implement the SUOTA service without advertising it.
    UInt16 cx = [BluetoothManager swap:HOMEKIT_UUID];
    NSData *cdx = [[NSData alloc] initWithBytes:(char *)&cx length:2];
    CBUUID *homekitUUID = [CBUUID UUIDWithData:cdx];
    
    NSArray         *uuids      = [NSArray arrayWithObjects:mainServiceUUID, homekitUUID, nil];
    NSDictionary	*options	= [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    
    [manager scanForPeripheralsWithServices:uuids options:options];
    //[manager scanForPeripheralsWithServices:nil options:nil];
}

- (void) stopScanning {
    [manager stopScan];
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    bluetoothReady = FALSE;
    switch (manager.state) {
        case CBCentralManagerStatePoweredOff:
            NSLog(@"CoreBluetooth BLE hardware is powered off");
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@"CoreBluetooth BLE hardware is powered on and ready");
            self.bluetoothReady = TRUE;
            break;
        case CBCentralManagerStateResetting:
            NSLog(@"CoreBluetooth BLE hardware is resetting");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@"CoreBluetooth BLE state is unauthorized");
            break;
        case CBCentralManagerStateUnknown:
            NSLog(@"CoreBluetooth BLE state is unknown");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"CoreBluetooth BLE hardware is unsupported on this platform");
            break;
        default:
            NSLog(@"Unknown state");
            break;
    }
}

- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    NSLog(@"Discovered item %@ (advertisement: %@)", peripheral, advertisementData);
    
    /*[manager stopScan];
    NSLog(@"Stopped scanning...");
    
    [self.delegate didDiscoverDevice:peripheral];*/
    
    //[self connectToDevice:peripheral];
    
    if (![knownPeripherals containsObject:peripheral]) {
        [knownPeripherals addObject:peripheral];
    }
    
    NSMutableArray *uuids = [[NSMutableArray alloc] init];
    for (CBPeripheral *p in knownPeripherals) {
        [uuids addObject:(id)p.identifier];
        NSLog(@"Looking for UUID: %@", peripheral.identifier);
    }
    
    [manager retrievePeripheralsWithIdentifiers:uuids];
    [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothManagerReceiveDevices object:knownPeripherals];
}

- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Did connect device: %@", peripheral);
    
    GenericServiceManager *m = [[DeviceStorage sharedInstance] deviceManagerWithIdentifier:[peripheral.identifier UUIDString]];
    if (m == nil) {
        m = [[GenericServiceManager alloc] initWithDevice:peripheral andManager:self];
    }
    [m setDevice:peripheral];
    //[m discoverServices];
    
    [[DeviceStorage sharedInstance] save];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothManagerConnectedToDevice object:peripheral];
}

- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Disconnected device");
    [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothManagerDisconnectedFromDevice object:peripheral];
}

- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"Error connecting device");
}

- (void) centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals {
    NSLog(@"Retreived connected devices");
}

- (void) centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals {
    NSLog(@"Retrieved periphs: %@", peripherals);
    NSLog(@"Retrieved known periphs: %@", knownPeripherals);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BluetoothManagerReceiveDevices object:knownPeripherals];
    //[manager stopScan];
}

/*!
 *  @method swap:
 *
 *  @param s Uint16 value to byteswap
 *
 *  @discussion swap byteswaps a UInt16
 *
 *  @return Byteswapped UInt16
 */

+ (UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

@end

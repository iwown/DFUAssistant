//
//  MTKBleManager.h
//  BleProfile
//
//  Created by ken on 14-7-6.
//  Copyright (c) 2014年 MTK. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#include <unistd.h>
#import "MTKBleProximityService.h"
#import "AlertService.h"
//#import "HealthKitSerivce.h"
#import "GATTLinker.h"
#import "BLEClientProfile.h"

/* Charactistic UUID */
extern NSString *kAlertLevelCharacteristicUUIDStringNew;
extern NSString *kTxPowerLevelCharacteristicUUIDString;

extern NSString *kEnterBackgroundNotification;
extern NSString *kEnterForegroundNotification;
extern NSString *kFinishLaunchNotification;

extern NSString *UserDefaultKey_disconnecManually;
extern NSString *UserDefaultKey_savedIdentify;
extern NSString *UserDefaultKey_killedForcely;

/*UI Protocols */
@protocol BleDiscoveryDelegate <NSObject>

- (void) discoveryDidRefresh: (CBPeripheral *)peripheral;
- (void) discoveryStatePoweredOff;

@end

@protocol BleConnectDelegate <NSObject>

- (void) connectDidRefresh:(int)connectionState deviceName:(CBPeripheral*)peripheral;
- (void) disconnectDidRefresh: (int)connectionState devicename: (CBPeripheral *)peripheral;
- (void) retrieveDidRefresh: (NSArray *)peripherals;

@end

@protocol BleScanningStateChangeDelegate <NSObject>

- (void) scanStateChange:(int)state;

@end

@protocol BluetoothAdapterStateChangeDelegate <NSObject>

-(void)onBluetoothStateChange:(int)state;

@end

@protocol ClientProfileDelegate <NSObject>

- (void)onCentralManagerStateChange: (int)state;
- (void)onConnected: (CBPeripheral *)peripheral;
- (void)onDisconnected;
- (void)onServiceDiscovered: (CBPeripheral *)periphearl error: (NSError *)error;
- (void)onCharacteristicDiscovered: (CBPeripheral *)peripheral forService: (CBService *)service error: (NSError *)err;
- (void)onUpdateValueForCharacteristic: (CBPeripheral *)peripheral forCharacteristic: (CBCharacteristic *)characteristic error: (NSError *)err;
- (void)onCharacteristicWrite;
- (void)onReadRssi: (CBPeripheral *)peripheral rssiValue: (int)rssi error: (NSError *)err;

@end

/******************** scaning state **********************/
const static int SCANNING_STATE_ON = 1;
const static int SCANNING_STATE_OFF = 0;
/**********************************************************/

/******************** conntion state **********************/
const static int CONNECT_SUCCESS = 1;
const static int CONNECT_FAILED = 2;
const static int DISCONNECT_SUCCESS = 3;
const static int DISCONNECT_FAILED = 4;

const static int CONNECTION_STATE_CONNECTED = 2;
const static int CONNECTION_STATE_CONNECTING = 1;
const static int CONNECTION_STATE_DISCONNECTING = 3;
const static int CONNECTION_STATE_DISCONNECTED = 0;
/**********************************************************/

@interface MTKBleManager: NSObject

+ (id) sharedInstance;

@property (nonatomic) int scanningState;

- (void)registerDiscoveryDelgegate: (id<BleDiscoveryDelegate>)discoveryDelegate;
- (void)registerConnectDelgegate: (id<BleConnectDelegate>)connectDelegate;
- (void)registerProximityDelgegate: (id<ProximityAlarmProtocol>)proximityDelegate __attribute__((deprecated("use method registerProximityDelgegate: in MTKBleProximityService instead")));
- (void)registerScanningStateChangeDelegate:(id<BleScanningStateChangeDelegate>)scanStateChangeDelegate;
- (void)registerBluetoothStateChangeDelegate:(id<BluetoothAdapterStateChangeDelegate>)bluetoothStateChangeDelegate;
//- (void)registerCalibrateDelegate:(id<CalibrateProtocol>)calibrateDelegate;

/* Action */
- (void)startScanning;
- (void)stopScanning;
- (void)forgetPeripheral;

- (int)getCurrentConnectState;

- (void)connectPeripheral: (CBPeripheral *)peripheral;
- (void)disconnectPeripheral: (CBPeripheral *)peripheral;//phase out

/***/
//- (void)retrievePeripherals:(NSArray *)peripherals;
//- (void)connectSavedPeripheral
/***/

- (void)unRegisterDiscoveryDelgegate: (id<BleDiscoveryDelegate>)discoveryDelegate;
- (void)unRegisterConnectDelgegate: (id<BleConnectDelegate>)connectDelegate;
- (void)unRegisterProximityDelgegate: (id<ProximityAlarmProtocol>)proximityDelegate __attribute__((deprecated("use method unRegisterProximityDelgegate: in MTKBleProximityService instead")));
- (void)unRegisterScanningStateChangeDelegate:(id<BleScanningStateChangeDelegate>)scanStateChangeDelegate;
- (void)unRegisterBluetoothStateChangeDelegate:(id<BluetoothAdapterStateChangeDelegate>)bluetoothStateChangeDelegate;
//- (void)unRegisterCalibrateDelegate:(id<CalibrateProtocol>)calibrateDelegate;


//pxp related
- (void)updatePxpSetting: (NSString *)peripheralIdentify
            alertEnabler: (int)alertEnabler
                   range: (int)rangeAlertEnabler
               rangeType: (int)rangeType
           alertDistance: (int)distance
  disconnectAlertEnabler: (int)disconnectAlertEnabler __attribute__((deprecated("use method updatePxpSetting: in MTKBleProximityService instead")));

- (int)queryDistance: (CBPeripheral *) peripheral __attribute__((deprecated("use method queryDistance: in MTKBleProximityService instead")));
- (BOOL)getIsNotifyRemote: (CBPeripheral *)peripheral __attribute__((deprecated("use method getIsNotifyRemote: in MTKBleProximityService instead")));
- (void)setAlertThreshold: (int)near midThreshold: (int)middle farThreshold: (int)far __attribute__((deprecated("use method updateAlertThreshhold: in MTKBleProximityService instead")));
-(BOOL)findTarget:(int) level __attribute__((deprecated("use method findTarget: in FmpGattClient instead")));

-(int)getScanningState;

/**
 use this method to set the DOGP max write GATT length to avoid loss package
 */
-(BOOL)setDogpMaxWriteLength:(int)length;

/* Behave properly when heading into and out of the background */
- (void)enteredBackground;
- (void)enteredForeground;

/*Access to the devices */
@property (retain, nonatomic) NSMutableArray *foundPeripherals;
@property (retain, nonatomic) NSMutableArray *connectPeripherals;
@property (retain, nonatomic) NSMutableArray *connectedService;
@property (retain, nonatomic, strong) CBPeripheral *peripheral;
@property (retain, nonatomic, strong) CBPeripheral *tempPeripheral;

/**
 *    register clien UUID for searching service
 *
 *    @param clientUUID the UUID published by remote server
 */
- (void)registerClientProfile: (NSString *)clientServiceUUIDStr ClientProfileDelegate: (id<ClientProfileDelegate>)clientProfileDelegate;

@end

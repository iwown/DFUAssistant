//
//  BtNotify.h
//  BtNotify
//
//  Created by user on 2017/2/20.
//  Copyright © 2017年 Mediatek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#define SPC_ERROR_CODE_STEP                             1

#define SPC_ERROR_CODE_OK                               0
#define SPC_ERROR_CODE_WRONG_PARAMETER                  (SPC_ERROR_CODE_OK - SPC_ERROR_CODE_STEP)
#define SPC_ERROR_CODE_NOT_INITED                       (SPC_ERROR_CODE_WRONG_PARAMETER - SPC_ERROR_CODE_STEP)
#define SPC_ERROR_CODE_NOT_STARTED                      (SPC_ERROR_CODE_NOT_INITED - SPC_ERROR_CODE_STEP)
#define SPC_ERROR_CODE_NOT_HANDSHAKE_DONE               (SPC_ERROR_CODE_NOT_STARTED - SPC_ERROR_CODE_STEP)

#define SPC_ERROR_CODE_FOTA_WRONG_TYPE                  (SPC_ERROR_CODE_NOT_HANDSHAKE_DONE - SPC_ERROR_CODE_STEP)

// Send priority
const static int SPC_PRIORITY_NORMAL = 0;
const static int SPC_PRIORITY_LOW = 1;
const static int SPC_PRIORITY_HIGH = 2;

// For FOTA
const static int SPC_FOTA_UPDATE_VIA_BT_TRANSFER_SUCCESS                   = 2;
const static int SPC_FOTA_UPDATE_VIA_BT_UPDATE_SUCCESS                     = 3;

const static int SPC_FOTA_UPDATE_VIA_BT_COMMON_ERROR                       = -1;
const static int SPC_FOTA_UPDATE_VIA_BT_WRITE_FILE_FAILED                  = -2;
const static int SPC_FOTA_UPDATE_VIA_BT_DISK_FULL                          = -3;
const static int SPC_FOTA_UPDATE_VIA_BT_TRANSFER_FAILED                    = -4;
const static int SPC_FOTA_UPDATE_VIA_BT_TRIGGER_FAILED                     = -5;
const static int SPC_FOTA_UPDATE_VIA_BT_UPDATE_FAILED                      = -6;
const static int SPC_FOTA_UPDATE_VIA_BT_TRIGGER_FAILED_CAUSE_LOW_BATTERY   = -7;

const static int SPC_REDBEND_FOTA_UPDATE                                   = 0;
const static int SPC_SEPARATE_BIN_FOTA_UPDATE                              = 1;
const static int SPC_ROCK_FOTA_UPDATE                                      = 4;
const static int SPC_FBIN_FOTA_UPDATE                                      = 5;
const static int SPC_GNSS_FOTA_UPDATE                                      = 6;

// For FOTA version
@interface SPC_FotaVersion : NSObject

@property NSString*     version;
@property NSString*     releaseNote;
@property NSString*     module;
@property NSString*     platform;
@property NSString*     deviceId;
@property NSString*     brand;
@property NSString*     domain;
@property NSString*     downloadKey;
@property NSString*     pinCode;
@property BOOL          isLowBattery;

@end


#pragma mark - Custom Related Delegate
@protocol SPC_NotifyCustomDelegate <NSObject>

@optional
-(void)onReadyToSend:(BOOL)ready;

-(void)onDataArrival:(NSString *)receiver arrivalData:(NSData *)data;

-(void)onProgress:(NSString *)sender
      newProgress:(float)progress;

@end

#pragma mark - Fota related Delegate
@protocol SPC_NotifyFotaDelegate <NSObject>

@optional
-(void)onFotaVersionReceived:(SPC_FotaVersion *)version;

-(void)onFotaTypeReceived:(int)fotaType;

-(void)onFotaStatusReceived:(int)status;

-(void)onFotaProgress:(float)progress;

@end

@interface BtNotify : NSObject


/**
 Static API to get BtNotify instance

 @return BtNotify instance
 */
+(id)sharedInstance;


/**
 Set Gatt Characteristic and CBPeripheral which will be used to 
 communicate with remote device

 @param peripheral Peripheral to operate
 @param writeChar Characteristic for writing
 @param readChar Characteristic for reading
 */
-(void)setGattParameters:(CBPeripheral *)peripheral
     writeCharacteristic:(CBCharacteristic *)writeChar
      readCharacteristic:(CBCharacteristic *)readChar;


/**
 Release memory
 */
-(void)deinit;


/**
 Write data to remote device
 The sender/receiver should be handled in remote device

 @param sender Sender value for remote device
 @param receiver Receiver value for remote device
 @param action Should match with remote device
 @param data Data to write
 @param needPro Set need progress while sending
 @param pri Send data with priority
 @return If append to SPC_Session manager, return OK,
         If sender/receiver/data is nil or length is 0, return SPC_ERROR_CODE_WRONG_PARAMETER
 */
-(int)send:(NSString *)sender
   receiver:(NSString *)receiver
 dataAction:(int)action
 dataToSend:(NSData *)data
needProgress:(BOOL)needPro
sendPriority:(int)pri;


/**
 Register custom delegate to receive callbacks

 @param delegate Delegate to register
 */
-(void)registerCustomDelegate:(id<SPC_NotifyCustomDelegate>)delegate;


/**
 Unregister custom delegate
 If called, the custom delegate will not be notified any more

 @param delegate Delegate to unregister
 */
-(void)unregisterCustomDelegate:(id<SPC_NotifyCustomDelegate>)delegate;


/**
 Register FOTA delegate

 @param delegate Delegate to register
 */
-(void)registerFotaDelegate:(id<SPC_NotifyFotaDelegate>)delegate;


/**
 Unregister FOTA delegate
 If called, the fota delegate will not be notified any more

 @param delegate Delegate to unregister
 */
-(void)unregisterFotaDelegate:(id<SPC_NotifyFotaDelegate>)delegate;


/**
 Update connection state with remote device via BLE

 @param newState New Connection state, which should be #CBPeripheralState
 */
-(void)updateConnectionState:(int)newState;


/**
 Handle the gatt write response which the characteristic should ONLY be BtNotify Characteristic
 Otherwise, ignore the response

 @param responseChar Write response characteristic
                     Should ONLY be BtNotify Characteristic
 @param err Write response Error
 */
-(void)handleWriteResponse:(CBCharacteristic *)responseChar error:(NSError *)err;


/**
 Handle the gatt read response which the characteristic should ONLY be BtNotify Characteristic
 Ohterwise, ignore the response

 @param dataChar Read response characteristic
 @param err Read response error
 */
-(void)handleReadReceivedData:(CBCharacteristic *)dataChar error:(NSError *)err;


/**
 Get BtNotify is ready to send app data
 Only the BtNotify handshake done, the value is YES
 Otherwise the value should be NO

 @return Current state
 */
-(BOOL)isReadyToSend;

#pragma mark - Fota Public APIs

/**
 Send Command to get remote device Fota Type
 */
-(int)sendFotaTypeGetCmd;


/**
 Send Command to get remote device FOTA version

 @param whichType according to fota type
 @return If #whichType is supported, return YES
         Otherwise return NO
 */
-(int)sendFotaVersionGetCmd:(int)whichType;
-(int)sendFotaData:(int)whchType firmwareData:(NSData *)data;


/**
 Cancel current FOTA sending
 */
-(void)cancelCurrentFotaSending;

@end

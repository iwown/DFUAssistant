//
//  FotaOperator.h
//  MTKBleManager
//
//  Created by user on 14/11/4.
//  Copyright (c) 2014年 ___MTK___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FotaVersion.h"

const int FOTA_UPDATE_VIA_BT_TRANSFER_SUCCESS                   = 2;
const int FOTA_UPDATE_VIA_BT_UPDATE_SUCCESS                     = 3;

const int FOTA_UPDATE_VIA_BT_COMMON_ERROR                       = -1;
const int FOTA_UPDATE_VIA_BT_WRITE_FILE_FAILED                  = -2;
const int FOTA_UPDATE_VIA_BT_DISK_FULL                          = -3;
const int FOTA_UPDATE_VIA_BT_TRANSFER_FAILED                    = -4;
const int FOTA_UPDATE_VIA_BT_TRIGGER_FAILED                     = -5;
const int FOTA_UPDATE_VIA_BT_UPDATE_FAILED                      = -6;
const int FOTA_UPDATE_VIA_BT_TRIGGER_FAILED_CAUSE_LOW_BATTERY   = -7;

//

const int REDBEND_FOTA_UPDATE                                   = 0;
const int SEPARATE_BIN_FOTA_UPDATE                              = 1;
const int ROCK_FOTA_UPDATE                                      = 4;
const int FBIN_FOTA_UPDATE                                      = 5;



//@interface FotaVersion : NSObject
//
//    @property NSString*     version;
//    @property NSString*     releaseNote;
//    @property NSString*     module;
//    @property NSString*     platform;
//    @property NSString*     deviceId;
//    @property NSString*     brand;
//    @property NSString*     domain;
//    @property NSString*     downloadKey;
//    @property NSString*     pinCode;
//    @property BOOL          isLowBattery;
//
//@end


@protocol FotaDelegate <NSObject>

-(void)onFotaTypeReceived:(int)fotaType;

-(void)onVersionReceived:(FotaVersion*)version;

-(void)onStatusReceived:(int)status;

-(void)onConnectionStateChange:(int)newState;

-(void)onProgress:(float)progress;

-(void)onReadyToSend;

@end


@interface FotaOperator : NSObject

+(id)sharedInstance;

-(void)registerFotaDelegate:(id<FotaDelegate>)delegate;

-(void)unregisterFotaDelegate:(id<FotaDelegate>)delegate;

-(void)sendFotaTypeCheckCommand;

-(BOOL)sendFotaVersionGetCommand:(int)whichType;

-(BOOL)sendFotaFirmwareData:(int)whichType dataFromFile:(NSData*)data;

-(void)cancelCurrentSending;

@end

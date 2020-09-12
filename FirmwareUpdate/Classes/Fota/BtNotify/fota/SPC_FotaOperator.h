//
//  SPC_FotaOperator.h
//  MTKBleManager
//
//  Created by user on 14/11/4.
//  Copyright (c) 2014年 ___MTK___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BtNotify.h"
/*
const int SPC_FOTA_UPDATE_VIA_BT_TRANSFER_SUCCESS                   = 2;
const int SPC_FOTA_UPDATE_VIA_BT_UPDATE_SUCCESS                     = 3;

const int SPC_FOTA_UPDATE_VIA_BT_COMMON_ERROR                       = -1;
const int SPC_FOTA_UPDATE_VIA_BT_WRITE_FILE_FAILED                  = -2;
const int SPC_FOTA_UPDATE_VIA_BT_DISK_FULL                          = -3;
const int SPC_FOTA_UPDATE_VIA_BT_TRANSFER_FAILED                    = -4;
const int SPC_FOTA_UPDATE_VIA_BT_TRIGGER_FAILED                     = -5;
const int SPC_FOTA_UPDATE_VIA_BT_UPDATE_FAILED                      = -6;
const int SPC_FOTA_UPDATE_VIA_BT_TRIGGER_FAILED_CAUSE_LOW_BATTERY   = -7;

//

const int SPC_REDBEND_FOTA_UPDATE                                   = 0;
const int SPC_SEPARATE_BIN_FOTA_UPDATE                              = 1;
const int SPC_ROCK_FOTA_UPDATE                                      = 4;
const int SPC_FBIN_FOTA_UPDATE                                      = 5;
*/
@protocol FotaDelegate <NSObject>

-(void)onTypeReceived:(int)fotaType;

-(void)onVersionReceived:(SPC_FotaVersion*)version;

-(void)onStatusReceived:(int)status;

-(void)onProgress:(float)progress;

@end


@interface SPC_FotaOperator : NSObject

+(id)sharedInstance;

-(void)deinitOperator;

-(void)registerFotaDelegate:(id<FotaDelegate>)delegate;

-(void)unregisterFotaDelegate:(id<FotaDelegate>)delegate;

-(void)sendFotaTypeCheckCommand;

-(BOOL)sendFotaVersionGetCommand:(int)whichType;

-(BOOL)sendFotaFirmwareData:(int)whichType dataFromFile:(NSData*)data;

-(void)cancelCurrentSending;

@end

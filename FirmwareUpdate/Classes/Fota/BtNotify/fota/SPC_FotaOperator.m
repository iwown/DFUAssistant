//
//  SPC_FotaOperator.m
//  MTKBleManager
//
//  Created by user on 14/11/4.
//  Copyright (c) 2014年 ___MTK___. All rights reserved.
//

#import "SPC_FotaOperator.h"
#import "SPC_FotaController.h"
#import "SPC_ControllerManager.h"
//#import "SPC_SessionManager.h"
//#import "SPC_GattLinker.h"
//#import "Command.h"

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                        FOTA Communicate String                             //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
NSString* const SPC_FOTA_COMM_TYPE_GET_STRING                   = @"getType";
NSString* const SPC_FOTA_COMM_DPACKAGE_VERSION_GET_STRING       = @"getDiffVersion";
NSString* const SPC_FOTA_COMM_UBIN_VERSION_GET_STRING           = @"getUBINVersion";
NSString* const SPC_FOTA_COMM_USB_VERSION_GET_STRING            = @"getUSBVersion";
NSString* const SPC_FOTA_COMM_ROCK_VERSION_GET_STRING           = @"getRockVersion";
NSString* const SPC_FOTA_COMM_FBIN_VERSION_GET_STRING           = @"getFBINVersion";


////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                        FOTA Sender                                         //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
NSString* const SPC_FOTA_SENDER_TYPE_GET_STRING                 = @"fota_type";
NSString* const SPC_FOTA_SENDER_VERSOION_STRING                 = @"SPC_fota_bt_ver";
NSString* const SPC_FOTA_SENDER_FIRMWARE_DPACKAGE_STRING        = @"SPC_fota_dpack";
NSString* const SPC_FOTA_SENDER_FIRMWARE_UBIN_STRING            = @"fota_ubin";
NSString* const SPC_FOTA_SENDER_FIRMWARE_ROCK_STRING            = @"fota_rock";
NSString* const SPC_FOTA_SENDER_FIRMWARE_FBIN_STRING            = @"fota_fbin";
NSString* const SPC_FOTA_SENDER_GNSS_UPDATE_STRING              = @"SPC_gnss_update";


////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                        FOTA Receiver                                       //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
NSString* const SPC_FOTA_RECEIVER_TYPE_GET_STRING                 = @"fota_type";
NSString* const SPC_FOTA_RECEIVER_VERSOION_STRING                 = @"fota_bt_ver";
NSString* const SPC_FOTA_RECEIVER_FIRMWARE_DPACKAGE_STRING        = @"fota_dpack";
NSString* const SPC_FOTA_RECEIVER_FIRMWARE_UBIN_STRING            = @"fota_ubin";
NSString* const SPC_FOTA_RECEIVER_FIRMWARE_ROCK_STRING            = @"fota_rock";
NSString* const SPC_FOTA_RECEIVER_FIRMWARE_FBIN_STRING            = @"fota_fbin";
NSString* const SPC_FOTA_RECEIVER_GNSS_UPDATE_STRING              = @"gnss_update";


NSString* const SPC_VERSION_NO_STRING                             = @"verno";
NSString* const SPC_RELEASE_DATE_STRING                           = @"releaseDate";
NSString* const SPC_PLATFORM_STRING                               = @"platform";
NSString* const SPC_MODEL_STRING                                  = @"model";
NSString* const SPC_DEV_ID_STRING                                 = @"dev_id";
NSString* const SPC_BATTERY_STRING                                = @"battery";
NSString* const SPC_BRAND_STRING                                  = @"brand";
NSString* const SPC_DOMAIN_STRING                                 = @"domain";
NSString* const SPC_DL_KEY_STRING                                 = @"dl_key";
NSString* const SPC_PIN_CODE_STRING                               = @"pin_code";

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                        FOTA Send Data Type                                 //
//                          Buffer or File                                    //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
NSString* const SPC_FOTA_SEND_DATA_BUFFER_TYPE_STRING             = @"0";
NSString* const SPC_FOTA_SEND_DATA_FILE_TYPE_STRING               = @"1";

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                        FOTA Action                                         //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
NSString* const SPC_FOTA_ACTION_VERSION_GET_STRING                = @"0";
NSString* const SPC_FOTA_ACTION_TYPE_GET_STRING                   = @"0";
NSString* const SPC_FOTA_ACTION_DATA_BEGIN_STRING                 = @"0";
NSString* const SPC_FOTA_ACTION_DATA_CONTENT_STRING               = @"1";
NSString* const SPC_FOTA_ACTION_DATA_END_STRING                   = @"2";

const int SPC_FOTA_ACTION_VERSION_GET_INT                = 0;
const int SPC_FOTA_ACTION_TYPE_GET_INT                   = 0;
const int SPC_FOTA_ACTION_DATA_BEGIN_INT                 = 0;
const int SPC_FOTA_ACTION_DATA_CONTENT_INT               = 1;
const int SPC_FOTA_ACTION_DATA_END_INT                   = 2;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                        FOTA END transfer value                             //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
NSString* const SPC_FOTA_DATA_SEND_END_STRING                     = @"BTpush";

NSString* const SPC_FOTA_UPDATE_VERSION_GET_FAILED                = @"-8";
NSString* const SPC_FEATURE_PHONE_LOW_BATTERY_STRING              = @"low";

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                        FOTA Type String                                    //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
//NSString* const FOTA_DPACKAGE_UPDATE_STRING                   = @"00000001";
//NSString* const FOTA_SEPARATE_BIN_UPDATE_STRING               = @"00000010";
//NSString* const FOTA_USB_CALBLE_STRING                        = @"00000100";

//NSString* const FOTA_DPACKAGE_USB_CABLE_STRING                = @"00000101";
//NSString* const FOTA_SEPARATE_BIN_USB_CABLE_STRING            = @"00000110";

//const int FOTA_TYPE_DPACKAGE_UPDATE_VALUE                     = 1;
//const int FOTA_TYPE_SEPERATE_BIN_FOTA_UPDATE_VALUE            = 2;
//const int FOTA_TYPE_USB_FOTA_UPDATE_VALUE                     = 4;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                        FOTA Update Type                                    //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
//const int FOTA_TYPE_DPACKAGE_UPDATE                           = 0;
//const int FOTA_TYPE_SEPARATE_BIN_UPDATE                       = 1;
//const int FOTA_TYPE_ROCK_UPDATE                               = 4;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                        FOTA transfer bytes                                 //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
const int SPC_FOTA_TRANSFER_BYTES_LENGTH                          = 1 * 1024; // 1K

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                       Class Sttaic Parameter                               //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
NSString * const SPC_TAG_FOTA = @"[FOTA][SPC_FotaOperator]";
const BOOL SPC_DEBUG_SWITCHER_FOTA = YES;


@interface SPC_FotaOperator() <SPC_FotaControllerDelegate>
{
    @private
    NSMutableArray* delegateArray;
    SPC_FotaController* controller;
    
    unsigned long mTotalTransferCount;
    unsigned long mCurrentTransferedCount;
    
}
@end


@implementation SPC_FotaOperator

static SPC_FotaOperator* sInstance;

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                        Public method                                       //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
/*******************************************************************************
 **
 ** Shared instance which used to get this class instance
 **
 *******************************************************************************/
+(id)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"[SPC_FotaOperator] [sharedInstance] begin to init");
        sInstance = [[SPC_FotaOperator alloc] init];
        [sInstance initialize];
    });
    return sInstance;
}

-(void)deinitOperator {
    [controller deinit];
    controller = nil;

    [delegateArray removeAllObjects];
    delegateArray = nil;
    sInstance = nil;
}

/*******************************************************************************
 **
 ** Register delegate which will callback to UX
 **
 *******************************************************************************/
-(void)registerFotaDelegate:(id<FotaDelegate>)delegate {
    if (delegate == nil) {
        [self printDebugLog:@"registerFotaDelegate" logInformation:@"delegate is nil"];
        return;
    }
    if (![delegateArray containsObject:delegate]) {
        [delegateArray addObject:delegate];
    }
}

/*******************************************************************************
 **
 ** Unregister the delegate
 **
 *******************************************************************************/
-(void)unregisterFotaDelegate:(id<FotaDelegate>)delegate {
    if (delegate == nil) {
        [self printDebugLog:@"unregisterFotaDelegate" logInformation:@"delegate is nil"];
        return;
    }
    if ([delegateArray containsObject:delegate]) {
        [delegateArray removeObject:delegate];
    }
}

/*******************************************************************************
 **
 ** Print debug log
 **
 *******************************************************************************/
-(void)sendFotaTypeCheckCommand {
    [self printDebugLog:@"sendFotaTypeCheckCommand" logInformation:@"begin to get wearable device fota type"];
    
//    NSUInteger length = SPC_FOTA_COMM_TYPE_GET_STRING.length;
    NSData* data = [SPC_FOTA_COMM_TYPE_GET_STRING dataUsingEncoding:NSUTF8StringEncoding];
    
//    NSString* cmdStr = [self buildSendCommadnString:SPC_FOTA_SENDER_TYPE_GET_STRING receiver:SPC_FOTA_RECEIVER_TYPE_GET_STRING action:FOTA_ACTION_TYPE_GET_STRING dataLength:length];
    
    /// TODO should call DOGP API to send data
    //[controller send:cmdStr data:data response:NO progress:NO priority:0];
//    [controller send:cmdStr data:data needResponse:NO needProgress:NO priority:0];
    [controller send:SPC_FOTA_SENDER_TYPE_GET_STRING receiver:SPC_FOTA_RECEIVER_TYPE_GET_STRING action:SPC_FOTA_ACTION_TYPE_GET_INT dataToSend:data needProgress:NO priority:SPC_PRIORITY_NORMAL];
}

/*******************************************************************************
 **
 ** Print debug log
 **
 *******************************************************************************/
-(BOOL)sendFotaVersionGetCommand:(int)whichType {
    
    if (whichType != SPC_REDBEND_FOTA_UPDATE && whichType != SPC_SEPARATE_BIN_FOTA_UPDATE
            && whichType != SPC_ROCK_FOTA_UPDATE && whichType != SPC_FBIN_FOTA_UPDATE) {
        [self printDebugLog:@"sendFotaVersionGetCommand" logInformation:@"Unknown type to get version"];
        return NO;
    }
    
    NSUInteger length = -1;
    NSData* dataFromString = nil;
    //NSString* versionStr = nil;
    
    if (whichType == SPC_REDBEND_FOTA_UPDATE) {
        
        length = SPC_FOTA_COMM_DPACKAGE_VERSION_GET_STRING.length;
        dataFromString = [SPC_FOTA_COMM_DPACKAGE_VERSION_GET_STRING dataUsingEncoding:NSUTF8StringEncoding];
        //versionStr = SPC_FOTA_COMM_DPACKAGE_VERSION_GET_STRING;
        
    } else if (whichType == SPC_SEPARATE_BIN_FOTA_UPDATE) {
        
        length = SPC_FOTA_COMM_UBIN_VERSION_GET_STRING.length;
        dataFromString = [SPC_FOTA_COMM_UBIN_VERSION_GET_STRING dataUsingEncoding:NSUTF8StringEncoding];
        //versionStr = SPC_FOTA_COMM_UBIN_VERSION_GET_STRING;
        
    } else if (whichType == SPC_ROCK_FOTA_UPDATE) {
        
        length = SPC_FOTA_COMM_ROCK_VERSION_GET_STRING.length;
        dataFromString = [SPC_FOTA_COMM_ROCK_VERSION_GET_STRING dataUsingEncoding:NSUTF8StringEncoding];
        //versionStr = SPC_FOTA_COMM_ROCK_VERSION_GET_STRING;
        
    } else if (whichType == SPC_FBIN_FOTA_UPDATE) {
        length = SPC_FOTA_COMM_FBIN_VERSION_GET_STRING.length;
        dataFromString = [SPC_FOTA_COMM_FBIN_VERSION_GET_STRING dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        
        [self printDebugLog:@"sendFotaVersionGetCommand" logInformation:@"Unknown type"];
        return NO;
        
    }
    
    //NSString* cmdStr = [self buildSendCommadnString:SPC_FOTA_SENDER_VERSOION_STRING receiver:SPC_FOTA_SENDER_VERSOION_STRING action:FOTA_ACTION_VERSION_GET_STRING dataLength:length];
    
    /// TODO send data via DOGP send interface
    
    //[controller send:cmdStr data:dataFromString response:NO progress:NO priority:0];
//    [controller send:cmdStr data:dataFromString needResponse:NO needProgress:NO priority:0];
    [controller send:SPC_FOTA_SENDER_VERSOION_STRING receiver:SPC_FOTA_RECEIVER_VERSOION_STRING action:SPC_FOTA_ACTION_VERSION_GET_INT dataToSend:dataFromString needProgress:NO priority:SPC_PRIORITY_NORMAL];

    return YES;
}

/*******************************************************************************
 **
 ** Send data to wearable device
 ** 
 ** whichType : Should only be FOTA_TYPE_DPACKAGE_UPDATE & FOTA_TYPE_SEPARATE_BIN_UPDATE
 ** data      : Need read data from file
 **
 *******************************************************************************/
-(BOOL)sendFotaFirmwareData:(int)whichType dataFromFile:(NSData*)data {
    if (whichType != SPC_REDBEND_FOTA_UPDATE && whichType != SPC_SEPARATE_BIN_FOTA_UPDATE
            && whichType != SPC_ROCK_FOTA_UPDATE && whichType != SPC_FBIN_FOTA_UPDATE
            && whichType != SPC_GNSS_FOTA_UPDATE) {
        [self printDebugLog:@"sendFotaFirmwareData" logInformation:@"Unrecoginzed type"];
        return NO;
    }
    
    if (data == nil || data.length == 0) {
        [self printDebugLog:@"sendFotaFirmwareData" logInformation:@"data is nil or EMPTY"];
        return NO;
    }
    
    /////////////
    int cu = data.length % SPC_FOTA_TRANSFER_BYTES_LENGTH;
    unsigned long max = data.length / SPC_FOTA_TRANSFER_BYTES_LENGTH;
    if (cu != 0) {
        max++;
    }
    //[self printDebugLog:@"sendFotaFirmwareData" logInformation:[NSString stringWithFormat:@"cu : %d, max : %lu", cu, max]];

    mCurrentTransferedCount = 0;
    mTotalTransferCount = 0;
    
    /// Call send API to send data
    [self sendBeginTransferCommand:whichType maxTransferCount:max];
    [NSThread sleepForTimeInterval:0.5];
    
    [self sendDataContent:whichType realDataContent:data];
    [NSThread sleepForTimeInterval:0.5];
    
    [self sendEndTransferCommand:whichType];
    
    return NO;
}

-(void)cancelCurrentSending {
    [controller cancelCurrentSending];
}

////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                        Private method                                      //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
/*******************************************************************************
 **
 ** Intialization
 **
 *******************************************************************************/
-(void)initialize {
    delegateArray = [[NSMutableArray alloc] init];
    
    controller = [SPC_FotaController sharedInstance];
    
    NSMutableArray *receiver_tags = [[NSMutableArray alloc] init];
    [receiver_tags addObject:SPC_FOTA_RECEIVER_TYPE_GET_STRING];
    [receiver_tags addObject:SPC_FOTA_RECEIVER_VERSOION_STRING];
    [receiver_tags addObject:SPC_FOTA_RECEIVER_FIRMWARE_UBIN_STRING];
    [receiver_tags addObject:SPC_FOTA_RECEIVER_FIRMWARE_ROCK_STRING];
    [receiver_tags addObject:SPC_FOTA_RECEIVER_FIRMWARE_DPACKAGE_STRING];
    [receiver_tags addObject:SPC_FOTA_RECEIVER_FIRMWARE_FBIN_STRING];
    
    [controller setReceiversTags:receiver_tags];
    [controller setControllerDelegate:self];
    
    [[SPC_ControllerManager CMSharedInstance] addController:controller];
}

/*******************************************************************************
 **
 ** Print debug log
 **
 *******************************************************************************/
-(void)printDebugLog:(NSString*)methodName logInformation:(NSString*)log {
    if (SPC_DEBUG_SWITCHER_FOTA == NO) {
        return;
    }
    if (log == nil || log.length == 0) {
        return;
    }
    if (methodName == nil || methodName.length == 0) {
        return;
    }
    NSLog(@"%@ : [%@], %@", SPC_TAG_FOTA, methodName, log);
}

/*******************************************************************************
 **
 ** Build the send command
 **
 *******************************************************************************/
-(NSString*)buildSendCommadnString:(NSString*)sender receiver:(NSString*)receiver action:(NSString*)action
                        dataLength:(NSUInteger)length {
    NSString* str = [NSString stringWithFormat:@"%@ %@ %@ %@ %lu ", sender, receiver, action,
                     SPC_FOTA_SEND_DATA_BUFFER_TYPE_STRING, (unsigned long)length];
    return str;
}

/*******************************************************************************
 **
 ** Before send the data content, need send the begin command to wearable device
 ** The dataLen should be the real data content max count
 **
 *******************************************************************************/
-(void)sendBeginTransferCommand:(int)whichType maxTransferCount:(NSUInteger)count {
    if (whichType != SPC_REDBEND_FOTA_UPDATE && whichType != SPC_SEPARATE_BIN_FOTA_UPDATE
            && whichType != SPC_ROCK_FOTA_UPDATE && whichType != SPC_FBIN_FOTA_UPDATE
            && whichType != SPC_GNSS_FOTA_UPDATE) {
        [self printDebugLog:@"sendBeginTransferCommand" logInformation:@"unrecognized update type"];
        return;
    }
    
    [self printDebugLog:@"sendBeginTransferCommand" logInformation:[NSString stringWithFormat:@"type : %d, count : %lu", whichType, (unsigned long)count]];
    
    NSString* sender = nil;
    NSString* receiver = nil;
    
    if (whichType == SPC_REDBEND_FOTA_UPDATE) {
        
        sender = SPC_FOTA_SENDER_FIRMWARE_DPACKAGE_STRING;
        receiver = SPC_FOTA_RECEIVER_FIRMWARE_DPACKAGE_STRING;
        
    } else if (whichType == SPC_SEPARATE_BIN_FOTA_UPDATE) {
        
        sender = SPC_FOTA_SENDER_FIRMWARE_UBIN_STRING;
        receiver = SPC_FOTA_RECEIVER_FIRMWARE_UBIN_STRING;
        
    } else if (whichType == SPC_ROCK_FOTA_UPDATE) {
        
        sender = SPC_FOTA_SENDER_FIRMWARE_ROCK_STRING;
        receiver = SPC_FOTA_RECEIVER_FIRMWARE_ROCK_STRING;
        
    } else if (whichType == SPC_FBIN_FOTA_UPDATE) {
        sender = SPC_FOTA_SENDER_FIRMWARE_FBIN_STRING;
        receiver = SPC_FOTA_RECEIVER_FIRMWARE_FBIN_STRING;
    } else if (whichType == SPC_GNSS_FOTA_UPDATE) {
        sender = SPC_FOTA_SENDER_GNSS_UPDATE_STRING;
        receiver = SPC_FOTA_RECEIVER_GNSS_UPDATE_STRING;
    } else {
        return;
    }
    
    NSString* str = [NSString stringWithFormat:@"%d", (unsigned int)count];
    NSData* strData = [str dataUsingEncoding:NSUTF8StringEncoding];
    /*
    NSString* cmdStr = [self buildSendCommadnString:sender receiver:receiver action:FOTA_ACTION_DATA_BEGIN_STRING dataLength:strData.length];
    
    NSString* dataL = [NSString stringWithFormat:@"%lu", (unsigned long)count];
    NSData* data = [dataL dataUsingEncoding:NSUTF8StringEncoding];
    */
    /// call send API to send data
    //[controller send:cmdStr data:data needResponse:NO needProgress:NO priority:0];
    [controller send:sender receiver:receiver action:SPC_FOTA_ACTION_DATA_BEGIN_INT dataToSend:strData needProgress:NO priority:SPC_PRIORITY_NORMAL];
    
}

/*******************************************************************************
 **
 ** Send the real data content
 **
 *******************************************************************************/
-(void)sendDataContent:(int)whichType realDataContent:(NSData*)data {
    if (whichType != SPC_REDBEND_FOTA_UPDATE && whichType != SPC_SEPARATE_BIN_FOTA_UPDATE
        && whichType != SPC_ROCK_FOTA_UPDATE && whichType != SPC_FBIN_FOTA_UPDATE
        && whichType != SPC_GNSS_FOTA_UPDATE) {
        [self printDebugLog:@"sendDataContent" logInformation:@"unrecognized type"];
        return;
    }
    
    [self printDebugLog:@"sendDataContent" logInformation:[NSString stringWithFormat:@"whichType : %d, data length : %lu", whichType, (unsigned long)data.length]];
    
    NSString* sender = nil;
    NSString* receiver = nil;
    
    if (whichType == SPC_REDBEND_FOTA_UPDATE) {
        
        sender = SPC_FOTA_SENDER_FIRMWARE_DPACKAGE_STRING;
        receiver = SPC_FOTA_RECEIVER_FIRMWARE_DPACKAGE_STRING;
        
    } else if (whichType == SPC_SEPARATE_BIN_FOTA_UPDATE) {
        
        sender = SPC_FOTA_SENDER_FIRMWARE_UBIN_STRING;
        receiver = SPC_FOTA_RECEIVER_FIRMWARE_UBIN_STRING;
        
    } else if (whichType == SPC_ROCK_FOTA_UPDATE) {
        
        sender = SPC_FOTA_SENDER_FIRMWARE_ROCK_STRING;
        receiver = SPC_FOTA_RECEIVER_FIRMWARE_ROCK_STRING;
        
    } else if (whichType == SPC_FBIN_FOTA_UPDATE) {
        sender = SPC_FOTA_SENDER_FIRMWARE_FBIN_STRING;
        receiver = SPC_FOTA_RECEIVER_FIRMWARE_FBIN_STRING;
    } else if (whichType == SPC_GNSS_FOTA_UPDATE) {
        sender = SPC_FOTA_SENDER_GNSS_UPDATE_STRING;
        receiver = SPC_FOTA_RECEIVER_GNSS_UPDATE_STRING;
    } else {
        return;
    }

    /// call send API to send data
    
    /**
     * split the data to 5k parts, and send each 5k part to wearable device
     */
    int cu = data.length % SPC_FOTA_TRANSFER_BYTES_LENGTH;
    unsigned long max = data.length / SPC_FOTA_TRANSFER_BYTES_LENGTH;
    
    if (cu != 0) {
        max ++;
    }
    
    [self printDebugLog:@"sendDataContent" logInformation:[NSString stringWithFormat:@"cu : %d, max : %lu", cu, max]];
    
    mTotalTransferCount = max;
    
    NSString* cmdStr = nil;
    
    unsigned long i = 0;
    unsigned long transferedLength = 0;
    while (transferedLength != data.length) {
        
        unsigned long restLength = data.length - transferedLength;
        [self printDebugLog:@"sendDataContent" logInformation:[NSString stringWithFormat:@"restLength : %lu", restLength]];
 
        NSRange range;
        if (restLength < SPC_FOTA_TRANSFER_BYTES_LENGTH) {
            range = NSMakeRange(i * SPC_FOTA_TRANSFER_BYTES_LENGTH, restLength);
            transferedLength = i * SPC_FOTA_TRANSFER_BYTES_LENGTH + restLength;
        } else {
            range = NSMakeRange(i * SPC_FOTA_TRANSFER_BYTES_LENGTH, SPC_FOTA_TRANSFER_BYTES_LENGTH);
            transferedLength = i * SPC_FOTA_TRANSFER_BYTES_LENGTH + SPC_FOTA_TRANSFER_BYTES_LENGTH;
        }
        
        [self printDebugLog:@"sendDataContent" logInformation:[NSString stringWithFormat:@"transferedLength : %lu", transferedLength]];
        
        NSData* dataToSend = [data subdataWithRange:range];
        [self printDebugLog:@"sendDataContent" logInformation:[NSString stringWithFormat:@"dataToSend length : %lu", (unsigned long)dataToSend.length]];
        cmdStr = [self buildSendCommadnString:sender receiver:receiver action:SPC_FOTA_ACTION_DATA_CONTENT_STRING dataLength:dataToSend.length];
        //[controller send:cmdStr data:dataToSend needResponse:NO needProgress:YES priority:0];
        //[controller send:cmdStr data:dataToSend response:NO progress:YES priority:10];
        [controller send:sender receiver:receiver action:SPC_FOTA_ACTION_DATA_CONTENT_INT dataToSend:dataToSend needProgress:YES priority:SPC_PRIORITY_NORMAL];
        
        i++;
        
    }
    
    //[self printDebugLog:@"sendDataContent" logInformation:[NSString stringWithFormat:@"finally i : %lu", i]];
    
}

/*******************************************************************************
 **
 ** While the data content send finished, should send the end command to wearable
 ** device
 **
 *******************************************************************************/
-(void)sendEndTransferCommand:(int)whichType {
    if (whichType != SPC_REDBEND_FOTA_UPDATE && whichType != SPC_SEPARATE_BIN_FOTA_UPDATE
        && whichType != SPC_ROCK_FOTA_UPDATE && whichType != SPC_FBIN_FOTA_UPDATE
        && whichType != SPC_GNSS_FOTA_UPDATE) {
        [self printDebugLog:@"sendEndTransferCommand" logInformation:@"unrecognized type"];
        return;
    }
    
    [self printDebugLog:@"sendEndTransferCommand" logInformation:[NSString stringWithFormat:@"whichType : %d", whichType]];
    
    NSString* sender = nil;
    NSString* receiver = nil;
    
    if (whichType == SPC_REDBEND_FOTA_UPDATE) {
        
        sender = SPC_FOTA_SENDER_FIRMWARE_DPACKAGE_STRING;
        receiver = SPC_FOTA_RECEIVER_FIRMWARE_DPACKAGE_STRING;
        
    } else if (whichType == SPC_SEPARATE_BIN_FOTA_UPDATE) {
        
        sender = SPC_FOTA_RECEIVER_FIRMWARE_UBIN_STRING;
        receiver = SPC_FOTA_RECEIVER_FIRMWARE_UBIN_STRING;
        
    } else if (whichType == SPC_ROCK_FOTA_UPDATE) {
        
        sender = SPC_FOTA_SENDER_FIRMWARE_ROCK_STRING;
        receiver = SPC_FOTA_RECEIVER_FIRMWARE_ROCK_STRING;
        
    } else if (whichType == SPC_FBIN_FOTA_UPDATE) {
        sender = SPC_FOTA_SENDER_FIRMWARE_FBIN_STRING;
        receiver = SPC_FOTA_RECEIVER_FIRMWARE_FBIN_STRING;
    } else if (whichType == SPC_GNSS_FOTA_UPDATE) {
        sender = SPC_FOTA_SENDER_GNSS_UPDATE_STRING;
        receiver = SPC_FOTA_RECEIVER_GNSS_UPDATE_STRING;
    } else {
        return;
    }
    
    NSData* data = [SPC_FOTA_DATA_SEND_END_STRING dataUsingEncoding:NSUTF8StringEncoding];
    
//    NSString* cmdStr = [self buildSendCommadnString:sender receiver:receiver action:FOTA_ACTION_DATA_END_STRING dataLength:data.length];
    
    /// call send API to send data
//    [controller send:cmdStr data:data needResponse:NO needProgress:NO priority:0];
    //[controller send:cmdStr data:data response:NO progress:NO priority:0];
    [controller send:sender receiver:receiver action:SPC_FOTA_ACTION_DATA_END_INT dataToSend:data needProgress:NO priority:SPC_PRIORITY_NORMAL];
}

/*******************************************************************************
 **
 ** While received the data from wearable device, and the receiver is fota type 
 ** get command return value
 **
 *******************************************************************************/
-(void)handleReceivedFotaType:(NSArray*)array {
    if (array == nil || [array count] != 5) {
        [self printDebugLog:@"handleReceivedFotaType" logInformation:@"array is nill or EMPTY"];
        return;
    }
    NSString* receiver = [array objectAtIndex:1];
    
    if (receiver == nil || receiver.length == 0) {
        [self printDebugLog:@"handleReceivedFotaType" logInformation:@"receiver is nil or EMPTY"];
        return;
    }
    
    if ([receiver isEqualToString:SPC_FOTA_RECEIVER_TYPE_GET_STRING] == NO) {
        [self printDebugLog:@"handleReceivedFotaType" logInformation:@"NOT SPC_FOTA_RECEIVER_TYPE_GET_STRING"];
        return;
    }
    
    NSString* value = [array objectAtIndex:4];
    if (value == nil || value.length == 0) {
        [self printDebugLog:@"handleReceivedFotaType" logInformation:@"value is nil or EMPTY"];
        
        for (id<FotaDelegate> delegate in delegateArray) {
            [delegate onTypeReceived:-1];
        }
        
        return;
    }
    
    [self printDebugLog:@"handleReceivedFotaType" logInformation:[NSString stringWithFormat:@"value : %@", value]];
    
    int type = 0;

    if ([value characterAtIndex:7] == 49) {
        
        [self printDebugLog:@"handleReceivedFotaType" logInformation:@"SUPPORT D-PACKAGE FOTA"];
        type = type | SPC_REDBEND_FOTA_UPDATE;
        
    } else if ([value characterAtIndex:6] == 49) {
        
        [self printDebugLog:@"handleReceivedFotaType" logInformation:@"SURPPORT SEPARATE BIN FOTA"];
        type = type | SPC_SEPARATE_BIN_FOTA_UPDATE;
        
    } else if ([value characterAtIndex:3] == 49) {
        
        [self printDebugLog:@"handleReceivedFotaType" logInformation:@"SURPPORT ROCK FOTA"];
        type = type | SPC_ROCK_FOTA_UPDATE;
        
    }
    
    if (type != -1) {
        for (id<FotaDelegate> delegate in delegateArray) {
            [delegate onTypeReceived:type];
        }
    }
    
}

/*******************************************************************************
 **
 ** Received the version get value
 **
 *******************************************************************************/
-(void)handleReceivedFotaVersion:(NSArray*)array {
    if (array == nil || [array count] != 5) {
        [self printDebugLog:@"handleReceivedFotaVersion" logInformation:@"array is nill or EMPTY"];
        return;
    }
    NSString* receiver = [array objectAtIndex:1];
    
    if (receiver == nil || receiver.length == 0) {
        [self printDebugLog:@"handleReceivedFotaVersion" logInformation:@"receiver is nil or EMPTY"];
        for (id<FotaDelegate> delegate in delegateArray) {
            [delegate onVersionReceived:nil];
        }
        return;
    }
    
    if ([receiver isEqualToString:SPC_FOTA_RECEIVER_VERSOION_STRING] == NO) {
        [self printDebugLog:@"handleReceivedFotaVersion" logInformation:@"NOT SPC_FOTA_RECEIVER_VERSOION_STRING"];
        for (id<FotaDelegate> delegate in delegateArray) {
            [delegate onVersionReceived:nil];
        }
        return;
    }
    
    NSString* value = [array objectAtIndex:4];
    
    if (value == nil || value.length == 0) {
        [self printDebugLog:@"handleReceivedFotaVersion" logInformation:@"value is nil or EMPTY"];
        
        for (id<FotaDelegate> delegate in delegateArray) {
            [delegate onVersionReceived:nil];
        }
        
        return;
    }

    if ([value isEqualToString:SPC_FOTA_UPDATE_VERSION_GET_FAILED] == YES) {
        [self printDebugLog:@"handleReceivedFotaVersion" logInformation:@"Failed to ge wearable device version"];
        
        for (id<FotaDelegate> delegate in delegateArray) {
            [delegate onVersionReceived:nil];
        }
        
        return;
    }

    NSArray* attributesListFromValue = [value componentsSeparatedByString:@";"];
    
    if (attributesListFromValue == nil) {

        [self printDebugLog:@"handleReceivedFotaVersion" logInformation:@"attributesListFromValue is nil or count is wrong"];
        
        for (id<FotaDelegate> delegate in delegateArray) {
            [delegate onVersionReceived:nil];
        }
        return;
    }
    
    SPC_FotaVersion* version = [[SPC_FotaVersion alloc] init];
    
    for (NSString *str in attributesListFromValue) {
        NSArray *keyValue = [str componentsSeparatedByString:@"="];
        if ([keyValue count] == 1) {
            [self printDebugLog:@"handleReceivedFotaVersion" logInformation:@"keyValue count is 1"];
            continue;
        }
        if ([[keyValue objectAtIndex:0] isEqualToString:SPC_VERSION_NO_STRING] == YES) {
            version.version = [keyValue objectAtIndex:1];
        }
        if ([[keyValue objectAtIndex:0] isEqualToString:SPC_RELEASE_DATE_STRING] == YES) {
            version.releaseNote = [keyValue objectAtIndex:1];
        }
        if ([[keyValue objectAtIndex:0] isEqualToString:SPC_PLATFORM_STRING] == YES) {
            version.platform = [keyValue objectAtIndex:1];
        }
        if ([[keyValue objectAtIndex:0] isEqualToString:SPC_MODEL_STRING] == YES) {
            version.module = [keyValue objectAtIndex:1];
        }
        if ([[keyValue objectAtIndex:0] isEqualToString:SPC_DEV_ID_STRING] == YES) {
            version.deviceId = [keyValue objectAtIndex:1];
        }
        if ([[keyValue objectAtIndex:0] isEqualToString:SPC_BATTERY_STRING] == YES) {
            if ([[keyValue objectAtIndex:1] isEqualToString:SPC_FEATURE_PHONE_LOW_BATTERY_STRING] == YES) {
                version.isLowBattery = YES;
            } else {
                version.isLowBattery = NO;
            }
        }
        if ([[keyValue objectAtIndex:0] isEqualToString:SPC_BRAND_STRING] == YES) {
            version.brand = [keyValue objectAtIndex:1];
        }
        if ([[keyValue objectAtIndex:0] isEqualToString:SPC_DOMAIN_STRING] == YES) {
            version.domain = [keyValue objectAtIndex:1];
        }
        if ([[keyValue objectAtIndex:0] isEqualToString:SPC_DL_KEY_STRING] == YES) {
            version.downloadKey = [keyValue objectAtIndex:1];
        }
        if ([[keyValue objectAtIndex:0] isEqualToString:SPC_PIN_CODE_STRING] == YES) {
            version.pinCode = [keyValue objectAtIndex:1];
        }
    }
    
    for (id<FotaDelegate> delegate in delegateArray) {
        [delegate onVersionReceived:version];
    }
    
}

/*******************************************************************************
 **
 ** Split the sub string with '=', and return the second string value
 **
 *******************************************************************************/
-(NSString*)getSubString:(NSString*)fullString {
    if (fullString == nil || fullString.length == 0) {
        [self printDebugLog:@"getSubString" logInformation:@"fullString is WRONG"];
        return nil;
    }
    
    NSArray* array = [fullString componentsSeparatedByString:@"="];
    return [array objectAtIndex:1];
    
}

/*******************************************************************************
 **
 ** Handle the received status value
 **
 *******************************************************************************/
-(void)handleReceivedStatus:(NSArray*)array {
    if (array == nil || [array count] != 5) {
        [self printDebugLog:@"handleReceivedStatus" logInformation:@"array is nill or EMPTY"];
        return;
    }
    NSString* receiver = [array objectAtIndex:1];
    
    if (receiver == nil || receiver.length == 0) {
        [self printDebugLog:@"handleReceivedStatus" logInformation:@"receiver is nil or EMPTY"];
        return;
    }
    
    if ([receiver isEqualToString:SPC_FOTA_RECEIVER_FIRMWARE_DPACKAGE_STRING] == NO
        && [receiver isEqualToString:SPC_FOTA_RECEIVER_FIRMWARE_UBIN_STRING] == NO
        && [receiver isEqualToString:SPC_FOTA_RECEIVER_FIRMWARE_ROCK_STRING] == NO
        && [receiver isEqualToString:SPC_FOTA_RECEIVER_FIRMWARE_FBIN_STRING] == NO) {
        [self printDebugLog:@"handleReceivedStatus" logInformation:@"NOT status receiver"];
        return;
    }
    
    NSString* str = [array objectAtIndex:4];
    int status = [str intValue];
    
    [self printDebugLog:@"handleReceivedStatus" logInformation:[NSString stringWithFormat:@"status : %d", status]];
    
    for (id<FotaDelegate> delegate in delegateArray) {
        [delegate onStatusReceived:status];
    }
    
}


////////////////////////////////////////////////////////////////////////////////
//                                                                            //
//                        DOGP callback                                       //
//                                                                            //
////////////////////////////////////////////////////////////////////////////////
-(void)onReceive:(NSData*)data {
    if (data == nil || data.length == 0) {
        [self printDebugLog:@"onReceive" logInformation:@"data is nil or EMPTY"];
        return;
    }
    
    NSString* returnString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (returnString == nil || returnString.length == 0) {
        [self printDebugLog:@"onReceive" logInformation:@"returnStirng is nil or EMPTY"];
        return;
    }
    
    NSArray* retArr = [returnString componentsSeparatedByString:@" "];
    if (retArr == nil || [retArr count] == 0) {
        [self printDebugLog:@"onReceive" logInformation:@"retArr is nil or EMPTY"];
        return;
    }
    
    //[self printDebugLog:@"onReceive" logInformation:[NSString stringWithFormat:@"array Count : %lu", (unsigned long)[retArr count]]];
    
    NSString* receiver = [retArr objectAtIndex:1];
    [self printDebugLog:@"onReceive" logInformation:receiver];
    if ([receiver isEqualToString:SPC_FOTA_RECEIVER_TYPE_GET_STRING]) {
        
        //[self printDebugLog:@"onReceive" logInformation:@"SPC_FOTA_RECEIVER_TYPE_GET_STRING"];
        
        [self handleReceivedFotaType:retArr];
        
    } else if ([receiver isEqualToString:SPC_FOTA_RECEIVER_VERSOION_STRING]) {
        
        //[self printDebugLog:@"onReceive" logInformation:@"SPC_FOTA_RECEIVER_VERSOION_STRING"];
        
        [self handleReceivedFotaVersion:retArr];
        
    } else if ([receiver isEqualToString:SPC_FOTA_RECEIVER_FIRMWARE_DPACKAGE_STRING]
               || [receiver isEqualToString:SPC_FOTA_RECEIVER_FIRMWARE_UBIN_STRING]
               || [receiver isEqualToString:SPC_FOTA_RECEIVER_FIRMWARE_ROCK_STRING]
               || [receiver isEqualToString:SPC_FOTA_RECEIVER_FIRMWARE_FBIN_STRING]) {
        
        //[self printDebugLog:@"onReceive" logInformation:@"SPC_FOTA_RECEIVER_FIRMWARE_DPACKAGE_STRING or SPC_FOTA_RECEIVER_FIRMWARE_UBIN_STRING"];
        
        [self handleReceivedStatus:retArr];
        
    } else {
        [self printDebugLog:@"onReceive" logInformation:@"unrecognized receiver from wearable device"];
    }
}

-(void)onProgress: (float)sentPercent {
    //[self printDebugLog:@"onProgress" logInformation: [NSString stringWithFormat:@"sentPercent = %.02f", sentPercent]];
    
    if (sentPercent == 1.0) {
        mCurrentTransferedCount ++;
        float pro = (float)mCurrentTransferedCount / (float)mTotalTransferCount;
        for (id<FotaDelegate> delegate in delegateArray) {
            [delegate onProgress: pro];
        }
        if (mCurrentTransferedCount == mTotalTransferCount) {
            mCurrentTransferedCount = 0;
            mTotalTransferCount = 0;
        }
    }
}

-(void)onReadyToSend {
    //[self printDebugLog:@"onReadyToSend" logInformation:@"Done"];
}

@end

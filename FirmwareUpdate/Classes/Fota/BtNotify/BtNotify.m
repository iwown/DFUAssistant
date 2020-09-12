//
//  BtNotify.m
//  BtNotify
//
//  Created by user on 2017/2/20.
//  Copyright © 2017年 Mediatek. All rights reserved.
//

/*=======================================Release Notes=============================*/
/*------------------------------------------------------------------------------
 - Version 20170627
    Fix issues:
    1. Issue: while the device connected/handshake done, device send the data
       to iPhone, the library cannot handle it
       Root Cause: the receiver array did not contains the receiver, which did not
                   send any data from iPhone to device
       Solution: While received, if the receiver did not be handled in the library
                 internally, just callback to application that the data received
 
    2. Issue: if the custom data contains space character (" "), the data parser (SPC_CommandUtils) will parse failed
       Root Cause: the data parser all the datas which is not necessory
       Solution: If the sender, receiver, action has been parsed, then just copy the rest
                 data into custom data
 
    3. Issue: Potential crash in the foreach a list
       Root Cause: while foreach a list to calling back the delegate, if the application
                   delete the delegate, crash happen
       Solution: Use a parameter to store the delegate list, foreach the new array,
                 check the delegate is deleted or not, if deleted, do not callback
                 check the delegate implemented the callback, if not, do not callback
 
 - Version 20170630
    Enhance Performance, callback delegate in a async task
 
 - Version 20170808
    Add GNSS fota support
------------------------------------------------------------------------------*/

#import "BtNotify.h"
#import "SPC_LogUtils.h"
#import "SPC_ControllerManager.h"
#import "SPC_GattLinker.h"
#import "SPC_SessionManager.h"
#import "SPC_ReadDataHandler.h"
#import "SPC_FotaOperator.h"
#import "SPC_Session.h"
#import "SPC_CommandUtils.h"


@interface BtNotify() <SPC_ReadDataHandlerDelegate, SPC_SessionDelegate, FotaDelegate> {
    
    @private
    SPC_ControllerManager       *mCMManager;
    SPC_GattLinker              *mLinker;
    SPC_SessionManager          *mSMManager;
    SPC_ReadDataHandler         *mHandler;
    
    NSMutableArray          *mCustomDelegates;
    NSMutableArray          *mFotaDelegates;
    
    SPC_FotaOperator            *mSPC_FotaOperator;
    
    NSMutableArray          *mSenderArray;
    NSMutableArray          *mReceiverArray;
}

@end


const NSString *CUR_VERSION = @"BtNotify_Version_1.0_20170808";

const NSString *N_LOG_TAG = @"BtNotify";
static BtNotify *sInstance;

@implementation BtNotify

+(id)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        LOG_I(N_LOG_TAG, @"Start to init BtNotify, Version - %@", CUR_VERSION, nil);
        sInstance = [[BtNotify alloc] init];
        [sInstance initialize];
    });
    return sInstance;
}

-(void)initialize {
    
    mCustomDelegates = [[NSMutableArray alloc] init];
    mFotaDelegates = [[NSMutableArray alloc] init];

    mLinker = [SPC_GattLinker GLSharedInstance];
    mCMManager = [SPC_ControllerManager CMSharedInstance];
    mSMManager = [SPC_SessionManager SMSharedInstance:mLinker];
    mHandler = [SPC_ReadDataHandler rdhSharedInstance];
    mSPC_FotaOperator = [SPC_FotaOperator sharedInstance];
    
    mSenderArray = [[NSMutableArray alloc] init];
    mReceiverArray = [[NSMutableArray alloc] init];

    [mSPC_FotaOperator registerFotaDelegate:self];
    [mSMManager setSessionDelegate:self];
    [mHandler setDelegate:self];
}

/*
-(NSData *)getCustomData:(NSData *)orginData {
    Byte *bytes = (Byte *)[orginData bytes];
    int spaceIndex = 0;
    int current = 0;
    for (int index = 0; index < [orginData length]; index ++) {
        if (bytes[index] == 0x20) {
            current ++;
        }
        if (current == 4) {
            spaceIndex = index;
            break;
        }
    }
    NSData *data = [orginData subdataWithRange:NSMakeRange(spaceIndex + 1, [orginData length] - spaceIndex - 1)];
    return data;
}
*/

-(void)deinit {
    [mSPC_FotaOperator deinitOperator];
    mSPC_FotaOperator = nil;
    
    [mCMManager deinit];
    mCMManager = nil;
    
    [mSMManager deinit];
    mSMManager = nil;

    [mHandler deinit];
    mHandler = nil;

    [mLinker deinit];
    mLinker = nil;

    sInstance = nil;
    
    [mCustomDelegates removeAllObjects];
    [mFotaDelegates removeAllObjects];
    
    [mSenderArray removeAllObjects];
    [mReceiverArray removeAllObjects];
}

#pragma mark - Public APIs Implementation
-(void)setGattParameters:(CBPeripheral *)peripheral
     writeCharacteristic:(CBCharacteristic *)writeChar
      readCharacteristic:(CBCharacteristic *)readChar {
    [mLinker setGattParameters:peripheral writeCharacteristic:writeChar readCharacteristic:readChar];
    LOG_I(N_LOG_TAG, @"Set gatt parameters (%@) - (%@)", [[writeChar UUID] UUIDString], [[readChar UUID] UUIDString], nil);
}

-(int)send:(NSString *)sender
   receiver:(NSString *)receiver
 dataAction:(int)action
 dataToSend:(NSData *)data
needProgress:(BOOL)needPro
sendPriority:(int)pri {
    if ((sender == nil || [sender length] ==0)
        || (data == nil || [data length] == 0)
        || (receiver == nil || [receiver length] == 0)) {
        LOG_E(N_LOG_TAG, @"Data is nil or empty", nil);
        return SPC_ERROR_CODE_WRONG_PARAMETER;
    }

    if ([mLinker getIsStarted] == NO) {
        LOG_E(N_LOG_TAG, @"BtNotify not started", nil);
        return SPC_ERROR_CODE_NOT_STARTED;
    }
    if ([mLinker getInited] == NO) {
        LOG_E(N_LOG_TAG, @"BtNotify not inited, please set gatt parameters", nil);
        return SPC_ERROR_CODE_NOT_INITED;
    }
    if ([mLinker getHandshakeDone] == NO) {
        return SPC_ERROR_CODE_NOT_HANDSHAKE_DONE;
    }
    
    if ([mSenderArray containsObject:sender] == NO) {
        [mSenderArray addObject:sender];
    }
    if ([mReceiverArray containsObject:receiver] == NO) {
        [mReceiverArray addObject:receiver];
    }
    
    SPC_Session *session = [[SPC_Session alloc] initSession:sender
                                       needProgress:needPro
                                       sendPriority:pri];

    NSData *cmdData = nil;
    NSString *cmd = [NSString stringWithFormat:@"%@ %@ %d %d %lu ", sender, receiver, action,
                     0, (unsigned long)[data length]];

    cmdData = [SPC_CommandUtils getCmdBuffer:9 command:cmd];
    
    [session setSendData:cmdData dataToSend:data];
    
    [mSMManager addSession:session];

    return SPC_ERROR_CODE_OK;
}

-(void)registerCustomDelegate:(id<SPC_NotifyCustomDelegate>)delegate {
    if (delegate != nil && ([mCustomDelegates containsObject:delegate] == NO)) {
        [mCustomDelegates addObject:delegate];
    } else {
        LOG_E(N_LOG_TAG, @"Delegate is nil or Delegate has been added", nil);
    }
}

-(void)unregisterCustomDelegate:(id<SPC_NotifyCustomDelegate>)delegate {
    if (delegate != nil && ([mCustomDelegates containsObject:delegate] == YES)) {
        [mCustomDelegates removeObject:delegate];
    } else {
        LOG_E(N_LOG_TAG, @"Delegate is nil or Delegate not exist", nil);
    }
}

-(void)registerFotaDelegate:(id<SPC_NotifyFotaDelegate>)delegate {
    if (delegate != nil && ([mFotaDelegates containsObject:delegate] == NO)) {
        [mFotaDelegates addObject:delegate];
    } else {
        LOG_E(N_LOG_TAG, @"Delegate is nil or Delegate has been added", nil);
    }
}

-(void)unregisterFotaDelegate:(id<SPC_NotifyFotaDelegate>)delegate {
    if (delegate != nil && ([mFotaDelegates containsObject:delegate] == YES)) {
        [mFotaDelegates removeObject:delegate];
    } else {
        LOG_E(N_LOG_TAG, @"Delegate is nil or Delegate not exist", nil);
    }
}

-(void)updateConnectionState:(int)newState {
    LOG_I(N_LOG_TAG, @"Update connection state to : %d", newState, nil);

    [mLinker updateConnectionState:newState];
    if (newState == CBPeripheralStateDisconnected) {
        [mSMManager handleDisconnected];
        // Update ready to send to be NO while disconnected
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *arr = [NSArray arrayWithArray:mCustomDelegates];
            for (id<SPC_NotifyCustomDelegate> del in arr) {
                if ([mCustomDelegates containsObject:del] == YES
                    && [del respondsToSelector:@selector(onReadyToSend)] == YES) {
                    [del onReadyToSend:NO];
                }
            }
        });
    }
}

-(void)handleWriteResponse:(CBCharacteristic *)responseChar error:(NSError *)err {
    LOG_D(N_LOG_TAG, @"handleWriteResponse", nil);
    [mLinker handleWriteCallback:responseChar error:err];
}

-(void)handleReadReceivedData:(CBCharacteristic *)dataChar error:(NSError *)err {
    [mLinker handleReadCallback:dataChar error:err];
}

-(BOOL)isReadyToSend {
    return [mLinker getHandshakeDone];
}

-(int)validState {
    if ([mLinker getInited] == NO) {
        return SPC_ERROR_CODE_NOT_INITED;
    }
    if ([mLinker getIsStarted] == NO) {
        return SPC_ERROR_CODE_NOT_STARTED;
    }
    if ([mLinker getHandshakeDone] == NO) {
        return SPC_ERROR_CODE_NOT_HANDSHAKE_DONE;
    }
    return SPC_ERROR_CODE_OK;
}

#pragma mark - Fota Public APIs
-(int)sendFotaTypeGetCmd {
    int value = [self validState];
    if (value != SPC_ERROR_CODE_OK) {
        return value;
    }
    [mSPC_FotaOperator sendFotaTypeCheckCommand];
    return SPC_ERROR_CODE_OK;
}

-(int)sendFotaVersionGetCmd:(int)whichType {
    int value = [self validState];
    if (value != SPC_ERROR_CODE_OK) {
        return value;
    }
    if ([mSPC_FotaOperator sendFotaVersionGetCommand:whichType] == NO) {
        return SPC_ERROR_CODE_FOTA_WRONG_TYPE;
    }
    return SPC_ERROR_CODE_OK;
}

-(int)sendFotaData:(int)whchType firmwareData:(NSData *)data {
    int value = [self validState];
    if (value != SPC_ERROR_CODE_OK) {
        return value;
    }
    if ([mSPC_FotaOperator sendFotaFirmwareData:whchType dataFromFile:data] == NO) {
        return SPC_ERROR_CODE_FOTA_WRONG_TYPE;
    }
    return SPC_ERROR_CODE_OK;
}

-(void)cancelCurrentFotaSending {
    [mSPC_FotaOperator cancelCurrentSending];
}

#pragma mark - SPC_ReadDataHandler delegate
-(void)onHandshakeDone:(BOOL)done {

    [mLinker setHandshakeDone:done];
    [mCMManager updateHandshakeDone:done];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *arr = [NSArray arrayWithArray:mCustomDelegates];
        for (id<SPC_NotifyCustomDelegate> delegate in arr) {
            if ([delegate respondsToSelector:@selector(onReadyToSend:)] == YES
                && [mCustomDelegates containsObject:delegate] == YES) {
                [delegate onReadyToSend:done];
            }
        }
    });
}

-(void)onDataReceived:(int)type handledData:(NSData *)data {
/*
    [mCMManager handleReceivedData:type handledData:data];

    NSString *receiver = [SPC_CommandUtils getReceiverTag:data];
    NSData *cusData = [SPC_CommandUtils getCustomData:data];
*/
    
    SPC_UtilData *dd = [SPC_CommandUtils parseData:data];
    if (dd == nil) {
        LOG_E(N_LOG_TAG, @"Failed to parse received data", nil);
        return;
    }
    LOG_I(N_LOG_TAG, @"Arrival receiver : %@", dd.receiver, nil);
    LOG_I(N_LOG_TAG, @"Arrival data : ..... %@", dd.data, nil);
    
    if ([mCMManager handleReceivedData:dd.receiver handledData:data] == false) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *arr = [NSArray arrayWithArray:mCustomDelegates];
            for (id<SPC_NotifyCustomDelegate> del in arr) {
                if ([del respondsToSelector:@selector(onDataArrival:arrivalData:)] == YES
                    && [mCustomDelegates containsObject:del] == YES) {
                    LOG_I(N_LOG_TAG, @"Receiver : %@, Data : %@", dd.receiver, dd.data, nil);
                    [del onDataArrival:dd.receiver arrivalData:dd.data];
                }
            }
        });
    } else {
        LOG_I(N_LOG_TAG, @"Handle data in controller", nil);
    }
}

-(void)onRequestToSend:(NSData *)sendData {
    [mLinker write:sendData];
}

-(void)onRemoteVersionReceived:(int)version {
    [mLinker setRemoteVersion:version];
}

#pragma mark - SPC_SessionManager Delegate
-(void)onProgressUpdate:(NSString *)tag progress:(float)pro {
    [mCMManager handleProgressUpdate:tag progress:pro];

    LOG_D(N_LOG_TAG, @"Progress update tag : %@ - %f", tag, pro, nil);
    
    if ([mSenderArray containsObject:tag] == YES) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSArray *arr = [NSArray arrayWithArray:mCustomDelegates];
            for (id<SPC_NotifyCustomDelegate> del in arr) {
                if ([del respondsToSelector:@selector(onProgress:newProgress:)] == YES
                    && [mCustomDelegates containsObject:del] == YES) {
                    [del onProgress:tag newProgress:pro];
                }
            }
        });
    }
}

#pragma mark - Fota Delegate
-(void)onTypeReceived:(int)fotaType {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *arr = [NSArray arrayWithArray:mFotaDelegates];
        for (id<SPC_NotifyFotaDelegate> delegate in arr) {
            if ([delegate respondsToSelector:@selector(onFotaTypeReceived:)] == YES
                && [mFotaDelegates containsObject:delegate] == YES) {
                [delegate onFotaTypeReceived:fotaType];
            }
        }
    });
}

-(void)onVersionReceived:(SPC_FotaVersion*)version {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *arr = [NSArray arrayWithArray:mFotaDelegates];
        for (id<SPC_NotifyFotaDelegate> delegate in arr) {
            if ([delegate respondsToSelector:@selector(onFotaVersionReceived:)] == YES
                && [mFotaDelegates containsObject:delegate] == YES) {
                [delegate onFotaVersionReceived:version];
            }
        }
    });
}

-(void)onStatusReceived:(int)status {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *arr = [NSArray arrayWithArray:mFotaDelegates];
        for (id<SPC_NotifyFotaDelegate> delegate in arr) {
            if ([delegate respondsToSelector:@selector(onFotaStatusReceived:)] == YES
                && [mFotaDelegates containsObject:delegate] == YES) {
                [delegate onFotaStatusReceived:status];
            }
        }
    });
}

-(void)onProgress:(float)progress {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *arr = [NSArray arrayWithArray:mFotaDelegates];
        for (id<SPC_NotifyFotaDelegate> delegate in arr) {
            if ([delegate respondsToSelector:@selector(onFotaProgress:)] == YES
                && [mFotaDelegates containsObject:delegate] == YES) {
                [delegate onFotaProgress:progress];
            }
        }
    });
}

@end

#pragma mark - SPC_FotaVersion
@implementation SPC_FotaVersion


@end

//
//  SPC_GattLinker.m
//  BtNotify
//
//  Created by user on 2017/2/20.
//  Copyright © 2017年 Mediatek. All rights reserved.
//

#import "SPC_GattLinker.h"
#import "SPC_LogUtils.h"
#import "SPC_Command.h"
#import <UIKit/UIKit.h>
#import "SPC_ReadDataHandler.h"

static SPC_GattLinker *sLinker;
const NSString *SPC_L_LOG_TAG = @"SPC_GattLinker";

const static int SPC_DEFAULT_MAX_WRITING_LENGTH = 20;

NSString *const SPC_IOS_INDICATION = @"ios indication";

@interface SPC_GattLinker() {
    
    @private
    CBPeripheral                *mPeripheral;
    CBCharacteristic            *mWriteChar;
    CBCharacteristic            *mReadChar;
    NSMutableArray              *mDelegateList;
    
    int                         mMaxSendSize;
    int                         mConnectionState;
}

@end


@implementation SPC_GattLinker

@synthesize handshakeDone;
@synthesize inited;
@synthesize isWriting;
@synthesize isStarted;


+(id)GLSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        LOG_I(SPC_L_LOG_TAG, @"Start to init SPC_GattLinker", nil);
        sLinker = [[SPC_GattLinker alloc] init];
        [sLinker initialize];
    });
    return sLinker;
}

-(void)initialize {
    mDelegateList = [[NSMutableArray alloc] init];
    mMaxSendSize = SPC_DEFAULT_MAX_WRITING_LENGTH;
    handshakeDone = NO;
    isStarted = NO;
    inited = NO;
    isWriting = NO;
}

-(void)setGattParameters:(CBPeripheral *)peripheral
     writeCharacteristic:(CBCharacteristic *)writeChar
      readCharacteristic:(CBCharacteristic *)readChar {
    if (peripheral == nil
        || writeChar == nil
        || readChar == nil) {
        LOG_E(SPC_L_LOG_TAG, @"Wrong parameter", nil);
        return;
    }
    mPeripheral = peripheral;
    mWriteChar = writeChar;
    mReadChar = readChar;
    
    inited = YES;
    
    if (mConnectionState == CBPeripheralStateConnected
        && isStarted == NO) {
        [self startBtNotify];
    }
}

-(void)deinit {
    mPeripheral = nil;
    mWriteChar = nil;
    mReadChar = nil;
    
    sLinker = nil;
    handshakeDone = NO;
    inited = NO;
    isStarted = NO;
}

#pragma mark - Write
-(void)write:(NSData *)data {
    if (mPeripheral == nil
        || mWriteChar == nil) {
        LOG_E(SPC_L_LOG_TAG, @"Peripheral or write characteristic is nil", nil);
        return;
    }
    if (isWriting == NO) {
        isWriting = YES;
        [mPeripheral writeValue:data forCharacteristic:mWriteChar type:CBCharacteristicWriteWithResponse];
    }
}

#pragma mark - Handle Read Write Response
-(void)handleWriteCallback:(CBCharacteristic *)ch error:(NSError *)err {
    if (ch == mWriteChar) {
        isWriting = NO;
        LOG_D(SPC_L_LOG_TAG, @"Update iswriting to no", nil);
        for (id<SPC_LinkerDelegate> delegate in mDelegateList) {
            if ([delegate respondsToSelector:@selector(onDataSent)] == YES) {
                [delegate onDataSent];
            }
        }
    } else {
        LOG_E(SPC_L_LOG_TAG, @"Characteristic not match write char", nil);
    }
}

-(void)handleReadCallback:(CBCharacteristic *)ch error:(NSError *)err {
    if (ch == mReadChar) {
        NSData *readData = [ch value];
        LOG_D(SPC_L_LOG_TAG, @"Read/Update value length (%lu)", (unsigned long)[readData length], nil);
        
        NSString *str = [[NSString alloc] initWithData:readData encoding:NSUTF8StringEncoding];
        if ([str length] == [SPC_IOS_INDICATION length]
            && [str isEqualToString:SPC_IOS_INDICATION] == YES) {
            // If received data is ios indication, start read characteristic from device
            [mPeripheral readValueForCharacteristic:mReadChar];
            return;
        }
        // Handle data from device
        if (err != nil) {
            LOG_E(SPC_L_LOG_TAG, @"Error happen %@", [err localizedFailureReason], nil);
            return;
        }
        [[SPC_ReadDataHandler rdhSharedInstance] processReceivedData:readData];
    } else {
        LOG_E(SPC_L_LOG_TAG, @"Characteristic not match read char", nil);
    }
}

#pragma mark - Register/Unregister Delegate
-(void)registerLinkerDelegate:(id<SPC_LinkerDelegate>)delegate {
    if (delegate != nil && [mDelegateList containsObject:delegate] == NO) {
        LOG_D(SPC_L_LOG_TAG, @"Register delegate", nil);
        [mDelegateList addObject:delegate];
    } else {
        LOG_D(SPC_L_LOG_TAG, @"Parameter is wrong", nil);
    }
}

-(void)unregisterLinkerDelegate:(id<SPC_LinkerDelegate>)delegate {
    if (delegate != nil && [mDelegateList containsObject:delegate] == YES) {
        LOG_D(SPC_L_LOG_TAG, @"Register delegate", nil);
        [mDelegateList removeObject:delegate];
    }
}

#pragma mark - Get Max Send Size
-(int)getSendMaxSize {
    return mMaxSendSize;
}

#pragma mark - Update Connection State
-(void)updateConnectionState:(int)newState {
    mConnectionState = newState;
    if (mConnectionState == CBPeripheralStateConnecting) {
        return;
    }
    if (mConnectionState == CBPeripheralStateConnected) {
        if (mPeripheral == nil
            || mWriteChar == nil
            || mReadChar == nil) {
            LOG_E(SPC_L_LOG_TAG, @"Please set gatt parameters", nil);
            return;
        }
        if (isStarted == NO) {
            [self startBtNotify];
        }
    } else {
        LOG_D(SPC_L_LOG_TAG, @"Device disconnected", nil);
        mPeripheral = nil;
        mWriteChar = nil;
        mReadChar = nil;
        handshakeDone = NO;
        isStarted = NO;
        inited = NO;
        isWriting = NO;
        mMaxSendSize = SPC_DEFAULT_MAX_WRITING_LENGTH;
        
        [[SPC_ReadDataHandler rdhSharedInstance] reset];
     }
}

-(void)setRemoteVersion:(int)version {
    /*if (mSettableMaxLength != 0) {
        return mSettableMaxLength;
    }*/
    if (version >= 331) {
        float currentSystemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        LOG_D(SPC_L_LOG_TAG, @"Current device version : %f", currentSystemVersion, nil);
        if (currentSystemVersion < 8.0) {
            mMaxSendSize = 128;
        } else if (currentSystemVersion < 10.0) {
            mMaxSendSize = 150;
        } else {
            mMaxSendSize = 300;
        }
    }
    LOG_I(SPC_L_LOG_TAG, @"Max send size : %d", mMaxSendSize, nil);
}

-(void)setHandshakeDone:(BOOL)done {
    if (handshakeDone != done) {
        handshakeDone = done;
        LOG_I(SPC_L_LOG_TAG, @"Handle shake done : %d", handshakeDone, nil);
    }
}

-(void)startBtNotify {
    if (mPeripheral == nil
        || mWriteChar == nil
        || mReadChar == nil) {
        LOG_E(SPC_L_LOG_TAG, @"Gatt parameters is nil", nil);
        return;
    }
    isStarted = YES;
    isWriting = NO;

    [mPeripheral setNotifyValue:YES forCharacteristic:mReadChar];
    //[mPeripheral readValueForCharacteristic:mReadChar];

    [self sendReqvData];
}

-(void)sendReqvData {
    NSString *str = @"REQV";
    
    int retLen = 0;

    unsigned char *result = SPC_getDatacmd(2, (unsigned char *)[str UTF8String], &retLen);
    LOG_D(SPC_L_LOG_TAG, @"Reqv data : (%d - %s)", retLen, result, nil);
    
    NSData *data = [NSData dataWithBytes:result length:retLen];
    [self write:data];
}

@end

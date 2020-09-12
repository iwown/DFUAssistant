//
//  SPC_ReadDataHandler.m
//  BtNotify
//
//  Created by user on 2017/2/23.
//  Copyright © 2017年 Mediatek. All rights reserved.
//

#import "SPC_ReadDataHandler.h"
#import "SPC_LogUtils.h"
#import "SPC_Command.h"
#import "SPC_GattLinker.h"
#import "SPC_Session.h"
#import "SPC_SessionManager.h"


#pragma mark - Static values

const static int SPC_READ_IDLE = 0;
const static int SPC_READ_PRE = 1;
const static int SPC_READ_CMD = 2;


const int NOTREC = 0;
const int DATA = 1;
const int SYNC = 2;
const int ACKY = 3;
const int VERN = 4;
const int MAPX = 5;
const int MAPD = 6;
const int CAPC = 7;
const int MREE = 8;
const int EXCD = 9;

const static int NOTIFY_MINI_HEADER_LENGHT = 8;
const static int NOTIFY_SYNC_LENGTH = 4;

const int sNameIndex = 36;

const Byte HEADER_F0 = 0xF0;
const Byte HEADER_F1 = 0xF1;

static SPC_ReadDataHandler *sInstance;

const NSString *DEVICE_INFO = @"mtk_deviceinfo";
const NSString *BT_NOTIFY_APK = @"mtk_bnapk";
const NSString *BT_NOTIFY_TIME = @"bnsrv_time";

const NSString *SPC_R_LOG_TAG = @"SPC_ReadDataHandler";


#pragma mark - SPC_ReadDataHandler private
@interface SPC_ReadDataHandler() {
@private
    NSMutableData       *receivedBuf;
    int                 curCmdType;
    int                 curState;
    int                 curCmdBufLength;
    int                 curDataBufLength;
    id<SPC_ReadDataHandlerDelegate> mDelegate;
}
@end




@implementation SPC_ReadDataHandler

#pragma mark - Static instance API
+(id)rdhSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        LOG_I(SPC_R_LOG_TAG, @"Start to init SPC_ReadDataHandler", nil);
        sInstance = [[SPC_ReadDataHandler alloc] init];
        [sInstance initialize];
    });
    return sInstance;
}

-(void)initialize {
    receivedBuf = [[NSMutableData alloc] init];
}

#pragma mark - Public APIs
-(void)deinit {
    mDelegate = nil;
    [receivedBuf replaceBytesInRange:NSMakeRange(0, [receivedBuf length]) withBytes:nil length:0];
    receivedBuf = nil;
    
    sInstance = nil;
    
    curState = SPC_READ_IDLE;
    curCmdType = 0;
    curCmdBufLength = 0;
    curDataBufLength = 0;
}

-(void)reset {
    LOG_D(SPC_R_LOG_TAG, @"Rest Read Data Handler", nil);
    [receivedBuf replaceBytesInRange:NSMakeRange(0, [receivedBuf length]) withBytes:nil length:0];
    curState = SPC_READ_IDLE;
    curCmdType = 0;
    curCmdBufLength = 0;
    curDataBufLength = 0;
}

-(void)processReceivedData:(NSData *)data {
    if (data == nil || [data length] == 0) {
        LOG_E(SPC_R_LOG_TAG, @"Handle data is nil", nil);
        return;
    }
    LOG_D(SPC_R_LOG_TAG, @"Before append data length : %lu", (unsigned long)[receivedBuf length], nil);
    
    [receivedBuf appendData:data];
    
    LOG_D(SPC_R_LOG_TAG, @"After append data length : %lu", (unsigned long)[receivedBuf length], nil);
    
    if ([receivedBuf length] > 0) {
        [self runningFSM];
    }
}

-(void)setDelegate:(id<SPC_ReadDataHandlerDelegate>)delegate {
    if (delegate != nil) {
        mDelegate = delegate;
    }
}

#pragma mark - Private APIs
-(void)runningFSM {
    if ([receivedBuf length] <= 0) {
        return;
    }
    switch (curState) {
        case SPC_READ_IDLE:
            [self handleCmdLength];
            break;
            
        case SPC_READ_PRE:
            [self handleDataLength];
            break;
            
        case SPC_READ_CMD:
            [self handleData];
            break;
            
        default:
            break;
    }
}

#pragma mark - Try to get Command length
-(void)handleCmdLength {
    LOG_D(SPC_R_LOG_TAG, @"Current state : %d, length : %lu", curState, (unsigned long)[receivedBuf length], nil);
    if (curState != SPC_READ_IDLE) {
        return;
    }
    if ([receivedBuf length] < NOTIFY_MINI_HEADER_LENGHT) {
        return;
    }
    int cmdPos = -1;
    int index = 0;
    Byte *bytes = (Byte *)[receivedBuf bytes];
    for (index = 0;  index < [receivedBuf length] - NOTIFY_SYNC_LENGTH; index++) {
        if (bytes[index] == HEADER_F0
            && bytes[index + 1] == HEADER_F0
            && bytes[index + 2] == HEADER_F0
            && bytes[index + 3] == HEADER_F1) {
            LOG_D(SPC_R_LOG_TAG, @"Succeed to get F0F0F0F1", nil);
            cmdPos = index;
            break;
        }
    }
    
    if (cmdPos != -1) {
        // Succeed to find F0F0F0F1 header
        curCmdBufLength = (bytes[index + 4] << 24)
                            | (bytes[index + 5] << 16)
                            | (bytes[index + 6] << 8)
                            | (bytes[index + 7]);
        [receivedBuf replaceBytesInRange:NSMakeRange(0, index + NOTIFY_MINI_HEADER_LENGHT) withBytes:nil length:0];
        LOG_D(SPC_R_LOG_TAG, @"After calculate command buf length (received length : %lu)", (unsigned long)[receivedBuf length], nil);
        LOG_D(SPC_R_LOG_TAG, @"Command buffer length : %d", curCmdBufLength, nil);
        
        curState = SPC_READ_PRE;
        [self runningFSM];
    } else {
        // Failed to find F0F0F0F1 header from current received buffer
        [receivedBuf replaceBytesInRange:NSMakeRange(0, NOTIFY_MINI_HEADER_LENGHT) withBytes:nil length:0];
        LOG_E(SPC_R_LOG_TAG, @"Failed to get F0F0F0F1, after length : %lu", (unsigned long)[receivedBuf length], nil);
        
        curState = SPC_READ_IDLE;
        [self runningFSM];
    }
}

#pragma mark - Try to get data length
-(void)handleDataLength {
    LOG_D(SPC_R_LOG_TAG, @"Current buffer : %@   Current buffer length : %lu, cmd length : %d", receivedBuf, (unsigned long)[receivedBuf length], curCmdBufLength, nil);
    if ([receivedBuf length] < curCmdBufLength) {
        return;
    }
    
    NSData *cmdbuf = [receivedBuf subdataWithRange:NSMakeRange(0, curCmdBufLength)];

    Byte *bytes = (Byte *)[cmdbuf bytes];

    curCmdType = SPC_getCmdType(bytes, curCmdBufLength);
    LOG_D(SPC_R_LOG_TAG, @"Get command type : %d", curCmdType, nil);
    
    [receivedBuf replaceBytesInRange:NSMakeRange(0, curCmdBufLength) withBytes:nil length:0];
    
    if ([[SPC_GattLinker GLSharedInstance] getHandshakeDone] == NO) {
        if (curCmdType == ACKY) {
            LOG_D(SPC_R_LOG_TAG, @"ACKY return", nil);
        } else if (curCmdType == VERN) {
            LOG_D(SPC_R_LOG_TAG, @"VERN return 1", nil);
        } else {
            LOG_D(SPC_R_LOG_TAG, @"Cannot handle data without handshake", nil);
            int length = SPC_getDataLength(bytes, curCmdBufLength);
            NSUInteger minlength = length > receivedBuf.length ? receivedBuf.length : length;

            [receivedBuf replaceBytesInRange:NSMakeRange(0, minlength) withBytes:nil length:0];
            curState = SPC_READ_IDLE;
            curCmdBufLength = 0;
            curCmdType = 0;
            [self runningFSM];
            return;
        }
    } else {
        if (curCmdType == VERN) {
            [receivedBuf replaceBytesInRange:NSMakeRange(0, [receivedBuf length]) withBytes:nil length:0];
            curState = SPC_READ_IDLE;
            LOG_D(SPC_R_LOG_TAG, @"VERN return 2", nil);
            return;
        }
    }
    
    curDataBufLength = SPC_getDataLength(bytes, curCmdBufLength);
    LOG_D(SPC_R_LOG_TAG, @"Received data length : %d", curDataBufLength, nil);
    if (curDataBufLength == -1) {
        curState = SPC_READ_IDLE;
        return;
    }
    curState = SPC_READ_CMD;
    [self runningFSM];
}

#pragma  mark - Handle the real data
-(void)handleData {
    LOG_D(SPC_R_LOG_TAG, @"Current received buffer length : %lu, data buf length : %d", (unsigned long)[receivedBuf length], curDataBufLength, nil);
    if (curDataBufLength > [receivedBuf length]) {
        return;
    }
    // get the real data from received buffer
    NSData *receiveData = [receivedBuf subdataWithRange:NSMakeRange(0, curDataBufLength)];
    LOG_D(SPC_R_LOG_TAG, @"Received data length : %lu", (unsigned long)[receiveData length], nil);
    
    // replace received data with nil
    [receivedBuf replaceBytesInRange:NSMakeRange(0, curDataBufLength) withBytes:nil length:0];
    LOG_D(SPC_R_LOG_TAG, @"Received buffer length (After data) : %lu", (unsigned long)[receivedBuf length], nil);
    curState = SPC_READ_IDLE;
    curCmdBufLength = 0;
    curDataBufLength = 0;
    
    LOG_D(SPC_R_LOG_TAG, @"Current cmd type : %d", curCmdType, nil);
    if (curCmdType == ACKY) {
        LOG_I(SPC_R_LOG_TAG, @"Received Command =========ACKY", nil);
        if (mDelegate != nil && [mDelegate respondsToSelector:@selector(onHandshakeDone:)] == YES) {
            [mDelegate onHandshakeDone:YES];
        }

    } else if (curCmdType == VERN) {
        LOG_I(SPC_R_LOG_TAG, @"Received Command =========VERN", nil);
        NSString *versionString = [[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
        int version = [versionString intValue];
        LOG_D(SPC_R_LOG_TAG, @"Current remote device version : %d", version, nil);
        if (mDelegate != nil && [mDelegate  respondsToSelector:@selector(onRemoteVersionReceived:)] == YES) {
            [mDelegate onRemoteVersionReceived:version];
        }
        [self sendSyncTime:NO];

    } else if (curCmdType == EXCD) {
        LOG_I(SPC_R_LOG_TAG, @"Received Command =========EXCD", nil);
        NSString *command = [[NSString alloc] initWithData:receiveData encoding:NSUTF8StringEncoding];
        NSArray *commands = [command componentsSeparatedByString:@" "];
        if ([[commands objectAtIndex:1] isEqual:BT_NOTIFY_APK] == YES) {
            if ([[commands objectAtIndex:0] isEqual:BT_NOTIFY_TIME] == YES) {
                [self sendSyncTime:YES];
            } else {
                if (mDelegate != nil && [mDelegate respondsToSelector:@selector(onDataReceived:handledData:)] == YES) {
                    [mDelegate onDataReceived:curCmdType handledData:receiveData];
                }
            }
        } else if ([[commands objectAtIndex:1] isEqual:DEVICE_INFO]) {
            if ([[commands objectAtIndex:2] isEqual:@"1"] == YES) {
                LOG_I(SPC_R_LOG_TAG, @"Received device name : %@", [[NSString alloc] initWithData:receiveData encoding:NSUTF8StringEncoding], nil);
            } else {
                LOG_I(SPC_R_LOG_TAG, @"Received device infor", nil);
            }
        } else {
            if (mDelegate != nil && [mDelegate respondsToSelector:@selector(onDataReceived:handledData:)] == YES) {
                [mDelegate onDataReceived:curCmdType handledData:receiveData];
            }
        }
    } else {
        LOG_I(SPC_R_LOG_TAG, @"Received Command =========OTHER", nil);
        [mDelegate onDataReceived:curCmdType handledData:receiveData];
    }
    
    if ([receivedBuf length] == 0) {
        return;
    } else {
        [self runningFSM];
    }
    return;
}

/*
-(void)handleWearbleInfor:(NSData *)data {
    LOG_D(SPC_R_LOG_TAG, @"handleWearableInfo ++", nil);
    
    NSString *command = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *commands = [command componentsSeparatedByString: @" "];
    if (commands == nil || [commands count] < 3) {
        LOG_D(SPC_R_LOG_TAG, @"handleWearableInfo::return ...", nil);
        return;
    }
    
    NSString *EDR_Address = [[[commands objectAtIndex: 0] uppercaseString] stringByReplacingOccurrencesOfString: @"-" withString: @":"];
    NSString *LE_Address = [[[commands objectAtIndex: 1] uppercaseString] stringByReplacingOccurrencesOfString: @"-" withString: @":"];
    
    int index = sNameIndex;
    
    Byte *dataBuffer1 = (Byte *)[data bytes];
    
    for (int i = index; i < [data length]; i ++) {
        if (dataBuffer1[i] == 0) {
            index = i;
            break;
        }
    }

    Byte *nameBuffer = (Byte *)malloc(index - sNameIndex);
    for (int j = 0, k = sNameIndex; j < index - sNameIndex; j ++, k ++) {
        nameBuffer[j] = dataBuffer1[k];
    }
    
    int nameBufferLength = index - sNameIndex;
    
    NSString* name = [[NSString alloc] initWithBytes:nameBuffer length:nameBufferLength encoding:NSUTF8StringEncoding];
    free(nameBuffer);
    
    if (name && [name length] > 18) {
        name = [name substringToIndex: 18];
    }
    
    LOG_D(SPC_R_LOG_TAG, @"handleWearableInfo::name = %@, EDR = %@, LE = %@", name, EDR_Address, LE_Address, nil);
}
*/

-(void)sendSyncTime:(BOOL)userNewFormat {
    LOG_D(SPC_R_LOG_TAG, @"userNewFormat = %d", userNewFormat);
    int timestamp = [[NSDate date] timeIntervalSince1970];
    int timezone = 8;
    
    int time = timestamp / 1000;
    
    NSString *timestamp1 = [NSString stringWithFormat:@"%d", time];
    NSString *timezone1 = [NSString stringWithFormat: @"%d", timezone];
    if (userNewFormat) {
        int datalen = (int)[timestamp1 length] + 1 + (int)[timezone1 length];
        NSString *syncTime_header = [NSString stringWithFormat:@"bnsrv_time mtk_bnapk 0 0 %@", [NSString stringWithFormat:@"%d", datalen]];
        NSString *syncTime_data = [NSString stringWithFormat:@"%@ %@", timestamp1, timezone1];
        
        int resultLen = 0;
        int *pResultLen = &resultLen;
        unsigned char *result = SPC_getDatacmd(EXCD, (unsigned char*)[syncTime_header UTF8String], pResultLen);//need to improve
        unsigned char *data = (unsigned char*)[syncTime_data UTF8String];

        SPC_Session *ses = [[SPC_Session alloc] initSession:@"SyncTime" needProgress:NO sendPriority:SPC_PRIORITY_NORMAL];
        [ses setSendData:[NSData dataWithBytes:result length:resultLen] dataToSend:[NSData dataWithBytes:data length:strlen((char *)data)]];
        [[SPC_SessionManager sharedInstance] addSession:ses];
        
    } else {
        NSString *syncTime = [NSString stringWithFormat:@"%@ %@ %@ %@", timestamp1, timezone1, @"1.1", @"IOS"];
        unsigned char *time = (unsigned char*)[syncTime UTF8String];
        
        LOG_D(SPC_R_LOG_TAG, @"[BLE][ReadDataParser] sendSyncTime:: syncTime = %@", syncTime);
        
        int tempLen = 0;
        int *pTempLen = &tempLen;
        unsigned char *result = SPC_getDatacmd(SYNC, time, pTempLen);//need to improve
        
        NSData* data = [NSData dataWithBytes: result length: tempLen];
        
        if (mDelegate != nil && [mDelegate respondsToSelector:@selector(onRequestToSend:)] == YES) {
            [mDelegate onRequestToSend:data];
        }
        
    }
}

@end

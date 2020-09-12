//
//  ReadDataParser.m
//  MTKBleManager
//
//  Created by user on 11/8/14.
//  Copyright (c) 2014 ___MTK___. All rights reserved.
//

#import "ReadDataParser.h"
#import "SPC_Command.h"
#import "SPC_ControllerManager.h"
#import "SPC_SessionManager.h"
#import "SPC_Session.h"
#import "SPC_LogUtils.h"
#import "SPC_GATTLinker.h"

const static int READ_IDLE = 0;
const static int READ_PRE = 1;
const static int READ_CMD = 2;

const static int NOTIFY_MINI_HEADER_LENGHT = 8;
const static int NOTIFY_SYNC_LENGTH = 4;

const static int CMD_1 = 1;
const static int CMD_2 = 2;
const static int CMD_3 = 3;
const static int CMD_4 = 4;
const static int CMD_5 = 5;
const static int CMD_6 = 6;
const static int CMD_7 = 7;
const static int CMD_8 = 8;
const static int CMD_9 = 9;

//static int sNameIndex = 36;

static BOOL isOlderThanVersionTow = YES;

const NSString *RDP_LOG_TAG = @"ReadDataParser";
const NSString *DEVICEINFO_RECEIVER = @"mtk_deviceinfo";
const NSString *DEVICEINFO_SENDER = @"bnsrv_device";
const NSString *EXTRA_DATA = @"EXTRA_DATA";

@interface ReadDataParser() {
@private
    int mState;
    Byte *receiveBuffer;
    Byte *commandBuffer;
    Byte *dataBuffer;
    int receiveBufferLength;
    int dataBufferLength;
    int cmdBufferLength;
    int mCommandtype;
}

@end

@implementation ReadDataParser

static ReadDataParser *this = nil;

+ (id) initReadDataParser {
    
    if (!this) {
        this = [[ReadDataParser alloc] init];
    }
    return this;
}

- (id) init {
    self = [super init];
    if (self) {
        receiveBuffer = (Byte *)malloc(50*1024);
        mState = READ_IDLE;
        
        receiveBufferLength = 0;
        dataBufferLength = 0;
        cmdBufferLength = 0;
    }
    
    return self;
}

-(void)deinit {
    receiveBufferLength = 0;
    dataBufferLength = 0;
    free(dataBuffer);
    free(receiveBuffer);
    receiveBuffer = nil;
    dataBuffer = nil;
    mState = READ_IDLE;
    this = nil;

}

- (void) syncReadData: (NSData *)data {
    NSLog(@"[BLE][ReadDataParser]syncReadData ++");
    if (data == nil || data.length == 0) {
        NSLog(@"[BLE][ReadDataParser] syncReadData :: data is WRONG");
        return;
    }
    Byte *srcDataBuffer = (Byte *)[data bytes];
    NSLog(@"[BLE][ReadDataParser] syncReadData :: receiveBufferLength : %d, data length : %lu", receiveBufferLength, (unsigned long)[data length]);
    for (int i =0, j = receiveBufferLength; i< [data length]; i ++, j ++) {
        receiveBuffer[j] = srcDataBuffer[i];
    }
    receiveBufferLength = receiveBufferLength + (int)[data length];
    NSLog(@"[BLE][ReadDataParser] syncReadData :: receiveBufferLength after : %d", receiveBufferLength);
    [self runningReadFSM];
}

- (void)clearBuffer {
    receiveBufferLength = 0;
    dataBufferLength = 0;
    cmdBufferLength = 0;
}

//private action
- (void)runningReadFSM {
    NSLog(@"[BLE][ReadDataParser]runningReadFSM ++, mState = %d", mState);
//    while (threadToBeStop == NO) {
        switch (mState) {
            case READ_IDLE:
                [self getCommandLength];
                break;
                
            case READ_PRE:
                [self getCmdAndDataLength];
                break;
                
            case READ_CMD:
                [self getData];
                break;
                
            default:
                break;
        }
//    }
}

//to improve
- (void)getCommandLength {
    NSLog(@"[BLE][ReadDataParser]getCommandLength ++");
    if (mState != READ_IDLE) {
        return;
    }
    
    NSLog(@"[BLE][ReadDataParser] getCommandLength :: receiveBufferLength = %d", receiveBufferLength);
    
    if (receiveBufferLength < NOTIFY_MINI_HEADER_LENGHT) {
        NSLog(@"[BLE][ReadDataParser]getCommandLength:: receive buffer too short");
        return;
    }

    int cmdPos = -1;
    int i = 0;
    int j = 0;
    for (i = 0; i< receiveBufferLength - NOTIFY_SYNC_LENGTH; i ++) {
        if (receiveBuffer[i] == (Byte)0xf0
            && receiveBuffer[i+1] == (Byte)0xf0
            && receiveBuffer[i+2] == (Byte)0xf0
            && receiveBuffer[i+3] == (Byte)0xf1) {
            cmdPos = i;
            NSLog(@"[BLE][ReadDataParser]getCommandLength:: get F0F0F0F1 success");
            break;
        }
    }
    
    if (cmdPos != -1) {
        cmdBufferLength = receiveBuffer[i+4] << 24 | receiveBuffer[i+5] << 16 | receiveBuffer[i+6] <<8 | receiveBuffer[i+7];
        
        //receiveBuffer << 8 Byte
        Byte *temp = (Byte *)malloc(receiveBufferLength);
        for (i = 0; i < receiveBufferLength; i ++) {
            temp[i] = receiveBuffer[i];
        }

        for (i = NOTIFY_MINI_HEADER_LENGHT, j = 0; i < receiveBufferLength; i ++, j ++) {
            receiveBuffer[j] = temp[i];
        }

        receiveBufferLength = receiveBufferLength - NOTIFY_MINI_HEADER_LENGHT;

        mState = READ_PRE;
        [self runningReadFSM];
        
        free(temp);
        temp = nil;
        
        NSLog(@"[BLE][ReadDataParser]getCommandLength::get cmdBufferlength success, cmdBufferLength = %d, receiveBufferLength = %d", cmdBufferLength, receiveBufferLength);
    } else {
        //receiveBuffer << 8 Byte
        Byte *temp = (Byte *)malloc(receiveBufferLength);
        for (i = 0; i < receiveBufferLength; i ++) {
            temp[i] = receiveBuffer[i];
        }
        
        for (i = NOTIFY_MINI_HEADER_LENGHT, j = 0; i < receiveBufferLength; i ++, j ++) {
            receiveBuffer[j] = temp[i];
        }
        
        receiveBufferLength = receiveBufferLength - NOTIFY_MINI_HEADER_LENGHT;
        mState = READ_IDLE;
        [self runningReadFSM];
        
        free(temp);
        temp = nil;
        
        NSLog(@"[BLE][ReadDataParser]getCommandLength::get cmdBufferlength fail, cmdBufferLength = %d, receiveBufferLength = %d", cmdBufferLength, receiveBufferLength);
    }
}

- (void)getCmdAndDataLength {
     NSLog(@"[BLE][ReadDataParser]getCmdAndDataLength ++");
    
    if (receiveBufferLength < cmdBufferLength) {
        NSLog(@"[BLE][ReadDataParser]getCmdAndDataLength:: receiveBufferLength < cmdBufferLength");
        return;
    }
    
    commandBuffer = (Byte *)malloc(cmdBufferLength);
    int i=0, j= 0;
    for (i = 0; i < cmdBufferLength; i ++) {
        commandBuffer[i] = receiveBuffer[i];
    }

    //receiveBuffer << cmdBufferLength
    Byte *temp = (Byte *)malloc(receiveBufferLength);
    for (i = 0; i < receiveBufferLength; i ++) {
        temp[i] = receiveBuffer[i];
    }
    for (i = cmdBufferLength, j = 0; i < receiveBufferLength; i ++, j ++) {
        receiveBuffer[j] = temp[i];
    }
    
    free(temp);
    receiveBuffer[receiveBufferLength - cmdBufferLength] = 0;
    receiveBufferLength = receiveBufferLength - cmdBufferLength;

    NSLog(@"[BLE][ReadDataParser]getCmdAndDataLength::get cmdBuffer success, cmdBufferlength = %d, receiveBufferlength = %d", cmdBufferLength, receiveBufferLength);
    mCommandtype = SPC_getCmdType(commandBuffer, cmdBufferLength);
    
    NSLog(@"[BLE][ReadDataParser]getCmdAndDataLength:: mCommandtype = %d", mCommandtype);
    if ([[SPC_GattLinker GLSharedInstance] getHandshakeDone] == NO) {
        if (mCommandtype == CMD_3) {
            NSLog(@"[BLE][ReadDataParser]getCmdAndDataLength::isHandshake = true");
            //[mManager sethandShakedone: YES];
            [[SPC_GattLinker GLSharedInstance] setHandshakeDone:YES];
        } else if (mCommandtype == CMD_4) {
            isOlderThanVersionTow = NO;
            [self handShakedone];
            NSLog(@"[BLE][ReadDataParser]getCmdAndDataLength::get the version success");
        } else {
            mState = READ_IDLE;
            return;
        }
    } else {
        if (mCommandtype == CMD_4) {
            receiveBuffer[0] = 0;
            receiveBufferLength = 0;
            mState = READ_IDLE;
            NSLog(@"[BLE][ReadDataParser]getCmdAndDataLength:: cmd_4 return");
            return;
        }
    }
    
    if (mCommandtype == CMD_1 || mCommandtype == CMD_5 || mCommandtype == CMD_6
        || mCommandtype == CMD_7 || mCommandtype == CMD_8 || mCommandtype == CMD_9) {
        dataBufferLength = SPC_getDataLength(commandBuffer, cmdBufferLength);
        NSLog(@"[BLE][ReadDataParser]getCmdAndDataLength:: get databufferlength success: %d", dataBufferLength);
        if (dataBufferLength == -1) {
            mState = READ_IDLE;
            return;
        }
    } else if (mCommandtype == CMD_3) {
        dataBufferLength = SPC_getDataLength(commandBuffer, cmdBufferLength);
        NSLog(@"[BLE][ReadDataParser]getCmdAndDataLength:: cmd_3 bufferlength = %d", dataBufferLength);
        if (dataBufferLength == -1) {
            mState = READ_IDLE;
            return;
        }
    } else if (mCommandtype == CMD_4) {
        dataBufferLength = SPC_getDataLength(commandBuffer, cmdBufferLength);
        NSLog(@"[BLE][ReadDataParser]getCmdAndDataLength:: cmd_4 bufferlength = %d", dataBufferLength);
        if (dataBufferLength == -1) {
            mState = READ_IDLE;
            return;
        }
    } else {
        mState = READ_IDLE;
        return;
    }
    mState = READ_CMD;
    [self runningReadFSM];
}

//private action
- (void)getData {
    NSLog(@"[BLE][ReadDataParser]getData :: dataBufferLength : %d, receiveBufferLength : %d", dataBufferLength, receiveBufferLength);
    
    int i = 0, j = 0;
    if (dataBufferLength <= receiveBufferLength) {
        dataBuffer = (Byte *)malloc(dataBufferLength);
        for (i = 0; i < dataBufferLength; i ++) {
            dataBuffer[i] = receiveBuffer[i];
        }
        
        //receiveBuffer << dataBufferLength
        Byte *temp = (Byte *)malloc(receiveBufferLength);
        for (i = 0; i < receiveBufferLength; i ++) {
            temp[i] = receiveBuffer[i];
        }
        for (i = dataBufferLength, j = 0; i < receiveBufferLength; i ++, j ++) {
            receiveBuffer[j] = temp[i];
        }
        free(temp);
        receiveBuffer[receiveBufferLength - dataBufferLength] = 0;
        receiveBufferLength = receiveBufferLength - dataBufferLength;
        
        mState = READ_IDLE;
        
        //reset databufferlength and cmdbufferlength
        int tempDataBufferLength = dataBufferLength;
        dataBufferLength = 0;
        cmdBufferLength = 0;
        
        if (mCommandtype == CMD_9) {
            NSLog(@"[BLE][ReadDataParser] getData:: mCommandtype ======= CMD_9");
            
            NSString *command = [[NSString alloc] initWithBytes: dataBuffer length:tempDataBufferLength encoding:NSUTF8StringEncoding];
            NSArray *commands = [command componentsSeparatedByString: @" "];
            
            NSLog(@"Testing:: getData::command = %@", command);
            
            if ([[commands objectAtIndex: 1] isEqual: @"mtk_bnapk"]) {
                if ([[commands objectAtIndex: 0] isEqual: @"bnsrv_time"]) {
                    [self sendSyncTime: YES];
                } else {
                    //[[ControllerManager getControllerManagerInstance] onReceive: mCommandtype data: [NSData dataWithBytes: dataBuffer length:tempDataBufferLength/* strlen(dataBuffer)*/]];
                    [[SPC_ControllerManager CMSharedInstance] handleReceivedData:@"fota_fbin" handledData:[NSData dataWithBytes:dataBuffer length:tempDataBufferLength]];
//                    [[SPC_ControllerManager CMSharedInstance] handleReceived:mCommandtype receivedData:[NSData dataWithBytes:dataBuffer length:tempDataBufferLength]];
                }
            } else if ([[commands objectAtIndex:1] isEqual: DEVICEINFO_RECEIVER]) {
                NSData *data = [NSData dataWithBytes:dataBuffer length:tempDataBufferLength];
                if ([[commands objectAtIndex: 2] isEqual: @"1"]) {
                    //[[DeviceInfoManager getDeviceInfoManagerInstance] onReceiverName: [NSData dataWithBytes: dataBuffer length:tempDataBufferLength/* strlen(dataBuffer)*/]];
                    LOG_D(RDP_LOG_TAG, @"Received device name : %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], nil);
                } else {
                    //[[DeviceInfoManager getDeviceInfoManagerInstance] onReceiverDeviceInfo:[NSData dataWithBytes: dataBuffer length:tempDataBufferLength/* strlen(dataBuffer)*/]];
                    LOG_D(RDP_LOG_TAG, @"Received device infor : %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding], nil);
                }
            } else {
                //[[ControllerManager getControllerManagerInstance] onReceive: mCommandtype data: [NSData dataWithBytes:dataBuffer length:tempDataBufferLength/* strlen(dataBuffer)*/]];
                
                [[SPC_ControllerManager CMSharedInstance] handleReceivedData:@"fota_fbin" handledData:[NSData dataWithBytes:dataBuffer length:tempDataBufferLength]];
//                [[ControllerManager CMSharedInstance] handleReceived:mCommandtype receivedData:[NSData dataWithBytes:dataBuffer length:tempDataBufferLength]];
            }
        } else if (mCommandtype == CMD_3) {
            NSLog(@"[BLE][ReadDataParser] getData:: mCommandtype ======= CMD_3");
            NSString* command = [[NSString alloc] initWithBytes:dataBuffer length:tempDataBufferLength encoding:NSUTF8StringEncoding];
            
            NSLog(@"[BLE][ReadDataParser] :: command : %@, length of dataBuffer : %d", command, tempDataBufferLength/*strlen(dataBuffer)*/);
            [self handleWearableInfo: command data: [NSData dataWithBytes: dataBuffer length:tempDataBufferLength/*strlen(dataBuffer)*/]];
        } else if (mCommandtype == CMD_4) {
            NSLog(@"[BLE][ReadDataParser] getData:: mCommandtype ======= CMD_4");
            NSString* versionString = [[NSString alloc] initWithBytes:dataBuffer length:tempDataBufferLength encoding:NSUTF8StringEncoding];
            int version = 0;
            version = [versionString intValue];
            //[mManager setRemoteVersion: version];
            [[SPC_GattLinker GLSharedInstance] setRemoteVersion:version];
            
        } else {
            NSLog(@"[BLE][ReadDataParser] getData:: mCommandtype ======= CMD_OTHER");
            //[[ControllerManager getControllerManagerInstance] onReceive: mCommandtype data: [NSData dataWithBytes: dataBuffer length:tempDataBufferLength/* strlen(dataBuffer)*/]];
            [[SPC_ControllerManager CMSharedInstance] handleReceivedData:@"fota_fbin" handledData:[NSData dataWithBytes:dataBuffer length:tempDataBufferLength]];
//            [[ControllerManager CMSharedInstance] handleReceived:mCommandtype receivedData:[NSData dataWithBytes: dataBuffer length:tempDataBufferLength]];
        }
        
        NSLog(@"[BLE][ReadDataParser]getData::receiveBufferLength %d" ,receiveBufferLength);
        
        if (receiveBufferLength == 0) {
            return;
        } else {
            [self runningReadFSM];
        }
        return;
    }
    
}

- (void) handShakedone {
    NSLog(@"[BLE][ReadDataParser]handShakedone ++");
    if (isOlderThanVersionTow) {
        //[mManager sethandShakedone: YES];
        [[SPC_GattLinker GLSharedInstance] setHandshakeDone:YES];
    } else {
        [self sendSyncTime: NO];
    }
}

//need to improve
- (void) sendSyncTime: (BOOL)userNewFormat {
    NSLog(@"[BLE][ReadDataParser]sendSyncTime ++ :: userNewFormat = %d", userNewFormat);
    int timestamp = [[NSDate date] timeIntervalSince1970];
    int timezone = 8;//*******
    
    int time = timestamp / 1000;
    
    NSString *timestamp1 = [NSString stringWithFormat:@"%d", time];
    NSString *timezone1 = [NSString stringWithFormat: @"%d", timezone];
    if (userNewFormat) {
        int datalen = (int)[timestamp1 length] + 1 + (int)[timezone1 length];
        NSString *syncTime_header = [NSString stringWithFormat:@"bnsrv_time mtk_bnapk 0 0 %@", [NSString stringWithFormat:@"%d", datalen]];
        NSString *syncTime_data = [NSString stringWithFormat:@"%@ %@", timestamp1, timezone1];
        
        int resultLen = 0;
        int *pResultLen = &resultLen;
        unsigned char *result = SPC_getDatacmd(CMD_9, (unsigned char*)[syncTime_header UTF8String], pResultLen);//need to improve
        unsigned char *data = (unsigned char*)[syncTime_data UTF8String];

        /*
        Session *session = [[Session alloc] initSession: @"SyncTime" Response: NO Progress: NO];
        [session addRequest: [NSData dataWithBytes: result length: resultLen]];
        [session addRequest: [NSData dataWithBytes: data length: strlen(data)]];
        [[SessionManager sessionMgrInstance] addSession: session];
         */
        SPC_Session *ses = [[SPC_Session alloc] initSession:@"SyncTime" needProgress:NO sendPriority:SPC_PRIORITY_NORMAL];
//        [[SPC_Session alloc] initSession:@"SyncTime" needResponse:NO needProgress:NO sendPriority:PRIORITY_NORMAL];
        [ses setSendData:[NSData dataWithBytes:result length:resultLen] dataToSend:[NSData dataWithBytes:data length:strlen((char *)data)]];
        [[SPC_SessionManager sharedInstance] addSession:ses];

    } else {
        NSString *syncTime = [NSString stringWithFormat:@"%@ %@ %@ %@", timestamp1, timezone1, @"1.1", @"IOS"];
        unsigned char *time = (unsigned char*)[syncTime UTF8String];
        
        NSLog(@"[BLE][ReadDataParser] sendSyncTime:: syncTime = %@", syncTime);
        
        int tempLen = 0;
        int *pTempLen = &tempLen;
        unsigned char *result = SPC_getDatacmd(CMD_2, time, pTempLen);//need to improve
        
        NSData* data = [NSData dataWithBytes: result length: tempLen];

        [[SPC_GattLinker GLSharedInstance] write:data];

    }
}

- (void) handleWearableInfo: (NSString *)command data: (NSData *)data {
    LOG_I(RDP_LOG_TAG, @"Enter ++ ", nil);
#if 0
    NSArray *commands = [command componentsSeparatedByString: @" "];
    if (commands == nil || [commands count] < 3) {
        NSLog(@"[BLE][ReadDataParser]handleWearableInfo::return ...");
        return;
    }
    
    //NSString *EDR_Address = [[[commands objectAtIndex: 0] uppercaseString] stringByReplacingOccurrencesOfString: @"-" withString: @":"];
    //NSString *LE_Address = [[[commands objectAtIndex: 1] uppercaseString] stringByReplacingOccurrencesOfString: @"-" withString: @":"];
    
    int index = sNameIndex;
    
    Byte *dataBuffer1 = (Byte*)malloc(data.length);//[data bytes];
    
    [data getBytes:dataBuffer1 range:NSMakeRange(0, [data length])];

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
//    NSString *name = [NSString stringWithUTF8String: nameBuffer];
    free(nameBuffer);
    free(dataBuffer1);
    
    if (name && [name length] > 18) {
        name = [name substringToIndex: 18];
    }
    
    NSLog(@"[BLE][ReadDataParser]handleWearableInfo::name = %@", name);
    
    [mManager handleWearableInfo: EDR_Address LE_address: LE_Address DeviceName: name];
#endif
}

@end

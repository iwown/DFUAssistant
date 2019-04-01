//
//  DataPaser.h
//  MTKBleManager
//
//  Created by user on 10/26/14.
//  Copyright (c) 2014 ___MTK___. All rights reserved.
//

#import <Foundation/Foundation.h>

const static int16_t TYPE_PDMS = 0x000A;
const static int16_t TYPE_SLEEP  = 0x000B;

const static int32_t SLEEP_MODE_INBED = 1;
const static int32_t SLEEP_MODE_ASLEEP = 2;

@interface DataParser : NSObject

//length: 20 Byte
struct WatchDataMsg {
    int16_t dataType;
    int16_t totalMsgCount;
    int16_t currentSerial;
    unsigned int startTimeSteps;//startTime for sleep & stepcount value for pedometer
    int32_t endTime;
    unsigned int valueCalories;//not used for sleep
    unsigned short valueDistance;//not used for sleep
};

struct DateTime {
    uint16_t year;
    uint8_t month;
    uint8_t day;
    uint8_t hours;
    uint8_t minutes;
    uint8_t seconds;
};

struct BloodPressureData {
    Byte flag;//8 bit
    float systolic; //16 bit, sfloat
    float diastolic;//16 bit, sfloat
    float map;//16 bit, sfloat
    struct DateTime datatime;
    float pulseRate;//16bit sfloat
    uint8_t userID;
    uint16_t measureMentStatus;
};

struct TemperatureData {
    Byte flag;//8 bit
    float tempValue;//32bit, float
    struct DateTime datatime;
    uint8_t type;
};


struct RequestPkg {
    int16_t type;//identify pedometer(0x000a), sleep(0x000b) or other types
    int16_t func;//identyfi start sync(0x0001), stop sync(0x0002), delete(0x0003) and other
    int16_t interval;
};

+ (NSData *)buildStartSyncPdmsReqest: (int16_t)interval;
+ (NSData *)buildStopSyncPdmsReqest;
+ (NSData *)buildDeletePdmsRequest;

+ (NSData *)BuildStartSyncSleepRequest;
+ (NSData *)BuildDeleteSleepRequest;
+ (struct WatchDataMsg)parseData: (NSData *)data;

+ (int)distanceWalked: (int)height stepCount: (int)steps;

+ (struct BloodPressureData)parseBloodPressure: (NSData *)data;

@end

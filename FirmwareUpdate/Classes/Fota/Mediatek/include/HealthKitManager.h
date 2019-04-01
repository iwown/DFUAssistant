//
//  HealthKitManager.h
//  MTKBleManager
//
//  Created by user on 10/26/14.
//  Copyright (c) 2014 ___MTK___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataParser.h"

@import HealthKit;

const static int INDICATION_INTERVAL_BACKGROUND = 60;//60s
const static int INDICATION_INTERVAL_FORGROUND = 1;

@class DataParser;
enum HealthDataType {
    stepCount = 0,
    activityClories = 1,
    walkingDistance = 2,
    sleepType = 3
};

//@protocol HealthKitDataChangeProtocol <NSObject>
//
//- (void)healthDataChanged: (enum HealthDataType)dataTypeChanged;
//- (void)forTest: (NSData *)data;
//
//@end

@interface HealthKitManager : NSObject

//UI controls
//@property (nonatomic, assign) id<HealthKitDataChangeProtocol>healthkitDataChangeDelegate;

+ (id)healthkitMgrInstance;

- (void) requestAuthorization;
- (void) saveDataToHealthkit: (struct WatchDataMsg)watchData;

- (void) getTodaysStepCount: (void (^)(double))callBack;
- (void) getTodaysActivityColories: (void (^)(double))callBack;
- (void) getTodaysWalkingDistance: (void (^)(double))callBack;
- (void) getUsersHeight: (void (^)(double))callBack;
- (void) getLatestSleepData: (int)mode ResultBack: (void (^)(NSInteger, NSDate *, NSDate *, NSError *))completion;
- (void) deInit;

- (void)saveBloodPressureToHealthStore: (double)systolic diastolic: (double)diaValue time: (NSDate *)recordTime;
- (void)saveBodyTemperatureToHealthStore: (double)bodyTemperature time: (NSDate *)timeRecord;
//- (void) getLatestASleepData: (void (^)(NSInteger, NSDate *, NSDate *, NSError *))completion;
//- (void) getLatestInBedData: (void (^)(NSInteger, NSDate *, NSDate *, NSError *))completion;

//test
//- (void) tempTest: (NSData *)dataNs;

@end

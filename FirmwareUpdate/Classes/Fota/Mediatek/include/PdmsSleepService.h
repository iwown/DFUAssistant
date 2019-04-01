//
//  HealthKitSerivce.h
//  MTKBleManager
//
//  Created by user on 10/23/14.
//  Copyright (c) 2014 ___MTK___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEClientProfile.h"
#import "HealthKitManager.h"

@class  MTKBleManager;

extern NSString *kPedometerServiceUUIDString;
extern NSString *kPedometerCharacteristicUUIDString;

@protocol PdmsSleepUpdateDelegate <NSObject>

- (void)onPdmsDataChange: (int32_t)totalStepCount calories: (int32_t)totalCalories distance: (int16_t)totalDistance;
- (void)onSleepDataChange: (NSDate *)startTime endTime: (NSDate *)endtime sleepMode: (int)mode;
- (void)didDisconnect;

@end

@interface PdmsSleepService : BLEClientProfile

+ (id) getInstance;

- (void) sendStartReadRequest: (int16_t)interval;
- (void) sendStopReadRequest;
- (void) sendDeletePdmsRquest;

- (void)registerPSDelegate: (id<PdmsSleepUpdateDelegate>)psDelegate;
- (void)unRegisterPSDelegate: (id<PdmsSleepUpdateDelegate>)psDelegate;

@end

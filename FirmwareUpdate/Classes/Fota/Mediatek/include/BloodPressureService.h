//
//  BloodPressureService.h
//  MtkBleManager
//
//  Created by user on 15-1-6.
//  Copyright (c) 2015年 ___MTK___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLEClientProfile.h"

extern NSString *kBloodPressueServiceUUIDString;
extern NSString *kBloodPressureMeasurementChUUIDString;
extern NSString *kBloodPressureFeatureUUIDString;

@protocol BloodPressureUpdateDelegate <NSObject>

/*!
 Invoked after blooddpressure updated from remote BLE device
 
 @param systolic systolic value
 @param dia      diastolic value
 @param data     update time. Always nil, reserved for furture use
 */
- (void)onBPDataUpdate: (float)systolic diastolic: (float)dia time: (NSDate *)date;

@end

@interface BloodPressureService : BLEClientProfile

+ (id) getInstance;

- (void) registerBPDelegate: (id<BloodPressureUpdateDelegate>)bpDelegate;
- (void) unRegisterBPDelegate: (id<BloodPressureUpdateDelegate>)bpDelegate;
@end

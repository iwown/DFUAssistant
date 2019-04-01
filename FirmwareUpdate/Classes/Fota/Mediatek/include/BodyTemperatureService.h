//
//  BodyTemperature.h
//  MtkBleManager
//
//  Created by user on 15-1-7.
//  Copyright (c) 2015年 ___MTK___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLEClientProfile.h"

extern NSString *kBodyTemperatureServiceUUIDString;
extern NSString *kBodyTemperatureMesaurementChUUID;

@protocol BodyTemperatureUpdateDelegate <NSObject>

- (void)onBodyTempUpdate: (float)temperature time: (NSDate *)date;

@end

@interface BodyTemperatureService : BLEClientProfile

+ (id) getInstance;

- (void) registerBodyTemperatureDelegate: (id<BodyTemperatureUpdateDelegate>)btDelegate;
- (void) unRegisterBodyTemperatureDelegate: (id<BodyTemperatureUpdateDelegate>)btDelegate;

@end

//
//  IwownBlePeripheral.h
//  BLELib3
//
//  Created by 曹凯 on 16/1/4.
//  Copyright © 2016年 Iwown. All rights reserved.
//
@class CBPeripheral;
#import <Foundation/Foundation.h>

@interface IwownBlePeripheral : NSObject

@property (nonatomic ,strong) CBPeripheral *cbDevice;
@property (nonatomic ,strong) NSString *mediaAC;
@property (nonatomic ,strong) NSNumber *RSSI;
@property (nonatomic ,strong) NSString *uuidString;
@property (nonatomic ,strong) NSString *deviceName;

- (instancetype)initWith:(CBPeripheral *)cbPeripheral andAdvertisementData:(NSDictionary *)advertisementData;

@end

//
//  RequestFirmwareUpdateApi.m
//  Kawayi
//
//  Created by CY on 2018/1/20.
//  Copyright © 2018年 A$CE. All rights reserved.
//

#import "RequestFirmwareUpdateApi.h"

@implementation RequestFirmwareUpdateApi {
    NSNumber *_devicePlatform;//Same with DFUPlatform
    NSNumber *_dType; //Same with DeviceCategory
    NSNumber *_modelNum;
    NSString *_deviceVersion;
    NSInteger _app;
    NSNumber *_appVersion;
}

- (id)initWithDevicePlatform:(NSNumber *)devicePlatform andDeviceType:(NSNumber *)deviceType andDeviceModel:(NSNumber *)model andFirmwareVersion:(NSString *)fwVersion andApp:(NSInteger)app andAppVersion:(NSNumber *)appVersion {
    self = [super init];
    if (self) {
        _devicePlatform = devicePlatform;
        _dType = deviceType;
        _modelNum = model;
        _deviceVersion = fwVersion;
        _app = app;
        _appVersion = appVersion;
    }
    return self;
}

- (NSString *)urlPath {
    return @"/venus/deviceservice/device/fwupdate";
}

- (NSString *)httpMethod {
    return POST;
}

- (id)postBodyParameters {
    NSNumber *module = @1; //1.Application
    NSNumber *skip = @0; //DEPRECATED_ATTRIBUTE
    NSNumber *appPlatform = @2; //1. android 2. iOS  8. all
    NSString *deviceVersion = _deviceVersion ? _deviceVersion : @"";
    
    return @{
             @"platform":_devicePlatform,
             @"device_type":_dType,
             @"device_model":_modelNum,
             @"fw_version":deviceVersion,
             @"app":@(_app),
             @"app_version":_appVersion,
             @"app_platform":appPlatform,
             @"module":module,
             @"skip":skip
             };
}

- (NSDictionary *)firmware {
    return self.responseJSONObject[@"firmware"];
}

@end

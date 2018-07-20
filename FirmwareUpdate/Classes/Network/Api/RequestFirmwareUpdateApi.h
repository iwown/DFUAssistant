//
//  RequestFirmwareUpdateApi.h
//  Kawayi
//
//  Created by CY on 2018/1/20.
//  Copyright © 2018年 A$CE. All rights reserved.
//

#import <YCNetworkLibrary/YCNetworkLibrary.h>

@class RequestFirmwareUpdateApi;

typedef void(^RequestFirmwareUpdateCompletion)(RequestFirmwareUpdateApi *responce, NSError *error);

@interface RequestFirmwareUpdateApi : IWBasicRequest

@property (nonatomic ,strong) NSDictionary *firmware;

- (id)initWithDevicePlatform:(NSNumber *)devicePlatform andDeviceType:(NSNumber *)deviceType andDeviceModel:(NSNumber *)model andFirmwareVersion:(NSString *)fwVersion andApp:(NSInteger)app andAppVersion:(NSNumber *)appVersion;
@end


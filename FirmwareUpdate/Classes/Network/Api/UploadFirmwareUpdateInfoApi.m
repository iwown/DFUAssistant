//
//  UploadFirmwareUpdateInfoApi.m
//  Kawayi
//
//  Created by CY on 2018/1/20.
//  Copyright © 2018年 A$CE. All rights reserved.
//

#import "UploadFirmwareUpdateInfoApi.h"

@implementation UploadFirmwareUpdateInfoApi
{
    NSDictionary *_params;
}

- (instancetype)initWithParams:(NSDictionary *)params {
    if (self = [super init]) {
        _params = params;
    }
    return self;
}

- (NSString *)urlPath {
    return @"/venus/deviceservice/device/uploadUpgrade";
}

- (NSString *)httpMethod {
    return POST;
}

- (id)postBodyParameters {
    return _params;
}
@end

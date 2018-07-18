//
//  DownloadFirmwareUpdateInfoApi.m
//  Kawayi
//
//  Created by CY on 2018/1/20.
//  Copyright © 2018年 A$CE. All rights reserved.
//

#import "DownloadFirmwareUpdateInfoApi.h"

@implementation DownloadFirmwareUpdateInfoApi
{
    NSString *_uid;
}

- (instancetype)initWithUid:(NSString *)uid {
    if (self = [super init]) {
        _uid = uid;
    }
    return self;
}

- (NSString *)urlPath {
    return @"/venus/deviceservice/device/downloadUpgrade";
}

- (NSString *)httpMethod {
    return GET;
}

- (id)urlParameters {
    return @{@"uid":_uid};
}

- (NSString *)url {
    return self.responseObject[@"url"];
}

- (NSString *)model {
    return self.responseObject[@"model"];
}
@end

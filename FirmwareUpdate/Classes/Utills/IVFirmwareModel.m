//
//  IVFirmwareModel.m
//  FirmwareUpdate
//
//  Created by 曹凯 on 2016/11/16.
//  Copyright © 2016年 west. All rights reserved.
//

#import "IVFirmwareModel.h"

@implementation IVFirmwareModel

+ (instancetype)getInstanceBy:(NSDictionary *)dict {
    IVFirmwareModel *ivfModel = [[IVFirmwareModel alloc] init];

    ivfModel.deviceModel = [dict[@"device_model"] integerValue];
    ivfModel.deviceType = [dict[@"device_type"] integerValue];
    ivfModel.fwVersion = dict[@"fw_version"];
    ivfModel.module = [dict[@"module"] integerValue];
    ivfModel.devicePlatform = dict[@"device_platform"];
    ivfModel.app = [dict[@"app"] integerValue];
    ivfModel.appVersion = [dict[@"app_version"] integerValue];
    ivfModel.appOS = [dict[@"app_platform"] integerValue];
    ivfModel.downloadLink = dict[@"download_link"];
    ivfModel.publishDate = dict[@"publish_date"];
    ivfModel.updateInfo = dict[@"update_information"];
    return ivfModel;
}

- (void)setDeviceModel:(NSInteger)deviceModel {
    _deviceModel = deviceModel;
    _model = [self modelBy:deviceModel];
}

- (NSString *)modelBy:(NSInteger)dmNum {
    NSString *modelKey = @"NULL";
    NSDictionary *dict = [IVFirmwareModel modelMap];
    for (NSString *model in dict.allKeys) {
        if ([dict[model] intValue] == dmNum) {
            modelKey = model;
            break;
        }
    }
    return modelKey;
}

+ (NSDictionary *)modelMap {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"modelNumber" ofType:@"plist"];
    NSDictionary *fileContent = [NSDictionary dictionaryWithContentsOfFile:path];
    return fileContent;
}

@end

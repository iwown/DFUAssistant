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
    switch (dmNum) {
        case 2:
        {
            return @"i5+3";
        }
            break;
        case 3:
        {
            return @"i5+5";
        }
            break;
        case 4:
        {
            return @"I7S";
        }
            break;
        case 14:
        {
            return @"I7S2";
        }
            break;
        case 5:
        {
            return @"V6";
        }
            break;
        case 6:
        {
            return @"I5PR";
        }
            break;
        case 7:
        {
            return @"I6";
        }
            break;
        case 17:
        {
            return @"I6PB";
        }
            break;
        case 8:
        {
            return @"I6HR";
        }
            break;
        case 9:
        {
            return @"I6NH";
        }
            break;
        case 10:
        {
            return @"R1";
        }
            break;
        case 11:
        {
            return @"I3MI";
        }
            break;
            
        default:
            return @"NULL";
            break;
    }
}
@end

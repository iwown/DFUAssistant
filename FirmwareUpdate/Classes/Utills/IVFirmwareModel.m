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
        case 15:
            return @"I5PK";
            break;
        case 16:
            return @"I6J0";
            break;
        case 18:
            return @"I6JA";
            break;
        case 20:
        {
            return @"I6H9";
        }
            break;
        case 22:
        {
            return @"I6ME";
        }
            break;
        case 24:
        {
            return @"i6HC";
        }
            break;
        case 25:
        {
            return @"I5H3";
        }
            break;
        case 26:
        {
            return @"I5A0";
        }
            break;
        case 32:
        {
            return @"P1J";
        }
            break;
        case 34:
        {
            return @"R1Y0";
        }
            break;
        case 35:
        {
            return @"R1N0";
        }
            break;
        case 36:
        {
            return @"i6C2";
        }
            break;
        case 37:
        {
            return @"P2J";
        }
            break;
        case 39:
            return @"i6H1";
            break;
        case 47:
            return @"I7F1";
            break;
        case 60:
            return @"P5J";
            break;
        case 64:
            return @"I7G1";
            break;
        case 66:
            return @"P1MINI";
            break;
        case 70:
            return @"I7B";
            break;
        case 79:
            return @"I7E";
            break;
            
        default:
            return @"NULL";
            break;
    }
}
@end

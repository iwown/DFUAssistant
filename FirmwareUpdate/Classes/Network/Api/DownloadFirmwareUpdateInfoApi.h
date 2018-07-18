//
//  DownloadFirmwareUpdateInfoApi.h
//  Kawayi
//
//  Created by CY on 2018/1/20.
//  Copyright © 2018年 A$CE. All rights reserved.
//

#import <YCNetworkLibrary/YCNetworkLibrary.h>

@interface DownloadFirmwareUpdateInfoApi : IWBasicRequest

@property (nonatomic ,copy) NSString *url;
@property (nonatomic ,copy) NSString *model;

- (instancetype)initWithUid:(NSString *)uid;
@end

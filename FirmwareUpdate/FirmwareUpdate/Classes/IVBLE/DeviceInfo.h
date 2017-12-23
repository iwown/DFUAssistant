//
//  DeviceInfo.h
//  ZLingyi
//
//  Created by Jackie on 15/1/29.
//  Copyright (c) 2015年 Jackie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceInfo : NSObject

@property (nonatomic,strong)    NSString *model;        // model string
@property (nonatomic,strong)    NSString *version;      // version string
@property (nonatomic,readonly)  NSUInteger versionValue;// integer value of version
@property (nonatomic,readonly)  NSUInteger oadMode;     // over air update mode
@property (nonatomic,readonly)  NSUInteger batLevel;    // battery level
@property (nonatomic,strong)    NSString *seriesNo;      // series No. ble Addr for display
@property (nonatomic,strong)    NSString *bleAddr;      // series No. ble Addr for upload
@property (nonatomic,readonly)  NSUInteger customNo;      // 客户的编号，0 代表我们自己

@property (nonatomic,strong)  NSString *hrVersion;    //心率版本号
@property (nonatomic,assign)  NSInteger hrVersionValue; //心率升级的版本号

@property (nonatomic,strong)    NSString *fontSupport;  //0 null ,1 e&&c ,2 128国


+(instancetype)defaultDeviceInfo;

- (void)updateDeviceInfo:(NSString *)deviceInfo;
- (void)updateBattery:(NSString *)batteryLevel;

- (void)updateHeartRateParam:(NSString *)body;

@end

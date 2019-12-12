//
//  IVFirmwareModel.h
//  FirmwareUpdate
//
//  Created by 曹凯 on 2016/11/16.
//  Copyright © 2016年 west. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IVFirmwareModel : NSObject

@property (nonatomic ,strong) NSString *model;
@property (nonatomic ,assign) NSInteger deviceModel;
@property (nonatomic ,assign) NSInteger deviceType;
@property (nonatomic ,strong) NSString *fwVersion;
@property (nonatomic ,assign) NSInteger module;
@property (nonatomic ,strong) NSString *devicePlatform;
@property (nonatomic ,assign) NSInteger app;
@property (nonatomic ,assign) NSInteger appVersion;
@property (nonatomic ,assign) NSInteger appOS;
@property (nonatomic ,strong) NSString *downloadLink;
@property (nonatomic ,strong) NSString *publishDate;
@property (nonatomic ,strong) NSString *updateInfo;

+ (instancetype)getInstanceBy:(NSDictionary *)dict;

+ (NSDictionary *)modelMap;

@end

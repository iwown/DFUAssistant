//
//  FUHandle.h
//  FirmwareUpdate
//
//  Created by A$CE on 2017/9/18.
//  Copyright © 2017年 west. All rights reserved.
//
#import <BLE3Framework/BLE3Framework.h>
#import <Foundation/Foundation.h>

@protocol FUHandleDelegate <NSObject>

@required

- (NSString *)fuHandleParamsUid;
- (NSNumber *)fuHandleParamsAppName;
- (NSString *)fuHandleParamsBuildVersion;

@optional
- (NSInteger)fuHandleReturnModelDfu;
- (NSString *)fuHandleReturnFileSuffixName;
- (NSString *)fuHandleReturnAliasByModel:(NSString *)model;
- (NSString *)fuHandleReplaceBroadcastName:(NSString *)bName;

- (void)fuHandleActionBegin;
- (void)fuHandleActionEnd;

//default is @Code{FU_NORAML_BUTTON_COLOR:0x47caa9}
- (int)fuNormalButtonColor;
@end

@interface FUHandle : NSObject

/**
 获取和更新设备信息是需要设置参数
 */
@property (nonatomic ,strong) ZeronerDeviceInfo *deviceInfo;

@property (nonatomic ,weak) id<FUHandleDelegate> delegate;


+ (FUHandle *)shareInstance;
/*firmware upgrade view controller*/
- (UIViewController *)getFUVC;
#pragma mark- Public
- (NSNumber *)devicePlatformNumber;
- (NSNumber *)deviceModelNumber;
- (NSNumber *)deviceTypeNumber;
- (NSString *)getFWPathFromModel:(NSString *)model;
- (NSString *)getDeivceAlias;
- (NSString *)braceletName:(NSString *)nName;


#pragma mark- UI
/*fuNormalButtonColorInt*/
- (int)fuNBCI;

#pragma mark- EPO
- (void)setState:(kBLEstate)state;
- (void)setEpoParamsIfNeed;
- (void)epoUpdateStart;

- (void)responseOfMTKBtNotifyData:(CBCharacteristic *)cbc;
- (void)responseOfMTKBtWriteData:(CBCharacteristic *)cbc;
@end

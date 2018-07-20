//
//  FUHandle.h
//  FirmwareUpdate
//
//  Created by A$CE on 2017/9/18.
//  Copyright © 2017年 west. All rights reserved.
//
#import "BLEShareInstance.h"
#import <Foundation/Foundation.h>
#import "RequestFirmwareUpdateApi.h"

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

@property (nonatomic ,strong) ZRDeviceInfo *deviceInfo;

@property (nonatomic ,weak) id<FUHandleDelegate> delegate;


+ (FUHandle *)handle;
/*firmware upgrade view controller*/
- (UIViewController *)getFUVC:(NSDictionary *)mContent;
#pragma mark- Public
- (NSNumber *)devicePlatformNumber;
- (NSNumber *)deviceModelNumber;
- (NSNumber *)deviceTypeNumber;
- (NSString *)getDeivceAlias;
- (NSString *)braceletName:(NSString *)nName;
- (NSString *)getFWName;
- (NSString *)getFWPath;
- (BOOL)dfuFileIsExist:(NSString *)url;
- (BOOL)downFWFromURL:(NSString *)fileURL;

- (void)fwUpdateRequestWithPlatform:(NSInteger)platform
                          andNeedFW:(NSUInteger)needFW
                   andDeviceVersion:(NSString *)deviceVersion
                         completion:(RequestFirmwareUpdateCompletion)completion;
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

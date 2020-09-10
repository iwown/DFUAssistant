//
//  BLEShareInstance.h
//  ZLYIwown
//
//  Created by 曹凯 on 15/11/16.
//  Copyright © 2015年 Iwown. All rights reserved.
//

typedef enum{
    kBLEstateDisConnected = 0,
    kBLEstateDidConnected ,
    kBLEstateBindUnConnected ,
}kBLEstate;

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <BLEMidAutumn/BLEMidAutumn.h>

UIKIT_EXTERN NSString *const kNOTICE_DEVICE_SYNC_END;
UIKIT_EXTERN NSString *const kNOTICE_SYNC_TODAY_SUMMARY_END;
UIKIT_EXTERN NSString *const kNOTICE_SYNC_TWODAYSDATAEND;
UIKIT_EXTERN NSString *const kNOTICE_SYNC_HEART_RATE_END;

@class CLLocation;
@protocol BLEShareInstanceDelegate <NSObject>

@optional
- (void)currentBLEProtovolIsNum2;

- (void)epoDataProgress:(float)progress;

@end


@interface BLEShareInstance : NSObject <BleConnectDelegate,BleDiscoverDelegate,BLEquinox>

@property (nonatomic ,strong) id<BLESolstice> solstice;
@property (nonatomic ,weak) id<BLEShareInstanceDelegate>delegate;
@property (nonatomic ,assign) kBLEstate state;
@property (nonatomic ,assign) CBManagerState centralBluetoothState;
@property (nonatomic ,strong) ZRDeviceInfo *deviceInfo;

@property (nonatomic, assign) NSInteger bleDeviceCategory;

@property (nonatomic, copy) void(^dfuBlock)(void);

+ (BLEShareInstance *)shareInstance;

+ (id<BLESolstice>)bleSolstice ;

- (BLEProtocol)bleProtocol;

- (void)scanDevice;
- (void)scanDeviceAndAutoDfu:(NSString *)keyWord andBlock:(void(^)(void))block;

- (void)stopScan ;

- (CBPeripheral *)getConnectedPeriphral;

- (NSArray *)getDevices;

- (BOOL)isBinded;

- (void)connectDevice:(ZRBlePeripheral *)device;

- (void)unConnectDevice;

- (void)deviceFWUpdate;
- (void)debindFromSystem;
- (void)getDeviceInfo;
- (void)getBatteryInfo;

#pragma mark - 6*
- (void)initBtNotifyIfNeed;
- (void)requestForStartEpoUpdate;
- (void)updateEpoLocation:(CLLocation *)location;

@end

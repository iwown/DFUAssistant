//
//  BLELib3.h
//  BLELib3
//
//  Created by 曹凯 on 15/10/26.
//  Copyright © 2015年 Iwown. All rights reserved.
//
#define BLE_MAIN_RESTORE_IDENTIFIER @"main_ble_restore_identifier"


#define SCAN_TIME_INTERVAL 5
#import "IwownModel.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum{
    kBLEstateDisConnected = 0,
    kBLEstateDidConnected ,
    kBLEstateBindUnConnected ,
}kBLEstate;
@class IwownBlePeripheral;
@class DeviceInfo;


@protocol BleDiscoverDelegate <NSObject>

@required

- (void)IWBLEDidDiscoverDeviceWithMAC:(IwownBlePeripheral *)iwDevice;

@optional
/**
 *
 *  @return the service did protocoled, for bracelet ,you could write @"FF20" ,you also can never implement this method for connect bracelet.
 */
- (NSString *)serverUUID;

@end

@protocol BleConnectDelegate <NSObject>

@required
/**
 *  invoked when the device did connected by the centeral
 *
 *  @param device: the device did connected
 */
- (void)IWBLEDidConnectDevice:(IwownBlePeripheral *)device;

@optional

/**
 *  invoked when the device did disConnect with the connectted centeral
 *
 *  @param device: the device whom the centeral was connected
 */
- (void)IWBLEDidDisConnectWithDevice:(IwownBlePeripheral *)device andError:(NSError *)error;

/**
 *  invoked when the device did fail to connected by the centeral
 *
 *  @param device: the device whom the centeral want to be connected
 */
- (void)IWBLEDidFailToConnectDevice:(IwownBlePeripheral *)device andError:(NSError *)error;

/**
 *  表示手环注册ANCS失败，此时消息推送不能work，需要重新配对。
 *  this method would be called when the Peripheral disConnected with the system; In this case ,your app should tell the user who could ingore the device on system bluetooth ,and reconnect and pair the device. or there will be risk of receiving a message reminder.
 *
 *  @param deviceName the Device Name
 */
- (void)deviceDidDisConnectedWithSystem:(NSString *)deviceName;

/**
 *  This method would be invoked when the app connected a device who is supportted by protocol2_0
 *  当前手环是2.0协议的手环是调用这个方法。
 */
- (void)didConnectProtocolNum2_0;

@end


@protocol BLELib3Delegate <NSObject>

#pragma mark -/****************************===device setting===*****************************************/

@required
/*
 * set bracelet parameter after connect with app.
 */
- (void)setBLEParameterAfterConnect;

#pragma mark -/****************************===device function===*****************************************/
@optional
/*!
 ** 
 * Description: call function *setKeyNotify:* with param 1 entry bacelet photograph mode. bracelet will view a
                photo icon on screen when successed.
 * Important:   function setKeyNotify send value 1 entry photograph mode, send value 0 out .Don't try another 
                photo action when last action finished ,thar might cause some result unexpected.
 * 描述: APP主动调用 setKeyNotify:1，让手环进入到拍照模式，手环上出现拍照按钮，
 *      按键或点击按钮手环SDK会通过 notifyToTakePicture 通知App拍照。
 * 注意: setKeyNotify 进入App智拍模式后设置1. 退出拍照界面设置0
 *      需要做拍照保护，拍照在未保存完成前不要开启第二次拍照。
 */
- (void)notifyToTakePicture;

/*!
 * 描述: 长按手环按钮或者点击触屏选择找手机按钮，手环SDK会通过 notifyToSearchPhone告诉App，手环需要找手机。
 *       接下来App可以播放寻找手机的音乐或者其他操作
 */
- (void)notifyToSearchPhone;

#pragma mark -/****************************===device Info===*****************************************/

- (void)updateDeviceInfo:(DeviceInfo*)deviceInfo;
- (void)updateBattery:(DeviceInfo *)deviceInfo;

/**
 *  the method be called after call - (void)getSupportSportsList;
 *
 *  @param ssList
 */
- (void)notifySupportSportsList:(NSDictionary *)ssList;

/**
 *  responseOfGetTime
 *
 *  @param date (year month day hour minute second)
 */
- (void)responseOfGetTime:(NSDate *)date;

/**
 *  the response of get clock
 *
 *  @param clock
 */
- (void)responseOfGetClock:(IwownClock *)clock;

/**
 *  the response of get sedentary
 *
 *  @param sedentary
 */
- (void)responseOfGetSedentary:(IwownSedentary *)sedentary;

/**
 *  the response of get HWOption
 *
 *  @param hwOption
 */
- (void)responseOfGetHWOption:(IwownHWOption *)hwOption;

- (void)responseOfGetSprotTarget:(IwownSportTarget *)spModel;

- (void)responseOfDNDSetting:(IwownDNDModel *)dndModel;

#pragma mark -/****************************===device data===*****************************************/
/**
 *  this method be called when the sdk have sleep data update;
 *
 *  @param dict
 */
- (void)updateSleepData:(NSDictionary *)dict;

/**
 *  this method be called when the sdk have sport data update;
 *
 *  @param dict
 */
- (void)updateSportData:(NSDictionary *)dict;

/**
 *  this method be called when the sdk have day sport data update;
 *
 *  @param dict
 */
- (void)updateWholeDaySportData:(NSDictionary *)dict;

/**
 *  this method be called when the sdk have HeartRate data update;
 *
 *  @param dict[detail_data], @{type,开始时间，结束时间，消耗能量，5个心率区间的时间分段、能量消耗、平均心率值},]
 */
- (void)updateHeartRateData:(NSDictionary *)dict;

/**
 *  this method be called when the sdk have HeartRate_hours data update;
 *
 *  @param 
     dict[@"hour"] 小时，12表示detail的数据属于 12:00-13:00
     dict[@"detail_data"], 一个小时内@[每分钟平均心率值]
 */
- (void)updateHeartRateData_hours:(NSDictionary *)dict;

/**
 *  all this data have errored date record ,like year:2255 month:256 day:256 hours:256 
 *  data transmossion by this method is not useful almost .It can notice you when you could not get anything with @link updateHeartRateData_hours @/link after send @link getHRDataOfHours @/link.
 */
- (void)transmissionHeartRateData_Hours:(NSDictionary *)dict;
/**
 *   this method be called when the sdk have current sport data update;
 *
 *  @param dict
 */
- (void)updateCurrentSportData:(NSDictionary *)dict;
/**
 *   this method be called when the sdk have current day sport data update;
 *
 *  @param dict
 */
- (void)updateCurrentWholeDaySportData:(NSDictionary *)dict;
/**
 *   this method be called when the sdk have current HeartRate data update;
 *
 *  @param dict
 */
- (void)updateCurrentHeartRateData:(NSDictionary *)dict DEPRECATED_ATTRIBUTE;

/**
 *  设置日程的应答
 *
 *  @param success YES 成功  NO 失败
 */
- (void)responseOfScheduleSetting:(BOOL)success;

/**
 *  读取某个日程的应答
 *
 *  @param exist YES 存在   NO 不存在
 */
- (void)responseOfScheduleGetting:(BOOL)exist;


/**
 *  读取日程Info的应答
 *
 *  @param dict 
    dict[@"cur_num"] 当前可配置日程数量
        remaining number of schedule could be set.
    dict[@"all_num"]:日程最大数量
        max number of schedule we can configure
    dict[@"day_num"]:每天可配置日程数量
        max number of schedule could  be configured for one day.
 */
- (void)responseOfScheduleInfoGetting:(NSDictionary *)dict;

@end

typedef enum{
    CurrentBLEProtocol2_0 = 0,
    CurrentBLEProtocol3_0
}CurrentBLEProtocol;

typedef void(^NFCSuccessData)(id data);

@interface BLELib3 : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic ,copy) NFCSuccessData successData;

@property (nonatomic ,assign) id <BLELib3Delegate>delegate;

@property (nonatomic ,assign) id <BleConnectDelegate>connectDelegate;

@property (nonatomic ,assign) id <BleDiscoverDelegate>discoverDelegate;

@property (nonatomic ,assign) CurrentBLEProtocol protocolVSN;

+ (instancetype)shareInstance;

- (NSString *)libBleSDKVersion;

@property (nonatomic ,assign) kBLEstate state; //support add observer ,abandon @readonly ,don't change it anyway.

@property (nonatomic ,readonly) CBPeripheral *currentDevice;

#pragma mark -action of connecting layer -连接层操作
- (void)scanDevice;
- (void)stopScan;
- (void)connectDevice:(IwownBlePeripheral *)dev;
- (void)unConnectDevice;
- (void)reConnectDevice;
- (NSArray *)retrieveConnectedPeripherals;

/**
 *  reset device
 */
- (void)deviceReset;
/*!
 *  发送进入 固件升级的命令。只有支持固件升级的设备需要使用
 ** This cmd could used for update firmware if the smartband is supported.
 */
- (void)deviceUpdate;
/*!
 *  提醒手环和系统解绑
 ** Remind smartband debind with system
 */
- (void)debindFromSystem;

#pragma mark -action of data layer -数据层操作
/**
 *  call this method get the supported sports list on current bracelet .@see {@link notifySupportSportsList:}
 */
- (void)getSupportSportsList;

/**
 *  call this method get current sports data; you could run a timer to do this. then you get data what you want  @see {@link updateWholeDaySportData:}
 */
- (void)getCurrentSportData;

/**
 *  调用这些方法可以得到连接的设备信息和电量信息，可以在
 *  call these methods to get current connected device's info @see {@link updateDeviceInfo:} And {@link updateBattery:}
 */
- (void)getDeviceInfo;
- (void)readDeviceInfo;
- (void)readDeviceBattery;

/*!
 *  28、29、51通道 ,在心率升级时需关闭此通道
 */
- (void)sportDataSwichOn:(BOOL)on;

/*!
 *  读取心率模块参数
 * read setting params of heartRate;
 */
- (void)getHRParam;

/*
 * 请求心率分时数据
 * read hrdata_hours by this cmd .
 * for the callback would be incoked when the data update. @see
    @link updateHeartRateData_hours :@/link and
    @link transmissionHeartRateData_Hours: @/link
 */
- (void)getHRDataOfHours;

/*
 * clear all data on smartband.
 */
- (void)clearSportsData;

#pragma mark -action of setting layer -设置层操作
/**
 *控制重连时是否需要write device setting, sdk 内部实现了一套自己的控制。
 */
@property (nonatomic ,assign) BOOL isResetFWSettingNeed;

#pragma mark -/****************************===device setting===*****************************************/

/*
 * 设置勿扰模式
 * setting DND(Do Not Disturb) mode. write this cmd with a <code>IwownDNDModel</code> object .
 */
- (void)setDNDMode:(IwownDNDModel *)dndModel;
/*
 * 读取勿扰模式设置
 * read for DND(Do Not Disturb) mode setting. Implement callback method @link responseOfDNDSetting: @\link to get the setting after this cmd.
 */
- (void)readDNDModeSetting;


- (void)syscTimeAtOnce;
- (void)setMessagePush:(IwownMESPush *)mspModel;
- (void)setAlertMotionReminder:(IwownSedentary *)sedentaryModel;
- (void)setPersonalInfo:(IwownPersonal *)personalModel;
- (void)setScheduleClock:(IwownClock *)clockModel; //alarm clock
- (void)setFirmWareOption:(IwownHWOption *)hwOptionModel;
- (void)setMotoControl:(IwownMotor *)motor DEPRECATED_ATTRIBUTE;

- (void)feelMotor:(IwownMotor *)motor; //体验震动;
- (void)setMotors:(NSArray<IwownMotor *> *)motors;  //设置震动
- (void)setWeather:(IwownWeather *)weather;

- (void)readPeriphralTime;
- (void)readMessagePush;
- (void)readSedentaryMotion;
- (void)readPersonalInfo DEPRECATED_ATTRIBUTE;
- (void)readAlarmClock;
- (void)readFirmwareOption;

/******************************************************************************************
 * arr [周一的arr，周二的arr，周三的arr，...]
 * 周一的arr [dict，dict，dict,...]， 周二的arr [dict，dict,...],...
 * dict {@"TARGET":@"100", @"TYPE":@"01",...}
 * 注意type和target是十进制的值
 
 superArr contains 7 subArr like superArr[subArr1[],subArr2[],..subArr7[]]
 subArr(1-7) match monday to sunday,
 subArr contains some NSDictionary object contains specific target.
 the NSDictionary object have keys @"TARGET" and @"TYPE" , @"TARGET" is a NSNumber value of specific target like waking target 8000 steps ,this value should be @8000 , @"TYPE" key is also an NSNumber value , the value matched the enum sd_sportType in IwownBleHeader.h file
 Note : both @"TARGET" and @"TYPE" value is decimalization.
 *******************************************************************************************/
- (void)setSportTarget:(NSMutableArray *)targetArray;
- (void)setSportTargetBy:(IwownSportTarget *)st;
- (void)readV3Target;
/*!
 * 写心率参数
 * hrIntensity 运动强度;
 * time 报警时间 units is minute , default is 10 minutes. if you write an number 0, the default num will be valid.
 */
- (void)setHRParamData:(NSUInteger)hrIntensity andAlarmTime:(NSUInteger)time;

#pragma mark 日程
//写入日程
- (void)writeSchedule:(IwownSchedule *)sModel;

//清空日程
- (void)clearAllSchedule;

//关闭指定日程
- (void)closeSchedule:(IwownSchedule *)sModel;

//读取日程信息
- (void)readScheduleInfo;

//读取指定日程
- (void)readSchedule:(IwownSchedule *)sModel;

#pragma mark -action of feature layer -功能层操作

/*!
 * 推送字串，比如： [iwownBLE pushStr:@"这是个测试例子"];
 */
- (void)pushStr:(NSString *)str; //推送字串

/*!
 *  心率升级必备。//注： 暂不支持心率升级
 */
- (void)writeHeartRateUpdateCharacteristicData:(NSString *)str;

- (void)hrDataSwichStr:(NSString *)str;

/*!
 * setKeyNotify 进入智拍模式设置1. 退出智拍模式设置0   // 通知拍照从 - (void)notifyToTakePicture; 获得
 * call this method to become smart photo or exits. set value 1 to active and set 0 to exit; get photoes @see - (void)notifyToTakePicture;
 */
- (void)setKeyNotify:(NSUInteger)keyNotify;

/*!
 *  Default is NO. set YES 放弃通用读写操作，在心率升级的时候使用。升级完成时候，需改回.
 */
- (void)setWriteDataForbidden:(BOOL)forbidden;


#pragma mark --NFC

/**
 *  交换NFC指令和数据
 *
 *  @param data
 *  @param successData
 *  @param failure
 */
- (void)exchangeWithData:(NSString *)data
            responseData:(NFCSuccessData)successData
                 failure:(void(^)(id error))failure;

#define mark -AppBackMode

- (void)applicationDidEnterBackground ;
- (void)applicationWillEnterForeground ;
- (void)applicationWillTerminate ;
- (void)applicationProtectedDataDidBecomeAvailable;
- (void)applicationProtectedDataWillBecomeUnavailable;
- (void)applicationDidFinishLaunchingWithOptions;
@end


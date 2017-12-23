//
//  IwownModel.h
//  Demo
//
//  Created by 曹凯 on 15/12/25.
//  Copyright © 2015年 Iwown. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "IwownBleHeader.h"
typedef enum {
//    Model_Clock = 1,          //闹钟
    Model_Sedentary = 2,      //久坐
    Model_HWOption = 3,       //硬件功能
    Model_MESPush = 4,        //消息过滤
//    Model_Schedule = 5,  //日程
}ModelType;

@interface IwownModel : NSObject <NSCoding>

+ (id)getModel:(ModelType)type;
+ (void)saveModel:(IwownModel *)model;
+ (void)initBLEModel;
@end


@interface IwownClock : IwownModel <NSCoding>
+ (instancetype)defaultClock;

/**
 * switch of clock ,defalult is NO.
 * 开关状态，闹钟的开关，默认是关。
 */
@property (nonatomic ,assign) BOOL switchStatus;

/**
 * this attribute denote that is this clock viable ,default is no.
 * 表示闹钟是否可见，删除的闹钟或者该编号闹钟没有被添加的VISABLE为0
 */
@property (nonatomic ,assign) BOOL viable;

/**
 * index of clock ,valiable range is 0～7.
 * 闹钟索引，支持8个闹钟，索引有效范围0～7
 */
@property (nonatomic ,assign) NSUInteger clockId;
@property (nonatomic ,readonly ,assign) NSUInteger clockType;


/* 0xff    b7 重复标记  b6:周一    b5:周二   b4:周三   b3:周四   b2:周五   b1:周六   b0:周日
 * 1表示开启  0表示关闭
 */
@property (nonatomic ,assign) NSUInteger weekRepeat;
@property (nonatomic ,assign) NSUInteger clockHour;
@property (nonatomic ,assign) NSUInteger clockMinute;
@property (nonatomic ,assign) NSUInteger clockTipsLenth; //DEPRECATED_ATTRIBUTE;
@property (nonatomic ,strong) NSString *clockTips; //DEPRECATED_ATTRIBUTE;

@end

@interface IwownSedentary : IwownModel <NSCoding,NSCopying>
+ (instancetype)defaultSedentary;

/**
 * the state of reminder switch, default is NO ,means off.
 * 久坐提醒的开关状态，默认关闭。
 */
@property (nonatomic ,assign) BOOL switchStatus;

/*
 *  可以设置多端，但时间不要交叉，
    eg： @｛sedentaryId：0，startHour：8:00，endHour：12:00｝，@｛sedentaryId：1，startHour：14:00，endHour：18:00｝is right
     but @｛sedentaryId：0，startHour：8:00，endHour：14:00｝，@｛sedentaryId：1，startHour：12:00，endHour：18:00｝is wrong
 */
@property (nonatomic ,assign) NSUInteger sedentaryId;

/**
 * the repeats of sedentary ,to know more details to see @code checkBoxStateChanged methods。
 * 久坐的重复设置 详情请参考 @code checkBoxStateChanged 函数。
 */
@property (nonatomic ,assign) NSUInteger weekRepeat ;

/**
 * the startTime of sedentary ,unit is hour .
 * 判断久坐的开始时间，整数，单位是小时
 */
@property (nonatomic ,assign) NSUInteger startHour;

/**
 * the endTime of sedentary ,unit is hour .
 * 判断久坐的结束时间，整数，单位是小时
 */
@property (nonatomic ,assign) NSUInteger endHour;

/**
 * the monitor duration ,unit is minute . your may demanded set a num is multiple of 5.
 * 判断久坐的时间长度，整数，单位是分钟
 * default duration is 60 minutes and threshold is 50 steps if you set both zero.
 */
@property (nonatomic ,assign) NSUInteger sedentaryDuration;
@property (nonatomic ,assign) NSUInteger sedentaryThreshold;

@end

typedef enum{
    UnitTypeInternational = 0, // International units ,like km、meter、kg .国际制单位，如，千米 、米 、千克。
    UnitTypeEnglish            // Imperial units ,like feet、inch、pound .国际制单位，如，英尺 、英寸 、磅。
}UnitType;

typedef enum{
    TimeFlag24Hour = 0,
    TimeFlag12Hour
}TimeFlag;

typedef enum{
    braceletLanguageDefault = 0, //default means no char ,all information replaced by figure.
    braceletLanguageSimpleChinese,
    braceletLanguageEnglish  DEPRECATED_ATTRIBUTE ,// some smartband did not support it ,use braceletLanguageDefault if you don't want set in simple chinese.
    braceletLanguageSimpleMarkings = 0xff, //show simple icon only.
}braceletLanguage;

@interface IwownHWOption : IwownModel <NSCoding>
+ (instancetype)defaultHWOption;
/**
 * switch of led light ,default is NO ,brcelet i7 is not supported .
 * LED灯开关，默认为NO，i7手环不支持。
 */
@property (nonatomic ,assign) BOOL ledSwitch;

/**
 * switch of wrist ,default is YES.
 * 翻腕开关,默认为YES。
 */
@property (nonatomic ,assign) BOOL wristSwitch;

/**
 * switch of unitType changed ,default is UnitTypeInternational.
 * 公英制单位切换开关 ，默认是国际单位制。
 */
@property (nonatomic ,assign) UnitType unitType;

/**
 * switch of timeFlag changed ,default is TimeFlag24Hour.
 * 时间制式切换开关 ,默认是24小时制。
 */
@property (nonatomic ,assign) TimeFlag timeFlag;

/**
 * switch of autoSleep ,default is YES ,that means bracelet recognize sleep state automatically .
 * 自动睡眠开关, 默认为YES, 也就是手环自动识别睡眠状态。
 */
@property (nonatomic ,assign) BOOL autoSleep;

@property (nonatomic ,assign) BOOL advertisementSwitch;
@property (nonatomic ,assign) NSUInteger backlightStart;
@property (nonatomic ,assign) NSUInteger backlightEnd;

/**
 *  backGroundColor for device, default is NO.  YES is white，NO is black
 *  屏幕背景颜色，默认为NO. YES为白色，NO为黑色.
 */
@property (nonatomic, assign) BOOL backColor;
/**
 * switch of what's language bracelet is used ,default is braceletLanguageSimpleChinese ,to know more about language that bracelet supported. @see braceletLanguage .
 * 手环使用的语言设置开关, 默认为简体中文。
 */
@property (nonatomic ,assign) braceletLanguage language;

/**
 *  switch of disConnectTip, default is NO ,default is close the tips 0f disConnect.
 *  断连提醒，默认为NO,也就是关闭提醒。
 */
@property (nonatomic, assign) BOOL disConnectTip;
@end



@interface IwownPersonal : IwownModel <NSCoding>

+ (instancetype)defaultPersonalModel;
/**
 * height of personal setting , unit is cm .default is 170.
 * 用户身高设置, 单位是厘米。 默认设置为170。
 */
@property (nonatomic ,assign) NSUInteger height;

/**
 * weight of personal setting , unit is kg .default is 170.
 * 用户体重设置, 单位是公斤。 默认设置为60。
 */
@property (nonatomic ,assign) NSUInteger weight;

/**
 * gender of personal setting ,0 represent male ,1 represent female .default is 0 .
 * 用户性别设置, 0表示男性，1表示女性。 默认设置为0。
 */
@property (nonatomic ,assign) NSUInteger gender;

/**
 * age of personal setting .default is 20.
 * 用户年龄设置。 默认设置为20。
 */
@property (nonatomic ,assign) NSUInteger age;

@property (nonatomic ,assign) NSUInteger target;
@end


typedef enum {
    MSGChangeSwithNumAll = 0,
    MSGChangeSwithNumPhone,
    MSGChangeSwithNumMessage,
    MSGChangeSwithNumQQ = 3,
    MSGChangeSwithNumWechat = 4,
    MSGChangeSwithNumFacebook = 5,
    MSGChangeSwithNumTwitter = 6,
    MSGChangeSwithNumSkype = 7,
    MSGChangeSwithNumWhatsapp = 8 ,
}MSGChangeSwithNum;
@interface IwownMESPush : IwownModel <NSCoding>

+ (instancetype)defaultMESPushModel;
/**
 * there are some attributes setting with message push ,the switch is setting yes ,the message of this social contact and which did show in apple notification center would pushed to your bracelet and notice it .Default is YES . @note make sure your bracelet is connectted with the iphone‘s sysctem.
 * 这里有一些社交平台的消息通知的开关，当开关打开时，显示在手机系统通知中心里对应社交平台的消息，将会推送到手环上,默认设置是YES。 @⚠️：确保你的手环和手机系统的连接
 */
@property (nonatomic ,assign) BOOL iphoneSwitch DEPRECATED_ATTRIBUTE;
@property (nonatomic ,assign) BOOL msgSwitch DEPRECATED_ATTRIBUTE;
@property (nonatomic ,assign) BOOL qqSwitch;
@property (nonatomic ,assign) BOOL wechatSwitch;
@property (nonatomic ,assign) BOOL facebookSwitch;
@property (nonatomic ,assign) BOOL twitterSwitch;
@property (nonatomic ,assign) BOOL skypeSwitch;
@property (nonatomic ,assign) BOOL whatsappSwitch;


/**
 *
 */
@property (nonatomic ,assign) NSInteger changeSwitch;
@end

@interface SportModel : IwownModel <NSCoding>
@property (nonatomic,assign)NSString *sportName;
@property (nonatomic,strong,readonly)NSString *unit;
@property (nonatomic,assign)sd_sportType type;
@property (nonatomic,assign)NSInteger targetNum;
@end

@interface IwownSportTarget : IwownModel <NSCoding>
+ (instancetype)defaultSportTargetModel;

/*
 * 0-6 monday-sunday
 */
@property (nonatomic,assign)NSInteger day;
/**
 *  添加的运动 请第一项设为步行（应该手环会默认作为步行处理）
 */
@property (nonatomic,strong)NSMutableArray *sportArr;
- (void)addSportModel:(SportModel *)sm;
@end


@interface IwownSchedule : NSObject
typedef enum {
    ScheduleUnSetting = 0,      //日程未写入
    ScheduleSetting = 1,        //日程已写入
    ScheduleInvalid = 2,        //日程无效（关闭的的日程）
}ScheduleState;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *subTitle;

@property(nonatomic,assign)NSInteger year;
@property(nonatomic,assign)NSInteger month;
@property(nonatomic,assign)NSInteger day;

@property(nonatomic,assign)NSInteger hour;
@property(nonatomic,assign)NSInteger minute;

@property(nonatomic,assign)NSInteger state;

@property(nonatomic,strong)NSDate   *invalidDate;

- (instancetype)initWithTitile:(NSString *)title subTitle:(NSString *)subTitle year:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute;
@end

typedef NS_ENUM (NSInteger,ShakeType){
    ShakeTypeClock = 0,
    ShakeTypeCall = 1,
    ShakeTypeMsg = 2,
    ShakeTypeSedentary = 3,
    ShakeTypeCharging = 4,
    ShakeTypeSchedule = 5,
    ShakeTypeCommon = 6
};

typedef NS_ENUM (NSInteger,ShakeWay){

    ShakeWayStaccato = 4 ,  //断奏
    ShakeWayWave         ,  //波浪

    ShakeWayPitpat   = 7 ,  //心跳
    ShakeWayRadiate      ,  //放射

    ShakeWayLight    = 11,  //灯塔
    ShakeWaySymphony     ,  //交响乐
    
    ShakeWayRapid    = 15,  //快速
};

@interface IwownMotor : IwownModel

+ (NSArray <IwownMotor *> *)defaultMotors ;
@property (nonatomic,assign)ShakeType   type;
@property (nonatomic,assign)ShakeWay    modeIndex;
@property (nonatomic,assign)NSInteger   shakeCount;

+ (NSString *)chineseNameForShakeWay:(ShakeWay)modelIndex;
@end

typedef NS_ENUM (NSInteger,DNDType){
    DNDTypeNull = 0 , // mean closed dndMode
    DNDTypeNormal ,
    DNDTypeSleep ,
    DNDTypeAllDay,
};
@interface IwownDNDModel : IwownModel

@property(nonatomic,assign)NSInteger dndType;  //when dndtype == DNDTypeNull, mean this smartBand has not set dnd model; you can also set dndType = 0 to close dnd model
@property(nonatomic,assign)NSInteger startHour;
@property(nonatomic,assign)NSInteger startMinute;

@property(nonatomic,assign)NSInteger endHour;
@property(nonatomic,assign)NSInteger endMinute;
@end

typedef NS_ENUM(NSInteger,WeatherType) {
     WeatherFine = 0,            //晴
     WeatherCloudy = 1,          //多云
     WeatherOvercast = 2,        //阴天
     WeatherLightRain = 3,       //小雨
     WeatherModerateRain = 4,    //中雨
     WeatherHeavyRain = 5,       //大雨
     WeatherShower = 6,          //阵雨
     WeatherSnow = 7,            //雪
     WeatherHaze = 8,            //雾霾
     WeatherSandstorm = 9        //沙尘暴
};

typedef NS_ENUM(NSInteger,TempUnit) {
     Centigrade = 0, //摄氏温度
     Fahrenheit = 1, //华氏温度
};

@interface IwownWeather : IwownModel

@property (nonatomic,assign)NSInteger temp;//温度值
@property (nonatomic,assign)TempUnit unit;
@property (nonatomic,assign)WeatherType  type;
@property (nonatomic,assign)NSInteger pm;
@end


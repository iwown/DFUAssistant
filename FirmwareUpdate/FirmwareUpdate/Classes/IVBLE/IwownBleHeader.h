//
//  IwownBleHeader.h
//  BLELib3
//
//  Created by 曹凯 on 16/1/4.
//  Copyright © 2016年 Iwown. All rights reserved.
//

#ifndef IwownBleHeader_h
#define IwownBleHeader_h

#define SCREEN_WIDTH_INLIB ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT_INLIB ([UIScreen mainScreen].bounds.size.height)

#define PEDOMETER_NEW_SERVICE_UUID          @"FF20"
#define PEDOMETER_NEW_CHARACT_SET_UUID      @"FF21"
#define PEDOMETER_OLD_CHARACT_TEST          @"FF22"
#define PEDOMETER_NEW_CHARACT_TEST          @"FF23"
#define PEDOMETER_NFC_CHARACT_TEST          @"FF25"

#define SPOTA_SERVICE_UUID_TEST     @"FEF5"  //Dialog升级服务

#define PEDOMETER_OLD_CHARACT_VALUE_PERFIX  @"22ff"
#define PEDOMETER_NEW_CHARACT_VALUE_PERFIX  @"23ff"
#define PEDOMETER_NFC_DATA_PREFIX           @"25ff"

#define UPLIMIT_CHARNO    (12)//I5
#define SCREEN_UPLIMIT_CHARNO   (32)
#define TIMEDELAY (1.0)

#define test



typedef enum {
    BLE_LOG_RECEIVE    = 0,
    BLE_LOG_SEND  = 1,
    BLE_LOG_NORMAL  = 2,
}bleLogType;

/*********************************************************************
 * MACROS
 */
#define MAKE_HEADER(grp, cmd)      ((((Byte)grp & 0x0f) << 4) | ((Byte)cmd & 0x0f))
#define GET_GROUP(header)          (((Byte)header & 0xf0) >> 4)
#define GET_COMMAND(header)        ((Byte)header & 0x0f)
/*********************************************************************
 * TYPEDEFS
 */
typedef enum
{
    CMD_GRP_DEVICE = 0,               // RESET, UPDATE, INFORMATION, see @CMD_ID_DEVICE_
    CMD_GRP_NFC = CMD_GRP_DEVICE,
    CMD_GRP_CONFIG,               // TIME_SETTINGS, BLE_SETTING, AC_SETTING, NMA_SETTING
    CMD_GRP_DATALOG,              // CLEAR, GET, PEDO_SETTING
    CMD_GRP_MSG,                  // UPLOAD, DOWNLOAD
    CMD_GRP_CTRL,
    CMD_GRP_HEARTRATE,            //心率
} braceletCmd_Group_t;

typedef enum
{
    CMD_ID_DEVICE_GET_INFORMATION = 0,
    CMD_ID_DEVICE_NFC_SET_AND_GET = CMD_ID_DEVICE_GET_INFORMATION,
    CMD_ID_DEVICE_GET_BATTERY = 1,
    CMD_ID_DEVICE_RESET = 2,
    CMD_ID_DEVICE_UPDATE = 3,
    CMD_ID_DEVICE_REQ_REBOND = 4,
    CMD_ID_DEVICE_DO_REBOND = 5,
    CMD_ID_DEVICE_DND_MODE = 6,
    CMD_ID_DEVICE_WEATHER = 7,
    
    CMD_ID_CONFIG_SET_TIME = 0,           // Time
    CMD_ID_CONFIG_GET_TIME = 1,
    CMD_ID_CONFIG_SET_BLE = 2,                // BLE
    CMD_ID_CONFIG_GET_BLE = 3,
    CMD_ID_CONFIG_SET_AC = 4,                 // AlarmClock
    CMD_ID_CONFIG_GET_AC = 5,
    CMD_ID_CONFIG_SET_NMA = 6,                // No-Move-Alert
    CMD_ID_CONFIG_GET_NMA = 7,
    CMD_ID_CONFIG_SET_HW_OPTION = 8,          // Hardware Option
    CMD_ID_CONFIG_GET_HW_OPTION = 9,
    CMD_ID_CONFIG_GET_SPORT_LIST = 10,         // Sport List
    CMD_ID_CONFIG_SET_SPORT_TARGET = 11,
    CMD_ID_CONFIG_GET_SPORT_TARGET = 12,
    CMD_ID_CONFIG_SET_SCHEDULE     = 13,
    CMD_ID_CONFIG_GET_SCHEDULE     = 14,
    
    CMD_ID_DATALOG_SET_BODY_PARAM = 0,    // Body Parmameters
    CMD_ID_DATALOG_GET_BODY_PARAM = 1,        // Body Parmameters
    CMD_ID_DATALOG_CLEAR_ALL = 2,
    CMD_ID_DATALOG_START_GET_DAY_DATA = 3,
    CMD_ID_DATALOG_STOP_GET_DAY_DATA = 4,
    CMD_ID_DATALOG_START_GET_MINUTE_DATA = 5,
    CMD_ID_DATALOG_STOP_GET_MINUTE_DATA = 6,
    CMD_ID_DATALOG_GET_CUR_DAY_DATA = 7,
    CMD_ID_DATALOG_GET_SPORTDATA  = 8,
    CMD_ID_DATALOG_GET_CUR_SPORTDATA = 9,
    
    CMD_ID_MSG_UPLOAD = 0,
    CMD_ID_MSG_SINGLE_DOWNLOAD = 1,
    CMD_ID_MSG_MULTI_DOWNLOAD_START = 2,
    CMD_ID_MSG_MULTI_DOWNLOAD_CONTINUE = 3,
    CMD_ID_MSG_MULTI_DOWNLOAD_END = 4,
    CMD_ID_MSG_MSG_SWITCH_SET = 5,
    CMD_ID_MSG_MSG_SWITCH_GET = 6,
    
    CMD_ID_CTRL_KEYNOTIFY = 0,
    CMD_ID_CTRL_MOTOR = 1,
    CMD_ID_CTRL_SENSOR = 2,
    

    CMD_ID_HEARTRATE_PARAM       = 0,     //读取和设置心率参数
    CMD_ID_HEARTRATE_DATA        = 1,     //分段心率数据同步
    CMD_ID_HEARTRATE_UPDATE      = 2,     //心率模块升级控制
    CMD_ID_HEARTRATE_HOURS_DATA  = 3,     //分时心率数据
    
} braceletCmd_Command_t;

/*sport type*/
/*数据运动模式*/
typedef enum
{
    SD_SPORT_TYPE_SLEEP							= 0x00, //睡眠
    
    SD_SPORT_TYPE_WALKING						= 0x01,//走路
    SD_SPORT_TYPE_SITE_UPS						= 0x02,//仰卧起坐
    SD_SPORT_TYPE_PUSH_UP						= 0x03 ,//俯卧撑
    SD_SPORT_TYPE_ROPE_SKIPPING					= 0x04 ,//跳绳
    SD_SPORT_TYPE_MOUNTAINEERING         		= 0x05 ,//登山
    SD_SPORT_TYPE_PULL_UP						= 0x06 ,//引体向上
    SD_SPORT_TYPE_RUNNING						= 0x07,//跑步
    
    SD_SPORT_TYPE_MASK							= 0x80 ,//掩码
    
    SD_SPORT_TYPE_BADMINTON						= 0x80 ,//羽毛球
    SD_SPORT_TYPE_BASKETBALL					= 0x81 ,//篮球
    SD_SPORT_TYPE_FOOTBALL						= 0x82,//足球
    SD_SPORT_TYPE_SWIM							= 0x83,//游泳
    SD_SPORT_TYPE_VOLLEYBALL					= 0x84 ,//排球
    SD_SPORT_TYPE_TABLE_TENNIS					= 0x85 ,//乒乓球
    SD_SPORT_TYPE_BOWLING						= 0x86 ,//保龄球
    SD_SPORT_TYPE_TENNIS						= 0x87 ,//网球
    SD_SPORT_TYPE_CYCLING						= 0x88 ,//骑行
    SD_SPORT_TYPE_SKI							= 0x89 ,//滑雪
    SD_SPORT_TYPE_SKATE							= 0x8a ,//滑冰
    SD_SPORT_TYPE_ROCK_CLIMBING					= 0x8b ,//攀岩
    SD_SPORT_TYPE_GYM							= 0x8c ,//健身房健身
    SD_SPORT_TYPE_DANCE							= 0x8d ,//舞蹈
    SD_SPORT_TYPE_TABLET_SUPPORT				= 0x8e ,//平板撑
    SD_SPORT_TYPE_GYM_EXERCISE                  = 0x8f ,//健身操
    SD_SPORT_TYPE_YOGA							= 0x90 ,//瑜伽
    SD_SPORT_TYPE_SHUTTLECOCK					= 0x91 ,//毽球
    SD_SPORT_TYPE_ALLBALL           = 0x92, //球类运动
    
    SD_SPORT_TYPE_HEART_RATE                    = 0xf0 ,//心率
    
}sd_sportType;


#endif /* IwownBleHeader_h */

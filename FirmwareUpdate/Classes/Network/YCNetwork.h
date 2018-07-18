//
//  YCNetwork.h
//  Kawayi
//
//  Created by IW on 2018/1/24.
//  Copyright © 2018年 A$CE. All rights reserved.
//

#ifndef YCNetwork_h
#define YCNetwork_h

typedef NS_ENUM(NSInteger, IWHTTPResponseCode) {
    IWHTTPResponseCodeConnectSeverFail = -1, //连接服务器出错
    IWHTTPResponseCodeSuccess = 0,   //成功
    IWHTTPResponseCodeDBError = 10001,//数据库错误
    IWHTTPResponseCodeNoData = 10404, //无数据
    IWHTTPResponseCodeParameterNotProvided = 10002,//没有提供此参数
    IWHTTPResponseCodeBaiduServiceNotRegister = 10003,//百度服务没有注册
    IWHTTPResponseCodeBaiduServiceFailure = 10004,//百度服务失败
    IWHTTPResponseCodeAccessUserServiceFailed = 10005,//进入用户服务失败
    IWHTTPResponseCodeInvalidLoginAccountType = 50001,//登录类型无效
    IWHTTPResponseCodeInvalidPhoneNumberformat = 50002,//手机号码格式不对
    IWHTTPResponseCodePasswordNotMatch = 50003,//密码错误
    IWHTTPResponseCodeUserAlreadyExist = 50004,//用户已存在
    IWHTTPResponseCodeSendPasswordMailFailed = 50005,//发送密码邮件失败
    IWHTTPResponseCodeInvalidPlatform = 50006,//无效的平台
    IWHTTPResponseCodeRelativeAlreadyExist = 50007,//
    IWHTTPResponseCodeUnionIDNotFound = 50008,//
    IWHTTPResponseCodeInvalidQueryType = 50009,//
    IWHTTPResponseCodeNoResultsOrResultsTooMany = 50010,//没有结果或者结果太多
    IWHTTPResponseCodeInvalidRegisterType = 50011,//无效的注册类型
    IWHTTPResponseCodeUserNotExist = 50012,//用户不存在
    IWHTTPResponseCodeNoNewFirmwareAvailable = 60001,//没有新的固件升级包
    IWHTTPResponseCodeWeChatInfoNOTRegister = 60002,//
    IWHTTPResponseCodeSaveFileError = 60003,//保存文件失败
};

#import "CYHttpProtocolDef.h"
#import "IWRetCodeTool.h"
#import <YCNetworkLibrary/YCNetworkLibrary.h>
#import "YCNetWorkTool.h"


#endif /* YCNetwork_h */

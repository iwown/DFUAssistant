//
//  IVNetAPI.h
//  linyi
//
//  Created by caike on 16/12/20.
//  Copyright © 2016年 com.kunekt.healthy. All rights reserved.
//

#ifndef IVNetAPI_h
#define IVNetAPI_h


typedef enum {
    IVSERVICE_ERROR_DBError  = 10001,
    IVSERVICE_ERROR_ParameterMiss  ,
    IVSERVICE_ERROR_BSNotRegister , //  BaiduServiceNotRegister
    IVSERVICE_ERROR_BSFailure  ,    //  BaiduServiceFailure
    IVSERVICE_ERROR_AccessUserServiceFailed  ,
    IVSERVICE_ERROR_FileIOError  ,
    
    IVSERVICE_ERROR_NoData  = 10404,
    
    IVSERVICE_SOCIAL_InvalidDirection = 30001,
    IVSERVICE_SOCIAL_GenerateDepartmentIdFailed ,
    IVSERVICE_SOCIAL_NoAdminExist ,
    IVSERVICE_SOCIAL_DepartmentNotEmpty ,
    IVSERVICE_SOCIAL_NotAdminOfCompany , // 30005
    IVSERVICE_SOCIAL_SizeOutLimit ,
    IVSERVICE_SOCIAL_ApplyIsExist ,
    IVSERVICE_SOCIAL_ApplyIsNotExist ,
    
    IVSERVICE_USER_IvalidLoginAccountType  = 50001,
    IVSERVICE_USER_IvalidPhoneNumFormat ,
    IVSERVICE_USER_PasswordNotMatch ,
    IVSERVICE_USER_UserAlreadyExist ,
    IVSERVICE_USER_SendPasswordMailFailed ,  //50005
    IVSERVICE_USER_InvalidPlatform,
    IVSERVICE_USER_RelativeAlreadyExist,
    IVSERVICE_USER_UnionIDNotFound ,
    IVSERVICE_USER_InvalidQueryType ,
    IVSERVICE_USER_NoResultsOrResultsTooMany ,  //50010
    IVSERVICE_USER_InvalidRegisterType ,
    IVSERVICE_USER_ThisAccountNotRegister ,
    IVSERVICE_USER_RelativeNotExist ,
    
    IVSERVICE_DEVICE_NoUpdateFile = 60001,
    
    IVSERVICE_FILE_FileUploadError = 90004,

}IVSERVICE_ERROR;


/**
 版本号
 */
#define APP_VERSION
/**
 平台号
 */
#define APP_PLATFORM

/**
 * 众测环境
 */
#define http_ip                                  @"http://betaapi.iwown.com:9000/venus"
#define http_oversea_ip                          @"http://hwbetaapi.iwown.com/venus"

#define http_device_ip                           http_ip

#define SERVICE_DEVICE                          [http_device_ip stringByAppendingString:@"/deviceservice/device"]        //设备

//Device
#define API_FW_UPDATE                           @"/fwupdate"
#define API_UPLOAD_FWINFO                       @"/uploadUpgrade"
#define API_DOWNLOAD_FWINFO                     @"/downloadUpgrade"


#define isSuccess(res) (res && (errorId(res)==0 || errorId(res)==10003 || errorId(res)==10004 || errorId(res)==10404))
#define isSuccessDev(res) (res && (errorId(res)==0 || errorId(res)==10404))
#define errorId(res) ([res[@"retCode"] integerValue])


#endif /* IVNetAPI_h */

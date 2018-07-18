//
//  YCNetworkSetting.h
//  YCNetworkLibrary
//
//  Created by CY on 2018/1/18.
//  Copyright © 2018年 c123. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YCNetworkSetting : NSObject
/**
 * 默认为空字符串@""，如果需要设置，请在使用网络库之前赋值；
 */

@property (nonatomic, strong) NSString *baseUrl;
/**
 * 是否在控制台打印URL；默认不打印；
 */
@property (nonatomic, assign) BOOL logURL;

/**
 * 是否在控制台打印参数；默认不打印；
 */
@property (nonatomic, assign) BOOL logParam;
/**
 * 是否保存日志文件到本地；默认不保存；
 */
@property (nonatomic, assign) BOOL saveLogFile;

+ (YCNetworkSetting *)shareSetting;
@end

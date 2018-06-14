//
//  IVHttpClient.h
//  linyi
//
//  Created by caike on 16/12/20.
//  Copyright © 2016年 com.kunekt.healthy. All rights reserved.
//

#import <Foundation/Foundation.h>
@class IVHttpRequest;

/**
 http网络请求客户端（负责分发数据请求，处理响应）
 */
@interface IVHttpClient : NSObject

/**
 监测网络状态
 */
+ (void)startMonitoring;

/**
 网络是否可用

 @return YES or NO
 */
+ (BOOL)networkReachability;


/**
 异步GET请求

 @param request 请求对象
 @param completion responseObj返回值，error错误对象
 */
+ (void)sendAsyncGetRequest:(IVHttpRequest *)request completion:(void (^)(id responseObj, NSError *error))completion;


/**
 异步POST请求

 @param request 请求对象
 @param completion responseObj返回值，error错误对象
 */
+ (void)sendAsyncPostRequest:(IVHttpRequest *)request completion:(void (^)(id responseObj, NSError *error))completion;


/**
 同步GET请求
 
 @param request 请求对象
 @param returnError error接收对象
 @return id返回值
 */
+ (id)sendSyncGetRequest:(IVHttpRequest *)request error:(NSError **)returnError;

/**
 同步POST请求

 @param request 请求对象
 @param returnError error接收对象
 @return id返回值
 */
+ (id)sendSyncPostRequest:(IVHttpRequest *)request error:(NSError **)returnError;



/**
 文件上传

 @param request 请求对象  需设置fileData fileName mimeType
 @param completion responseObj返回值，error错误对象
 */
+ (void)sendUploadRequest:(IVHttpRequest *)request completion:(void (^)(id responseObj, NSError *error))completion;

@end

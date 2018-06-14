//
//  IVHttpClient.m
//  linyi
//
//  Created by caike on 16/12/20.
//  Copyright © 2016年 com.kunekt.healthy. All rights reserved.
//

#import "IVHttpClient.h"
#import <AFNetworking/AFNetworking.h>
#import "IVHttpRequest.h"
@implementation IVHttpClient

#pragma mark - 网络状态
+ (void)startMonitoring
{
    [[AFNetworkReachabilityManager sharedManager]setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

+ (BOOL)networkReachability
{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}


#pragma mark - 网络请求
+ (void)sendAsyncGetRequest:(IVHttpRequest *)request completion:(void (^)(id, NSError *))completion
{
    [request setMethod:GET];
    [self fetchDataWithRequest:request completion:completion];
}

+ (void)sendAsyncPostRequest:(IVHttpRequest *)request completion:(void (^)(id, NSError *))completion
{
    [request setMethod:POST];
    [self fetchDataWithRequest:request completion:completion];
}

+ (id)sendSyncPostRequest:(IVHttpRequest *)request error:(NSError * __autoreleasing *)returnError
{
    AFHTTPSessionManager *manager = [self manager];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block id data = nil;
    NSLog(@"POST网络请求----%@",request);
    [manager POST:request.absoluteURL parameters:request.parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"返回值:%@",responseObject);
        data = responseObject;
        dispatch_semaphore_signal(semaphore);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (returnError) {
            *returnError = error;
        }
        NSLog(@"网络请求Error:\n%@",error);
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return data;
}

+ (id)sendSyncGetRequest:(IVHttpRequest *)request error:(NSError * __autoreleasing *)returnError
{
    AFHTTPSessionManager *manager = [self manager];
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    __block id data = nil;
    NSLog(@"GET网络请求----%@",request);
    [manager GET:request.absoluteURL parameters:request.parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"返回值:%@",responseObject);
        data = responseObject;
        dispatch_semaphore_signal(semaphore);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (returnError) {
            *returnError = error;
        }
        NSLog(@"网络请求Error:\n%@",error);
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    return data;
}


+ (void)sendUploadRequest:(IVHttpRequest *)request completion:(void (^)(id, NSError *))completion
{
    AFHTTPSessionManager *manager = [self manager];
    NSLog(@"文件上传请求----%@  %@",request,request.mimeType);
    [manager POST:request.absoluteURL parameters:request.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:request.filedata name:@"file" fileName:request.fileName mimeType:request.mimeType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"返回值:%@",responseObject);
        completion(responseObject,nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"网络请求Error:\n%@",error);
        completion(nil,error);
    }];
}



#pragma mark 私有方法
/**
 通过请求获取数据
 
 @param request 请求参数对象
 @param completion 响应
 */
+ (void)fetchDataWithRequest:(IVHttpRequest *)request completion:(void (^)(id, NSError *))completion
{
    AFHTTPSessionManager *manager = [self manager];
    
    if ([[request httpMehtod] isEqualToString:GET]) {
        [manager GET:request.absoluteURL parameters:request.parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"GET网络请求----%@\n返回值:%@",request,responseObject);
#ifdef DEVELOPER_TEST
            if (!isSuccessDev(responseObject)) {
                [Utils hudToast:[NSString stringWithFormat:@"errorID:%ld",errorId(responseObject)]];
            }
#endif
            completion(responseObject,nil);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"GET网络请求----%@\n网络请求Error:\n%@",request,error);
#ifdef DEVELOPER_TEST
            [Utils hudToast:[NSString stringWithFormat:@"errorID:%ld\n%@",error.code,error.localizedDescription]];
#endif
            completion(nil,error);
        }];
    }
    else{
        [manager POST:request.absoluteURL parameters:request.parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"POST网络请求----%@\n返回值:%@",request,responseObject);
#ifdef DEVELOPER_TEST
            if (!isSuccessDev(responseObject)) {
                [Utils hudToast:[NSString stringWithFormat:@"errorID:%ld",errorId(responseObject)]];
            }
#endif
            completion(responseObject,nil);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"POST网络请求----%@\n网络请求Error:\n%@",request,error);
#ifdef DEVELOPER_TEST
                [Utils hudToast:[NSString stringWithFormat:@"errorID:%ld\n%@",error.code,error.localizedDescription]];
#endif
            completion(nil,error);
        }];
    }
}

+ (AFHTTPSessionManager *)manager
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [self requestSerializer];
    manager.responseSerializer = [self responseSerializer];
    manager.securityPolicy = [self securityPolicy];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/x-msdownload"];
    return manager;
}


+ (AFJSONRequestSerializer *)requestSerializer{
    AFJSONRequestSerializer *serializer = [AFJSONRequestSerializer serializer];
    serializer.timeoutInterval = 15;    //超时时间
    return serializer;
}

+ (AFJSONResponseSerializer *)responseSerializer{
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    return serializer;
}


+ (AFSecurityPolicy *)securityPolicy {
    AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    [policy setValidatesDomainName:NO];
    return policy;
}

@end

//
//  CYBasicRequest.h
//  CYRequestDemo
//
//  Created by CY on 2016/11/28.
//  Copyright © 2016年 chenyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
//请求方式
static NSString * _Nonnull const  POST = @"http_post";
static NSString * _Nonnull const  GET = @"http_get";


@class IWBasicRequest;

typedef void(^YCRequestCompletionBlock)(__kindof IWBasicRequest * request);//__kindof一般用在返回值，表示返回该类或其子类

@protocol AFMultipartFormData;
typedef void (^AFConstructingBlock)(id <AFMultipartFormData> formData);


/**
 *  数据请求对象基类
 */
@interface IWBasicRequest : NSObject

#pragma mark - Request的一些设置


/**
 *  Http请求方法（POST、GET）,默认为GET
 *  需要在子类的getter方法里面赋值
 */
@property (nonatomic, readonly) NSString* httpMethod;

/**
 *  POST方式时的参数数组/字典，POST时子类必须对其赋值（POST时子类必须赋值，可以为nil）
 *  GET方式时设置无效
 *  需要在子类的getter方法里面赋值
 */
@property (nonatomic, strong,readonly) id postBodyParameters;

/**
 *  POST方式时的 URL Params 参数集合，默认为nil;
 *  GET方式的时候的URL Params 参数集合，默认为nil；
 *  需要在子类的getter方法里面赋值
 */
@property (nonatomic, strong,readonly) id urlParameters;


/**
 *  Http的请求url，例如："https://apple.api.com",默认为nil
 *  需要在子类的getter方法里面赋值
 */
@property (nonatomic, readonly) NSString * baseUrl;

/**
 *  Http的请求url的具体路径，例如："/user/login",默认为nil
 *  需要在子类的getter方法里面赋值
 */
@property (nonatomic, readonly) NSString * urlPath;

/**
 *  网络请求的超时时间,默认为10；
 *  如果需要更改，请在在子类的getter方法里面赋值
 */
@property (nonatomic, readonly) NSTimeInterval timeoutInterval;


//这个接口还未完善，请暂时不要使用；
- (nullable id)jsonValidator;



/**
 *  如果你需要上传文件，请在子类中override这个方法，具体的方法，请查看上传图片的request示例；
 *
 */
@property (nonatomic, copy, nullable) AFConstructingBlock constructingBodyBlock;

//****************************************************
//****************************************************
//****************************************************


@property (nonatomic, strong, readonly) NSURLSessionTask * _Nullable requestTask;


#pragma mark - Request的回调
@property (nonatomic, copy, nullable) YCRequestCompletionBlock successCompletionBlock;
@property (nonatomic, copy, nullable) YCRequestCompletionBlock failureCompletionBlock;

///  发送请求，并设置请求成功或者失败的回调
- (void)sendRequestWithCompletionBlockWithSuccess:(nullable YCRequestCompletionBlock)success
                                    failure:(nullable YCRequestCompletionBlock)failure;

- (void)clearCompletionBlock;

//****************************************************
//****************************************************
//****************************************************


@property (nonatomic, strong, readonly, nullable) NSString *responseString;

@property (nonatomic, strong, readonly, nullable) id responseObject;

@property (nonatomic, strong, readonly, nullable) id responseJSONObject;

@property (nonatomic, strong, readonly, nullable) NSError *error;

@end

NS_ASSUME_NONNULL_END

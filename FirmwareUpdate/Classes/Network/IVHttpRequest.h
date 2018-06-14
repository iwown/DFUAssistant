//
//  IVHttpRequest.h
//  linyi
//
//  Created by caike on 16/12/20.
//  Copyright © 2016年 com.kunekt.healthy. All rights reserved.
//

#import <Foundation/Foundation.h>
//请求方式
static NSString *const  POST = @"post";
static NSString *const  GET = @"get";

/**
 http网络请求体（负责拼接URL及参数）
 */
@interface IVHttpRequest : NSObject


@property(nonatomic,copy)NSString               *service;
@property(nonatomic,copy)NSString               *api;
@property(nonatomic,strong)id                   parameters;

@property (nonatomic,strong) NSData             *filedata;      //上传数据
@property (nonatomic,copy) NSString             *fileName;      //文件名
@property (nonatomic,copy) NSString             *mimeType;      //文件类型  eg. image/jgp

+ (instancetype)requestWithService:(NSString *)service api:(NSString *)api parameters:(id)parameters;

+ (instancetype)requestWithURL:(NSString *)url parameters:(id)parameters;



- (NSString *)absoluteURL;

- (void)setMethod:(NSString *)method;

- (NSString *)httpMehtod;

#pragma mark 文件上传 参数
//方式一
- (void)setFileData:(NSData *)data fileName:(NSString *)fileName mimeType:(NSString *)mimeType;
//方式二
- (void)setFilePath:(NSString *)filePath fileName:(NSString *)fileName;

@end

//
//  IVHttpRequest.m
//  linyi
//
//  Created by caike on 16/12/20.
//  Copyright © 2016年 com.kunekt.healthy. All rights reserved.
//

#import "IVHttpRequest.h"
#import "IVNetAPI.h"

@interface IVHttpRequest ()
@property (nonatomic,copy)NSString              *URL;
@property (nonatomic,copy)NSString              *method;
@end

@implementation IVHttpRequest

+ (instancetype)requestWithService:(NSString *)service api:(NSString *)api parameters:(id)parameters
{
    IVHttpRequest *request = [[IVHttpRequest alloc]init];
    request.service = service;
    request.api = api;
    request.parameters = parameters;
    return request;
}

+ (instancetype)requestWithURL:(NSString *)url parameters:(id)parameters
{
    IVHttpRequest *request = [[IVHttpRequest alloc]init];
    request.URL = url;
    request.parameters = parameters;
    return request;
}


- (void)setFileData:(NSData *)data fileName:(NSString *)fileName mimeType:(NSString *)mimeType
{
    _filedata = data;
    _fileName = fileName;
    _mimeType = mimeType;
}

- (void)setFilePath:(NSString *)filePath fileName:(NSString *)fileName
{
    NSURL *binUrl = [NSURL fileURLWithPath:filePath];
    NSURLRequest *requestS = [NSURLRequest requestWithURL:binUrl];
    NSURLResponse *repsonse = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:requestS returningResponse:&repsonse error:nil];
    NSString *mimeType = repsonse.MIMEType;
    [self setFileData:data fileName:fileName mimeType:mimeType];
}



- (NSString *)absoluteURL
{
    if (!self.URL) {
        return [NSString stringWithFormat:@"%@%@",self.service,self.api];
    }
    return self.URL;
}


- (void)setMethod:(NSString *)method
{
    _method = method;
}

- (NSString *)httpMehtod
{
    if (!_method) {
        return GET;
    }
    return _method;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@\nParame:%@",self.absoluteURL,self.parameters];
}


//-(void)dealloc
//{
//    NSLog(@"%s",__FUNCTION__);
//}

@end

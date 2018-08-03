//
//  NetWorkHandle.m
//  FirmwareUpdate
//
//  Created by 曹凯 on 2016/11/16.
//  Copyright © 2016年 west. All rights reserved.
//
#import "IVFirmwareModel.h"
#import "NetWorkHandle.h"

@implementation NetWorkHandle

+ (NSArray <IVFirmwareModel *>*)selectFirmwareList {
    
    //第一步，创建URL
    NSURL *url = [NSURL URLWithString:@"http://betaapi.iwown.com/venus/deviceservice/device/firmwareList?type=0"];

    //第二步，创建请求
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    
    //第三步，连接服务器
    NSError *error;
    NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    NSString *responseStr = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
    
    //Json 解析
    NSData *jdata= [responseStr dataUsingEncoding:NSUTF8StringEncoding];
    if (jdata == nil) {
        return nil;
    }
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jdata options:NSJSONReadingAllowFragments error:&error];
    
    NSMutableArray *mArr = [NSMutableArray arrayWithCapacity:0];
    if ([jsonObject[@"retCode"] integerValue] == 0) {
        jsonObject = jsonObject[@"firmwares"];
        if ([jsonObject isKindOfClass:[NSArray class]])//判断json转diction错误与否
        {
            for (NSDictionary *dict in jsonObject) {
                IVFirmwareModel *fModel = [IVFirmwareModel getInstanceBy:dict];
                [mArr addObject:fModel];
            }
        }else if([jsonObject isKindOfClass:[NSDictionary class]]){
            IVFirmwareModel *fModel = [IVFirmwareModel getInstanceBy:jsonObject];
            [mArr addObject:fModel];
        }else{
            NSLog(@"error!!!  %@",jsonObject);
            return nil;
        }
    }else{
        NSLog(@"error!!!  %@",jsonObject);
        return nil;
    }
    
    return mArr;
}
@end

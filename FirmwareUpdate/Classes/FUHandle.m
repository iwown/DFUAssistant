//
//  FUHandle.m
//  FirmwareUpdate
//
//  Created by A$CE on 2017/9/18.
//  Copyright © 2017年 west. All rights reserved.
//
#import "BtNotify.h"
#import "DFUViewController.h"
#import "SUOTA_DFUController.h"
#import "FOTA_DFUController.h"
#import "ZGDFUController.h"
#import "Toast.h"
#import "FirmwareUpdate.h"
#import <IVBaseKit/IVBaseKit.h>
#import "FUHandle.h"

@interface FUHandle ()
{
    NSString *_fwName;
}
@end

@implementation FUHandle
static FUHandle *__fuhdle = nil;

+ (FUHandle *)handle {
    @synchronized(__fuhdle)
    {
        if (!__fuhdle)
        {
            __fuhdle = [[FUHandle alloc]init];
        }
    }
    
    return __fuhdle;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (UIViewController *)getFUVC:(NSDictionary *)mContent {
    
    if (nil == mContent) {
        [Toast makeToast:@"Newest Version, No Need For Upgrade"];
        return nil;
    }
    
    if (![self dfuCheckFirst]) {
        return nil;
    }
    
    BaseDFUController *dfuVC = nil;
    switch ([[FUHandle handle].deviceInfo platformForDfu]) {
        case DFUPlatformNortic:
        {
            dfuVC = [[DFUViewController alloc]init];
        }
            break;
        case DFUPlatformDialog:
        {
            dfuVC = [[SUOTA_DFUController alloc]init];
        }
            break;
        case DFUPlatformMtk:
        {
            dfuVC = [[FOTA_DFUController alloc]init];
        }
            break;
            
        default:
            dfuVC = [[ZGDFUController alloc]init];
            break;
    }
    if (dfuVC) {
        dfuVC.fwContent = mContent;
    }
    return dfuVC;
}

- (BOOL)dfuCheckFirst {
    /*
     * Determine whether the current upgrade condition is met before entering the bracelet upgrade page.
     * 1. Bluetooth open & & bracelet connection
     * 2. Complete device information
     * 3. The power is greater than 20%
     */
    
    if ([[BLEShareInstance shareInstance] state] != kBLEstateDidConnected) {
        [Toast makeToast:NSLocalizedString(@"Unconnected，please connect the device",nil)];
        return NO;
    }
    
    ZRDeviceInfo *df = self.deviceInfo;
    if (df == nil) {
        [Toast makeToast:NSLocalizedString(@"Reading device info，please wait",nil)];
        return NO;
    }
    
    if ([df batLevel] < 20) {
        [Toast makeToast:NSLocalizedString(@"Low power",nil)];
        return NO;
    }
    return YES;
}
#pragma mark- Public
- (NSNumber *)devicePlatformNumber {
    //oadMode  :1->TI ，2->Nordic ,3->Dialog
    NSUInteger oadMode = [self.deviceInfo oadMode];
    switch (oadMode) {
        case 1:
            return @0;
            break;
        case 2:
            return @1;
            break;
        case 3:
            return @2;
            break;
        case 4:
            return @3;
            break;
            
        default:
            return @0;
            break;
    }
}

- (NSNumber *)deviceModelNumber {
    if ([self.delegate respondsToSelector:@selector(fuHandleReturnModelDfu)]) {
        return @([self.delegate fuHandleReturnModelDfu]);
    }
    NSString *model = [self.deviceInfo model];
    //    2-i5+3, 3-i5+5, 4-i7, 5-v6, 6-i5 pro, 7-i6 pro, 8-i6 HR
    if ([model isEqualToString:@"I5+3"]) {
        return @2;
    }else if ([model isEqualToString:@"I5+5"]) {
        return @3;
    }else if ([model isEqualToString:@"I7S"]){
        return @4;
    }else if ([model isEqualToString:@"V6"]){
        return @5;
    }else if ([model isEqualToString:@"I5PR"]){
        return @6;
    }else if ([model isEqualToString:@"I6"]){
        return @7;
    }else if ([model isEqualToString:@"I6HR"]){
        return @8;
    }else if ([model isEqualToString:@"I6NH"]){
        return @9;
    }else if ([model isEqualToString:@"I7S2"]){
        return @14;
    }else if ([model isEqualToString:@"I6PB"]){
        return @17;
    }else if ([model isEqualToString:@"I6H9"]){
        return @21;
    }else if ([model isEqualToString:@"i6HC"]){
        return @24;
    }else if ([model isEqualToString:@"R1N0"]){
        return @35;
    }else if ([model isEqualToString:@"I6C2"]){
        return @36;
    }else if ([model isEqualToString:@"P2J"]){
        return @37;
    }else if ([model isEqualToString:@"S2"]){
        return @101;
    }
    return @0;
}

- (NSString *)getFWName {
    return _fwName;
}

- (NSString *)getDeivceAlias {
    
    if ([self.delegate respondsToSelector:@selector(fuHandleReturnAliasByModel:)]) {
        NSString *model = [_deviceInfo model];
        if (model) {
            NSString *alias = [self.delegate fuHandleReturnAliasByModel:model];
            if (alias) {
                return alias;
            }
        }
    }

    return @"NO ALIAS";
}

- (NSString *)braceletName:(NSString *)nName {
    if ([self.delegate respondsToSelector:@selector(fuHandleReplaceBroadcastName:)]) {
        return [self.delegate fuHandleReplaceBroadcastName:nName];
    }
    return nName;
}


- (NSString *)saveFileName:(NSString *)fileUrl {
    NSArray *mArr = [fileUrl componentsSeparatedByString:@"/"];
    NSString *name = [mArr lastObject];
    _fwName = name;
    return name;
}

- (BOOL)deleteFW {
    
    NSString *firmwareName = [self getFWName];
    if (!firmwareName) {
        return YES;
    }
    
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:firmwareName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    __autoreleasing NSError *err;
    if ([fileManager fileExistsAtPath:fullPath]){
        return [fileManager removeItemAtPath:fullPath error:&err];
    }
    return YES;
}

- (NSString *)getFWPath {
    
    NSString *firmwareName = [self getFWName];
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:firmwareName];
    return fullPath;
}

- (BOOL)dfuFileIsExist:(NSString *)url {
    
    [self saveFileName:url];
    NSString *fullPath = [self getFWPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:fullPath]) {
        return NO;
    }else{
        return YES;
    }
}

- (BOOL)downFWFromURL:(NSString *)fileURL {
    NSLog(@"执行固件下载函数（Downloading）: %@",fileURL);
//    [self deleteFW];
    NSString *firmwareName = [self saveFileName:fileURL];
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:firmwareName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:fullPath]) {
        NSError *error = nil;
        fileURL = [fileURL stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSURL *url = [NSURL URLWithString:fileURL];
        NSData *data = [NSData dataWithContentsOfURL:url options:NSDataReadingUncached error:&error];
        if (error) {
            NSLog(@"%@",error);
            return NO;
        }
        @try {
            [fileManager createFileAtPath:fullPath contents:data attributes:nil];
        } @catch (NSException *exception) {
            NSLog(@"NSException: %@",exception);
        } @finally {
            
        }
        
        if ([[fileManager contentsAtPath:fullPath] length] == 0) {
            return NO;
        } else {
            NSLog(@"固件下载完成（Complete）");
            return YES;
        }
    } else {
        NSLog(@"固件已存在（Exist）");
        return YES;
    }
}

#pragma mark- API
- (void)fwUpdateRequestWithPlatform:(NSInteger)platform
                          andNeedFW:(NSUInteger)needFW
                   andDeviceVersion:(NSString *)deviceVersion
                         completion:(RequestFirmwareUpdateCompletion)completion {
    
    if (!deviceVersion || deviceVersion.length == 0) {
        completion(nil, nil);
        return;
    }

    NSNumber *modelNum = [self deviceModelNumber];
    
    NSNumber *appVersion = @(1);
    NSNumber *deviceType = @1;
    RequestFirmwareUpdateApi *rfuApi = [[RequestFirmwareUpdateApi alloc] initWithDevicePlatform:@(platform) andDeviceType:deviceType andDeviceModel:modelNum andFirmwareVersion:deviceVersion andApp:6 andAppVersion:appVersion];
    [rfuApi sendRequestWithCompletionBlockWithSuccess:^(__kindof IWBasicRequest * _Nonnull request) {
        completion(request,request.error);
    } failure:^(__kindof IWBasicRequest * _Nonnull request) {
        completion(request,request.error);
    }];
}

#pragma mark- UI
- (int)fuNBCI {
    if ([self.delegate respondsToSelector:@selector(fuNormalButtonColor)]) {
        return [self.delegate fuNormalButtonColor];
    }else {
        return FU_NORAML_BUTTON_COLOR;
    }
}

@end

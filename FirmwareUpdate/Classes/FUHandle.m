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

@interface FUHandle ()<NotifyCustomDelegate>
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
        [[BtNotify sharedInstance] registerCustomDelegate:self];
    }
    return self;
}

- (UIViewController *)getFUVC:(NSDictionary *)mContent {
    
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
     * 进入手环升级页面前判断当前是否符合升级条件
     * 1.蓝牙打开&&手环连接
     * 2.设备信息完整
     * 3.电量大于30%
     */
    
    if ([[BLEShareInstance shareInstance] state] != kBLEstateDidConnected)
    {
        [Toast makeToast:NSLocalizedString(@"设备未连接，请连接设备",nil)];
        return NO;
    }
    
    ZRDeviceInfo *df = self.deviceInfo;
    
    if (df == nil) {
        [Toast makeToast:NSLocalizedString(@"设备信息读取中，请稍后",nil)];
        return NO;
    }
    
    if ([df batLevel] < 30) {
        [Toast makeToast:NSLocalizedString(@"电池电量低于30%，请连接充电器。",nil)];
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
    }else if ([model isEqualToString:@"I6C2"]){
        return @36;
    }else if ([model isEqualToString:@"S2"]){
        return @101;
    }
    return @0;
}

- (NSNumber *)deviceTypeNumber {
    NSString *model = [self.deviceInfo model];
    //1->手环 ，2->体重秤 ,3->手表
    if ([model isEqualToString:@"F1"] || [model isEqualToString:@"P1J"]) {
        return @3;
    }else {
        return @1; //默认手环
    }
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
    NSLog(@"执行固件下载函数: %@",fileURL);
    [self deleteFW];
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
            NSLog(@"固件下载完成");
            return YES;
        }
    } else {
        NSLog(@"固件已存在");
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
    
    NSNumber *appVersion = @(1000);
    NSNumber *deviceType = @1; //1->手环 ，2->体重秤 ,3->手表
    RequestFirmwareUpdateApi *rfuApi = [[RequestFirmwareUpdateApi alloc] initWithDevicePlatform:@(platform) andDeviceType:deviceType andDeviceModel:modelNum andFirmwareVersion:deviceVersion andApp:3 andAppVersion:appVersion];
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

#pragma mark- BTNotify
- (void)setEpoParamsIfNeed {
    
    CBPeripheral *p = [[BLEShareInstance shareInstance] getConnectedPeriphral];

    CBCharacteristic *wCh = nil;
    CBCharacteristic *rCh = nil;
    for (CBService *s in p.services) {
        if (![s.UUID isEqual:[CBUUID UUIDWithString:PEDOMETER_WATCH_SERVICE_UUID]]) {
            continue;
        }
        for (CBCharacteristic *c in s.characteristics) {
            if ([c.UUID isEqual:[CBUUID UUIDWithString:kDOGPWriteCharUUIDString]]) {
                wCh = c;
            }else if ([c.UUID isEqual:[CBUUID UUIDWithString:kDOGPReadCharUUIDString]]) {
                rCh = c;
            }
        }
    }
    if (!wCh && !rCh) {
        return;
    }
    [[BtNotify sharedInstance] setGattParameters:p writeCharacteristic:wCh readCharacteristic:rCh];
    [[BtNotify sharedInstance] updateConnectionState:CBPeripheralStateConnected];
}

- (void)setState:(kBLEstate)state{
    if (state == kBLEstateDidConnected) {
        [[BtNotify sharedInstance] updateConnectionState:CBPeripheralStateConnected];
    }else {
        [[BtNotify sharedInstance] updateConnectionState:CBPeripheralStateDisconnected];
    }
}
#pragma mark- BTNotifyDelegate
-(void)onReadyToSend:(BOOL)ready {
    NSLog(@"%s:%d",__func__,ready);
}

-(void)onDataArrival:(NSString *)receiver arrivalData:(NSData *)data {
    NSString *dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%s:%@ data: %@ - String: %@",__func__,receiver,data,dataStr);
    if ([dataStr isEqualToString:@"epo_download"]) {
        [[FUHandle handle] epoUpdateStart];
    }
}

-(void)onProgress:(NSString *)sender
      newProgress:(float)progress {
    NSLog(@"%s:%@ : %f",__func__,sender,progress);
}

- (void)responseOfMTKBtNotifyData:(CBCharacteristic *)cbc {
    NSError *error = nil;
    [[BtNotify sharedInstance] handleReadReceivedData:cbc error:error];
    NSLog(@"%s:%@ \nERROR:%@",__func__,cbc,error);
}

- (void)responseOfMTKBtWriteData:(CBCharacteristic *)cbc {
    NSError *error = nil;
    [[BtNotify sharedInstance] handleWriteResponse:cbc error:error];
    NSLog(@"%s:%@ \nERROR:%@",__func__,cbc,error);
}

#pragma mark -EPO
static NSString *const kDOGPReadCharUUIDString = @"00002aa0-0000-1000-8000-00805f9b34fb";
static NSString *const kDOGPWriteCharUUIDString = @"00002aa1-0000-1000-8000-00805f9b34fb";

- (dispatch_queue_t)bleQueue {
    static dispatch_queue_t _bleQueue = nil;
    if (_bleQueue == nil) {
        _bleQueue = dispatch_queue_create("ble-central-mtk-epo-queue", 0);}
    return _bleQueue;}
static int DATA_LEN = 1024;
#define EPO_URL [NSURL URLWithString:@"http://api6.iwown.com/epo_download/EPO_GPS_3_1.DAT"]
#define EPO_PATH [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"EPO_GPS_3_1.dat"]
#define EPO_PATH_TMP [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"EPO_GPS_3_1_tmp.dat"]
#define EPO_DATE @"EPO_DATE_MARK"
- (void)epoUpdateStart {
    if (![self downlaodEpoFile]) {
        return;
    }
    dispatch_async([self bleQueue], ^{
        
        NSString* pathEpo = EPO_PATH;
        NSData* dataEpo = [[NSData alloc] initWithContentsOfFile:pathEpo];
        
        int datatemplength = (int)dataEpo.length;
        int packageLength = datatemplength/DATA_LEN + (datatemplength%DATA_LEN>0?1:0);
        NSString *str = [NSString stringWithFormat:@"%d",packageLength];
        NSData *dataInt = [str dataUsingEncoding:NSUTF8StringEncoding];
        
        int responeBegan = [[BtNotify sharedInstance] send:@"epo_update_data" receiver:@"epo_update_data" dataAction:0 dataToSend:dataInt needProgress:YES sendPriority:PRIORITY_NORMAL];
        if (responeBegan > 0) {
            NSLog(@"ERROR: send start epo_update_data: %d %d-%@-%@",responeBegan,datatemplength,str,dataInt);
            return;
        }
        [NSThread sleepForTimeInterval:0.8];

        int cicleNum = 0;
        for (int i =0; i<dataEpo.length; i += DATA_LEN) {
            
            NSRange range = NSMakeRange(i, DATA_LEN);
            if (i + DATA_LEN > dataEpo.length) {
                range = NSMakeRange(i, dataEpo.length - i);
            }
            NSData *subData = [dataEpo subdataWithRange:range];
            int respone = [[BtNotify sharedInstance] send:@"epo_update_data" receiver:@"epo_update_data" dataAction:1 dataToSend:subData needProgress:YES sendPriority:PRIORITY_NORMAL];
            if (respone > 0) {
                NSLog(@"ERROR: send epo_update_data :%d count:%d cicleNum:%d",respone,i,++cicleNum);
                return;
            }
            NSLog(@"send epo_update_data :%d count:%d cicleNum:%d",respone,i,++cicleNum);
            [NSThread sleepForTimeInterval:0.08];
        }
        [NSThread sleepForTimeInterval:0.8];
        
        int responeEnd = [[BtNotify sharedInstance] send:@"epo_update_data" receiver:@"epo_update_data" dataAction:2 dataToSend:[@"end" dataUsingEncoding:NSUTF8StringEncoding] needProgress:YES sendPriority:PRIORITY_NORMAL];
        if (responeEnd > 0) {
            NSLog(@"ERROR: send end epo_update_data: %d ",responeEnd);
            return;
        }
        NSLog(@"send end epo_update_data: %d",responeEnd);
        [NSThread sleepForTimeInterval:3];
        NSString *md5Data = [BKUtils getFileMD5WithPath:pathEpo];
        int response = [[BtNotify sharedInstance] send:@"epo_update_md5" receiver:@"epo_update_md5" dataAction:1 dataToSend:[md5Data dataUsingEncoding:NSUTF8StringEncoding] needProgress:YES sendPriority:PRIORITY_NORMAL];
        if (response > 0) {
            NSLog(@"ERROR: send epo_update_md5: %d ",response);
            return;
        }
        NSLog(@"send epo_update_md5: %d ",response);
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:EPO_DATE];
    });
}

- (BOOL)downlaodEpoFile {
    NSDate *epoDate = [[NSUserDefaults standardUserDefaults] objectForKey:EPO_DATE];
    NSDate *theDate = [NSDate date];
    
    if ([theDate timeIntervalSinceDate:epoDate] < 24 * 3600) { //24小时 内不重复下载升级文件
        return NO;
    }
    
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfURL:EPO_URL options:NSDataReadingMappedIfSafe error:&error];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createFileAtPath:EPO_PATH_TMP contents:data attributes:nil];
    if (error || data.length == 0) {
        NSLog(@"epo download failure : %@",error);
        return NO;
    }
    
    if (![fileManager fileExistsAtPath:EPO_PATH]) {
        [fileManager moveItemAtPath:EPO_PATH_TMP toPath:EPO_PATH error:&error];
        if (error) {
            return NO;
        }
    }else { //存在，比较md5
        NSString *md5Epo = [BKUtils getFileMD5WithPath:EPO_PATH];
        NSString *md5EpoTmp = [BKUtils getFileMD5WithPath:EPO_PATH_TMP];
        if (epoDate && [md5Epo isEqualToString:md5EpoTmp]) { //epoDate 存在表示上一次升级成功
            return NO; //same file ,needn't update
        }
        [fileManager removeItemAtPath:EPO_PATH error:nil];
        [fileManager moveItemAtPath:EPO_PATH_TMP toPath:EPO_PATH error:&error];
        if (error) {
            return NO;
        }
    }
    return YES;
}
@end

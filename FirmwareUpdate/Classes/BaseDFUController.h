//
//  BaseDFUController.h
//  ZLYIwown
//
//  Created by caike on 16/8/31.
//  Copyright © 2016年 Iwown. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,DFUDevice){
    DFUDevice_null = 0,
    DFUDevice_Bracelet = 1,
    DFUDevice_ScaleS2 = 2,
};

typedef NS_ENUM(NSInteger,DFUState){
    DFUState_Null = 0,
    DFUState_Return = 1,
    DFUState_DownLoadFial = 2,
    DFUState_Retry = 3,
    DFUState_Waiting = 4,
    DFUState_Helper = 5,
    DFUState_SaveInfo = 6,
    DFUState_Start = 7
};

@class DeviceInfo;
@interface BaseDFUController : UIViewController
{
    UIButton            *_udBtn;
    
    NSString            *_fwUrl;
    NSString            *_fwModel;
}
@property (nonatomic,assign)DFUState            state;
/**
 * 保存为校验成功时的输出,然后作为准备工作（保存DFU信息）时的输入
 * saved info when got reponse from  requestForCheckDFU: ,as input data when  prepareDFUUpgrade
 */
@property (nonatomic,strong)NSDictionary        *fwContent;

- (void)initUI;

#pragma mark 公共method
- (void)requestForCheckDFU:(DFUDevice)device; //校验
- (void)prepareDFUUpgrade;  //准备工作，（保存dfu信息）
- (void)downloadFirmware:(void(^)(void))downloadFWSuccessful; //下载固件

- (void)returnBtnClicked:(id)sender;
- (void)udBtnClicked:(id)sender;
- (void)toastDisplay:(id)string;
- (id)getStateParams:(NSString *)text
         andDFUState:(DFUState)state;
- (void)finallySuccessful;
- (BOOL)dfuFileIsExist:(NSString *)model;
- (BOOL)downFWFromURL:(NSString *)fileURL andFilePath:(NSString *)filePath ;
- (BOOL)deleteBootloader;
#pragma mark 更新UI
- (void)entryUpgradeView;
- (void)prepareNoUpdateView;
- (void)prepareUpgradeView;
- (void)updateCheckDFU;
- (void)updateUIDownloadFail;
- (void)updateUIDownloadSuccessful;
- (void)updateUINoData;
- (void)updateUIDownload;
- (void)updateUIPercent:(NSInteger)percentage;
- (void)updateUIReady;
- (void)updateUIFail;
- (void)updateUIUnKnowError;
- (void)updateUINoNeed;
- (void)updateUIWaiting;
- (void)updateUISaveInfo;
- (void)updateUIAferComplete;
- (void)newCompleteAnimationView;
- (void)updateUIState:(id)stateInfo;
- (void)updateTipsContent:(NSString *)tips;

- (void)signOffDelegate;

@end

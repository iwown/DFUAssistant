//
//  DUViewController.h
//  FirmwareUpdate
//
//  Created by 曹凯 on 2016/11/7.
//  Copyright © 2016年 west. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Defines.h"
#import "ParamaterStorage.h"
#import "SUOTAServiceManager.h"

@interface DUViewController : UIViewController<UIAlertViewDelegate> {
    int step, nextStep;
    int expectedValue;
    
    int chunkSize;
    int blockStartByte;
    
    ParamaterStorage *storage;
    SUOTAServiceManager *manager;
    NSMutableData *fileData;
    NSTimer *autoscrollTimer;
}

@property char memoryType;
@property int memoryBank;
@property UInt16 blockSize;

@property int i2cAddress;
@property char i2cSDAAddress;
@property char i2cSCLAddress;

@property char spiMOSIAddress;
@property char spiMISOAddress;
@property char spiCSAddress;
@property char spiSCKAddress;

- (NSString*) getErrorMessage:(SPOTA_STATUS_VALUES)status;

@end

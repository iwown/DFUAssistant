//
//  AlertService.h
//  FMP_Proj
//
//  Created by ken on 14-7-7.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "IAlert.h"
#import "DefaultAlert.h"
#import "MTKBleManager.h"


//00001802-0000-1000-8000-00805F9B34FB Immediate Alert Service uuid
extern NSString *kAlertServiceUUIDString;

//00002A06-0000-1000-8000-00805F9B34FB
extern NSString *kAlertLevelCharacteristicUUIDString;

typedef enum{
    kAlertHighLevel=2,
    kAlertMediumLevel=1,
    kAlertNoLevel=0,
}AlertLevel;

@interface AlertService : NSObject{
    DefaultAlert *defaultAlert;
}

+ (id) sharedInstance: (CBPeripheralManager *)peripheralManager;
- (void) initService;
- (void) alertFunc: (int8_t)value;
- (void) stopAlert;
//-(void)removeService;

@property (nonatomic) CBMutableCharacteristic  *myCharacteristic;
@end

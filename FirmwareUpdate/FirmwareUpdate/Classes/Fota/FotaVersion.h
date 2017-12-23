//
//  FotaVersion.h
//  MTKBleManager
//
//  Created by user on 14/11/10.
//  Copyright (c) 2014年 ___MTK___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FotaVersion : NSObject

@property NSString*     version;
@property NSString*     releaseNote;
@property NSString*     module;
@property NSString*     platform;
@property NSString*     deviceId;
@property NSString*     brand;
@property NSString*     domain;
@property NSString*     downloadKey;
@property NSString*     pinCode;
@property BOOL          isLowBattery;

@end

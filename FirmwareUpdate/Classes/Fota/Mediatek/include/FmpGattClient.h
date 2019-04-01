//
//  FmpGattClient.h
//  MTKBleManager
//
//  Created by user on 15-2-11.
//  Copyright (c) 2015年 ___MTK___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLEClientProfile.h"

@interface FmpGattClient : BLEClientProfile

+(id)getInstance;

- (BOOL)findTarget: (int)level;

@end

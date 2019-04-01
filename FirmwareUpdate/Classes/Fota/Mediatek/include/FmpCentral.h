//
//  FmpCentral.h
//  FMP_Proj
//
//  Created by ken on 14-7-10.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

__attribute__((deprecated("use the class FmpGattClient instead")))
@interface FmpCentral : NSObject

-(id)initWithPeripheral:(CBPeripheral *)periheral alertLevel: alertLevelCharactistic;
-(BOOL)findTarget:(int)level;
@property (nonatomic,readwrite) Boolean isReadyFind;

@end

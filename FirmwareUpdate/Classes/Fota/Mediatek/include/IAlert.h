//
//  IAlert.h
//  FMP_Proj
//
//  Created by betty on 14-7-7.
//  Copyright (c) 2014年 ken. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import<AudioToolbox/AudioToolbox.h>

@interface IAlert : NSObject

-(Boolean) alert:(int) level;
-(Boolean) uninit;
-(Boolean) isPlay;
-(void) stopAlert;

@end

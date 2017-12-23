//
//  DeviceStorage.h
//  SmartTags
//
//  Created by Martijn Houtman on 13/01/14.
//  Copyright (c) 2014 Martijn Houtman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "GenericServiceManager.h"
#import <UIKit/UIKit.h>

extern NSString * const DeviceStorageUpdated;

@interface DeviceStorage : NSObject

+ (DeviceStorage*) sharedInstance;
- (id) init;

- (CBPeripheral*) deviceForIndex: (int) index;
- (GenericServiceManager*) deviceManagerForIndex: (int)index;
- (GenericServiceManager*) deviceManagerWithIdentifier:(NSString*)identifier;
- (int) indexOfDevice:(CBPeripheral*) device;
- (int) indexOfIdentifier:(NSString*) identifier;

- (void) unpairDevice:(GenericServiceManager*)device;
- (void) load;
- (void) save;

@property (strong) NSMutableArray *devices;

@end

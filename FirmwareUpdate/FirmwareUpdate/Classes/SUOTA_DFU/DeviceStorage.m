    //
//  DeviceStorage.m
//  SmartTags
//
//  Created by Martijn Houtman on 13/01/14.
//  Copyright (c) 2014 Martijn Houtman. All rights reserved.
//

#import "DeviceStorage.h"
#import "BluetoothManager.h"

NSString * const DeviceStorageUpdated = @"DeviceStorageUpdated";

@implementation DeviceStorage

static DeviceStorage* sharedDeviceStorage = nil;

+ (DeviceStorage*) sharedInstance {
    if (sharedDeviceStorage == nil) {
        sharedDeviceStorage = [[DeviceStorage alloc] init];
    }
    return sharedDeviceStorage;
}

- (id) init {
    if (self = [super init]) {
        self.devices = [[NSMutableArray alloc] init];
                
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveDevices:)
                                                     name:BluetoothManagerReceiveDevices
                                                   object:nil];
    }
    return self;
}

- (void) receiveDevices:(NSNotification *) notification {
    [self.devices removeAllObjects];
    
    for (CBPeripheral *device in [notification object]) {
        GenericServiceManager *dm = [self deviceManagerWithIdentifier:[device.identifier UUIDString]];
        dm.device = device;
        
        if (!dm) {
            dm = [[GenericServiceManager alloc] initWithDevice:device andManager:[BluetoothManager getInstance]];
            [self.devices addObject:dm];
        }
        
        if (dm.autoconnect)
            [dm connect];
        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DeviceStorageUpdated object:self];
}

#pragma mark - Storage

- (CBPeripheral*) deviceForIndex: (int)index {
    GenericServiceManager *deviceManager = [self.devices objectAtIndex:index];
    return deviceManager.device;
}

- (GenericServiceManager*) deviceManagerForIndex: (int)index {
    GenericServiceManager *deviceManager = [self.devices objectAtIndex:index];
    return deviceManager;
}

- (GenericServiceManager*) deviceManagerWithIdentifier:(NSString*)identifier {
    for (GenericServiceManager *device in self.devices) {
        if ([device.identifier isEqualToString:identifier]) {
            return device;
        }
    }
    return nil;
}

- (int) indexOfDevice:(CBPeripheral*) device {
    for (int n=0; n < [self.devices count]; n++) {
        CBPeripheral *p = [self deviceForIndex:n];
        if (p == device)
            return n;
    }
    return -1;
}

- (int) indexOfIdentifier:(NSString*) identifier {
    for (int n=0; n < [self.devices count]; n++) {
        GenericServiceManager *p = [self deviceManagerForIndex:n];
        if ([p.identifier isEqualToString:identifier])
            return n;
    }
    return -1;
}

- (void) unpairDevice:(GenericServiceManager*)device {
    int index = [self indexOfIdentifier:device.identifier];
    [self.devices removeObjectAtIndex:index];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:DeviceStorageUpdated object:self];
}

- (void) load {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *devices = [defaults objectForKey:@"deviceList"];
    
    self.devices = [[NSMutableArray alloc] init];
    for (NSData *encodedDevice in devices) {
        [self.devices addObject:(GenericServiceManager*) [NSKeyedUnarchiver unarchiveObjectWithData:encodedDevice]];
    }
    
    NSLog(@"Retrieved devices.");    
    [[NSNotificationCenter defaultCenter] postNotificationName:DeviceStorageUpdated object:self];
}

- (void) save {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableArray *deviceList = [[NSMutableArray alloc] init];
    for (GenericServiceManager *device in self.devices) {
        NSData *encodedDevice = [NSKeyedArchiver archivedDataWithRootObject:device];
        [deviceList addObject:encodedDevice];
    }
    
    [defaults setObject:deviceList forKey:@"deviceList"];
    [defaults synchronize];
}

@end

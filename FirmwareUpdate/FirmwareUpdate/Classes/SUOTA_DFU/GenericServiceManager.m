//
//  GenericServiceManager.m
//  SmartExite
//
//  Created by Martijn Houtman on 9/30/13.
//  Copyright (c) 2013 Martijn Houtman. All rights reserved.
//

#import "GenericServiceManager.h"
#import "BluetoothManager.h"
#import "Defines.h"

NSString * const GenericServiceManagerDidReceiveValue         = @"GenericServiceManagerDidReceiveValue";
NSString * const GenericServiceManagerDidSendValue            = @"GenericServiceManagerDidSendValue";

static GenericServiceManager *instance;
static NSMutableDictionary *instances;

@implementation GenericServiceManager

@synthesize device, deviceName;

+ (id)getInstanceForDevice:(CBPeripheral *)device {
    NSString *identifier = [NSString stringWithFormat:@"%@", device.identifier];
    
    if ([instances valueForKey:identifier] != nil) {
        return [instances valueForKey:identifier];
    }
    
    return nil;
}

+ (void) destroyInstanceForDevice:(CBPeripheral *)device {
    NSString *identifier = [NSString stringWithFormat:@"%@", device.identifier];
    
    if ([instances valueForKey:identifier] != nil) {
        return [instances removeObjectForKey:identifier];
    }
}

- (id) initWithDevice:(CBPeripheral*) _device {
    return [self initWithDevice:_device andManager:[BluetoothManager getInstance]];
}

- (id) initWithDevice:(CBPeripheral*) _device andManager:(BluetoothManager *)_manager {
    self = [super init];
    if (self) {
        manager = _manager;
        device = _device;
        [device setDelegate:self];
        instance = self;
        
        self.deviceName = self.device.name;
        
        rssiTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateRSSI) userInfo:nil repeats:YES];
        
        if (!instances)
            instances = [[NSMutableDictionary alloc] init];
        
        NSString *identifier = [NSString stringWithFormat:@"%@", device.identifier];
        [instances setObject:self forKey:identifier];
    }
    return self;
}

- (void) setDevice:(CBPeripheral *)_device {
    device = _device;
    [rssiTimer invalidate];
    rssiTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateRSSI) userInfo:nil repeats:YES];
}

- (void) updateRSSI {
    if (self.device.state == CBPeripheralStateConnected)
        [self.device readRSSI];
}

- (void) peripheralDidUpdateRSSI:(CBPeripheral *)peripheral error:(NSError *)error {
    self.RSSI = [peripheral.RSSI doubleValue];
    [self.delegate didUpdateData:self.device];
}

- (void) discoverServices {
    [device setDelegate:self];
    [device discoverServices:nil];
}

- (void) peripheral:(CBPeripheral *)_peripheral didDiscoverServices:(NSError *)error {
    NSArray *services = [_peripheral services];
    
    for (CBService *service in services) {
        NSLog(@"Services %@ (%@)", [service UUID], service);
        [device discoverCharacteristics:nil forService:service];
    }
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    NSLog(@"Characteristics for service %@ (%@)", [service UUID], service);
    NSArray *characteristics = [service characteristics];
    for (CBCharacteristic *characteristic in characteristics) {
        NSLog(@" -- Characteristic %@ (%@)", [characteristic UUID], characteristic);
        
        switch ([self CBUUIDToInt:characteristic.UUID]) {
            case ORG_BLUETOOTH_CHARACTERISTIC_MANUFACTURER_NAME_STRING:
            case ORG_BLUETOOTH_CHARACTERISTIC_MODEL_NUMBER_STRING:
            case ORG_BLUETOOTH_CHARACTERISTIC_FIRMWARE_REVISION_STRING:
            case ORG_BLUETOOTH_CHARACTERISTIC_SOFTWARE_REVISION_STRING:
                [self readValue:service.UUID characteristicUUID:characteristic.UUID p:peripheral];
                break;
                
        }
    }
    
    [self.delegate deviceReady:self.device];
}

- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"Value for %@ is %@", [characteristic UUID], [characteristic value]);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GenericServiceManagerDidReceiveValue object:characteristic];
}

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    NSLog(@"Data written: %@", error);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:GenericServiceManagerDidSendValue object:characteristic];
}

- (void) connect {
    self.autoconnect = TRUE;
    [manager connectToDevice:self.device];
}

- (void) disconnect {
    [rssiTimer invalidate];
    self.autoconnect = FALSE;
    [manager disconnectDevice];
}

- (NSString *) deviceName {
    if (!deviceName)
        return self.device.name;
    return deviceName;
}

- (id) initWithCoder:(NSCoder *) decoder {
    if (self = [super init]) {
        NSLog(@"Name: %@", [decoder decodeObjectForKey:@"identifier"]);
        self.identifier = [decoder decodeObjectForKey:@"identifier"];
        self.deviceName = [decoder decodeObjectForKey:@"deviceName"];
        self.autoconnect = [decoder decodeBoolForKey:@"autoconnect"];
        
        manager = [BluetoothManager getInstance];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*) encoder {
    [encoder encodeObject:self.identifier forKey:@"identifier"];
    [encoder encodeObject:self.deviceName forKey:@"deviceName"];
    [encoder encodeBool:self.autoconnect forKey:@"autoconnect"];
}

/*- (NSString*) getDeviceName {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *dict = [defaults objectForKey:self.identifier];
    if ([dict objectForKey:@"device_name"]) {
        return [dict objectForKey:@"device_name"];
    }
    return self.device.name;
}*/

/*!
 *  @method writeValue:
 *
 *  @param serviceUUID Service UUID to write to (e.g. 0x2400)
 *  @param characteristicUUID Characteristic UUID to write to (e.g. 0x2401)
 *  @param data Data to write to peripheral
 *  @param p CBPeripheral to write to
 *
 *  @discussion Main routine for writeValue request, writes without feedback. It converts integer into
 *  CBUUID's used by CoreBluetooth. It then searches through the peripherals services to find a
 *  suitable service, it then checks that there is a suitable characteristic on this service.
 *  If this is found, value is written. If not nothing is done.
 *
 */

- (void) writeValue:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data andResponseType:(CBCharacteristicWriteType)responseType
{
    CBService *service = [self findServiceFromUUID:serviceUUID p:p];
    if (!service) {
        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@\r\n",[self CBUUIDToString:serviceUUID], p.identifier);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    if (!characteristic) {
        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@\r\n",[self CBUUIDToString:characteristicUUID],[self CBUUIDToString:serviceUUID], p.identifier);
        return;
    }
    [p writeValue:data forCharacteristic:characteristic type:responseType];
}

- (void) writeValue:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data {
    [self writeValue:serviceUUID characteristicUUID:characteristicUUID p:p data:data andResponseType:CBCharacteristicWriteWithResponse];
}

- (void) writeValueWithoutResponse:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID p:(CBPeripheral *)p data:(NSData *)data {
    [self writeValue:serviceUUID characteristicUUID:characteristicUUID p:p data:data andResponseType:CBCharacteristicWriteWithoutResponse];
}

- (void) readValue: (CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID p:(CBPeripheral *)p {
    CBService *service = [self findServiceFromUUID:serviceUUID p:p];
    if (!service) {
        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@\r\n",[self CBUUIDToString:serviceUUID], p.identifier);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    if (!characteristic) {
        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@\r\n",[self CBUUIDToString:characteristicUUID],[self CBUUIDToString:serviceUUID], p.identifier);
        return;
    }
    [p readValueForCharacteristic:characteristic];
}

- (void) notification:(CBUUID*)serviceUUID characteristicUUID:(CBUUID*)characteristicUUID p:(CBPeripheral *)p on:(BOOL)on {
    CBService *service = [self findServiceFromUUID:serviceUUID p:p];
    if (!service) {
        NSLog(@"Could not find service with UUID %s on peripheral with UUID %@\r\n",[self CBUUIDToString:serviceUUID], p.identifier);
        return;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:characteristicUUID service:service];
    if (!characteristic) {
        NSLog(@"Could not find characteristic with UUID %s on service with UUID %s on peripheral with UUID %@\r\n",[self CBUUIDToString:characteristicUUID],[self CBUUIDToString:serviceUUID], p.identifier);
        return;
    }
    [p setNotifyValue:on forCharacteristic:characteristic];
}

/*
 *  @method CBUUIDToString
 *
 *  @param UUID UUID to convert to string
 *
 *  @returns Pointer to a character buffer containing UUID in string representation
 *
 *  @discussion CBUUIDToString converts the data of a CBUUID class to a character pointer for easy printout using printf()
 *
 */
-(const char *) CBUUIDToString:(CBUUID *) UUID {
    return [[UUID.data description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy];
}


/*
 *  @method UUIDToString
 *
 *  @param UUID UUID to convert to string
 *
 *  @returns Pointer to a character buffer containing UUID in string representation
 *
 *  @discussion UUIDToString converts the data of a CFUUIDRef class to a character pointer for easy printout using printf()
 *
 */
-(const char *) UUIDToString:(CFUUIDRef)UUID {
    if (!UUID) return "NULL";
    CFStringRef s = CFUUIDCreateString(NULL, UUID);
    return CFStringGetCStringPtr(s, 0);
    
}

/*
 *  @method compareCBUUID
 *
 *  @param UUID1 UUID 1 to compare
 *  @param UUID2 UUID 2 to compare
 *
 *  @returns 1 (equal) 0 (not equal)
 *
 *  @discussion compareCBUUID compares two CBUUID's to each other and returns 1 if they are equal and 0 if they are not
 *
 */

-(int) compareCBUUID:(CBUUID *) UUID1 UUID2:(CBUUID *)UUID2 {
    char b1[16];
    char b2[16];
    [UUID1.data getBytes:b1];
    [UUID2.data getBytes:b2];
    if (memcmp(b1, b2, UUID1.data.length) == 0)return 1;
    else return 0;
}

/*
 *  @method compareCBUUIDToInt
 *
 *  @param UUID1 UUID 1 to compare
 *  @param UUID2 UInt16 UUID 2 to compare
 *
 *  @returns 1 (equal) 0 (not equal)
 *
 *  @discussion compareCBUUIDToInt compares a CBUUID to a UInt16 representation of a UUID and returns 1
 *  if they are equal and 0 if they are not
 *
 */
-(int) compareCBUUIDToInt:(CBUUID *)UUID1 UUID2:(UInt16)UUID2 {
    char b1[16];
    [UUID1.data getBytes:b1];
    UInt16 b2 = [BluetoothManager swap:UUID2];
    if (memcmp(b1, (char *)&b2, 2) == 0) return 1;
    else return 0;
}
/*
 *  @method CBUUIDToInt
 *
 *  @param UUID1 UUID 1 to convert
 *
 *  @returns UInt16 representation of the CBUUID
 *
 *  @discussion CBUUIDToInt converts a CBUUID to a Uint16 representation of the UUID
 *
 */
-(UInt16) CBUUIDToInt:(CBUUID *) UUID {
    char b1[16];
    [UUID.data getBytes:b1];
    return ((b1[0] << 8) | b1[1]);
}

/*
 *  @method IntToCBUUID
 *
 *  @param UInt16 representation of a UUID
 *
 *  @return The converted CBUUID
 *
 *  @discussion IntToCBUUID converts a UInt16 UUID to a CBUUID
 *
 */
-(CBUUID *) IntToCBUUID:(UInt16)UUID {
    /*char t[16];
    t[0] = ((UUID >> 8) & 0xff); t[1] = (UUID & 0xff);
    NSData *data = [[NSData alloc] initWithBytes:t length:16];
    return [CBUUID UUIDWithData:data];
    */
    UInt16 cz = [BluetoothManager swap:UUID];
    NSData *cdz = [[NSData alloc] initWithBytes:(char *)&cz length:2];
    CBUUID *cuz = [CBUUID UUIDWithData:cdz];
    return cuz;
}


- (CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p {
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([self compareCBUUID:s.UUID UUID2:UUID]) return s;
    }
    return nil; //Service not found on this peripheral
}

/*
 *  @method findCharacteristicFromUUID:
 *
 *  @param UUID CBUUID to find in Characteristic list of service
 *  @param service Pointer to CBService to search for charateristics on
 *
 *  @return pointer to CBCharacteristic if found, nil if not
 *
 *  @discussion findCharacteristicFromUUID searches through the characteristic list of a given service
 *  to find a characteristic with a specific UUID
 *
 */
-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service {
    for(int i=0; i < service.characteristics.count; i++) {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([self compareCBUUID:c.UUID UUID2:UUID]) return c;
    }
    return nil; //Characteristic not found on this service
}

@end


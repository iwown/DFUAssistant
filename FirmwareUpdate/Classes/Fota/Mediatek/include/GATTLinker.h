//
//  GATTLinker.h
//  MTKBleManager
//
//  Created by user on 11/7/14.
//  Copyright (c) 2014 ___MTK___. All rights reserved.
//

#import "Linker.h"
#import "MTKBleManager.h"

extern NSString *kDOGPServiceUUIDString;
extern NSString *kDOGPReadCharUUIDString;
extern NSString *kDOGPWriteCharUUIDString;

const static int STATE_READ_NONE = 0;
const static int STATE_READ_WAIT_FOR_RESPONSE = 1;
const static int STATE_READ_NEED_TO_READ = 2;

@protocol LinkerListenerProtocol <NSObject>

- (void)onDataArrived: (NSData *)data;
- (void)onDataSent: (float)percent Tag: (NSString *)sessionTag;
- (void)onConnectionStateChange: (int)newState;

@end

@interface GATTLinker : Linker

+ (id) initGattLinkerInstance: (CBPeripheral *)peripheral readChar: (CBCharacteristic *)readCh writeChar: (CBCharacteristic *)writeCh;
+ (id) getGattLinkerInstance;

-(void)close;

- (void) write: (NSData *)data;

-(void)readNextDataValue;

-(void)writeDataDirectly:(NSData*)data;

- (void) changeDataBuffer: (int)SessionDataSize;

//for MTKBleManager
- (void) onReadCharacteristicCallBack: (CBCharacteristic *)ch error: (NSError *)er;
- (void) onWriteCharacteristicCallBack: (CBCharacteristic *)ch error: (NSError *)er;

-(void)onConnectionStateChange:(int)newState;

-(BOOL)isConnected;
-(BOOL)isHandShakeDone;

-(void)setHandShakeDone:(BOOL)done;

@property (nonatomic) id<LinkerListenerProtocol> mLinkerListener;

@end

//
//  SPC_GattLinker.h
//  BtNotify
//
//  Created by user on 2017/2/20.
//  Copyright © 2017年 Mediatek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BtNotify.h"

@protocol SPC_LinkerDelegate <NSObject>

@optional

-(void)onDataSent;

@end


@interface SPC_GattLinker : NSObject

+(id)GLSharedInstance;

-(void)setGattParameters:(CBPeripheral *)peripheral
     writeCharacteristic:(CBCharacteristic *)writeChar
      readCharacteristic:(CBCharacteristic *)readChar;

-(void)deinit;

-(void)write:(NSData *)data;

-(BOOL)getIsWriting;

-(void)handleWriteCallback:(CBCharacteristic *)ch error:(NSError *)err;

-(void)handleReadCallback:(CBCharacteristic *)ch error:(NSError *)err;

-(void)registerLinkerDelegate:(id<SPC_LinkerDelegate>)delegate;

-(void)unregisterLinkerDelegate:(id<SPC_LinkerDelegate>)delegate;

-(int)getSendMaxSize;

-(void)updateConnectionState:(int)newState;

-(void)setRemoteVersion:(int)version;

@property (nonatomic, readonly, getter=getIsStarted)BOOL isStarted;

@property (nonatomic, readonly, getter=getIsWriting)BOOL isWriting;

@property (nonatomic, readonly, getter=getInited)BOOL inited;

@property (nonatomic, getter=getHandshakeDone, setter=setHandshakeDone:)BOOL handshakeDone;

@end

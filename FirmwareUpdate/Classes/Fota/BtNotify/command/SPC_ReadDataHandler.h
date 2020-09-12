//
//  SPC_ReadDataHandler.h
//  BtNotify
//
//  Created by user on 2017/2/23.
//  Copyright © 2017年 Mediatek. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SPC_ReadDataHandlerDelegate <NSObject>

@optional
-(void)onDataReceived:(int)type handledData:(NSData *)data;
-(void)onHandshakeDone:(BOOL)done;
-(void)onRequestToSend:(NSData *)sendData;
-(void)onRemoteVersionReceived:(int)version;

@end

@interface SPC_ReadDataHandler : NSObject

+(id)rdhSharedInstance;

-(void)deinit;

-(void)reset;

-(void)processReceivedData:(NSData *)data;

-(void)setDelegate:(id<SPC_ReadDataHandlerDelegate>)delegate;

@end

//
//  SPC_Session.h
//  BtNotify
//
//  Created by user on 2017/2/20.
//  Copyright © 2017年 Mediatek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPC_Session : NSObject

/*
-(id)initSession:(NSString *)tag
    needResponse:(BOOL)response
    needProgress:(BOOL)pro
    sendPriority:(int)pri;
*/

-(id)initSession:(NSString *)tag
    needProgress:(BOOL)pro
    sendPriority:(int)pri;

-(void)deinit;

-(void)setSendData:(NSData *)cmdHeader dataToSend:(NSData *)dataBuf;

-(NSString *)getTag;

-(NSData *)getSendData:(int)maxLength;

-(void)updateSentSize:(unsigned long)lastSentSize;

-(float)getSendProgress;

-(int)getPriority;

-(BOOL)getNeedProgress;

//-(BOOL)getNeedResponse;

@end

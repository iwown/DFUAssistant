//
//  SPC_CommandUtils.h
//  BtNotify
//
//  Created by user on 2017/3/1.
//  Copyright © 2017年 Mediatek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPC_UtilData : NSObject

@property NSString  *sender;
@property NSString  *receiver;
@property int       dataType;
@property int       dataLen;
@property NSData    *data;

@end

@interface SPC_CommandUtils : NSObject

+(NSData *)getCmdBuffer:(int)cmdType command:(NSString *)cmd;

+(SPC_UtilData *)parseData:(NSData *)data;

/*
+(NSString *)getReceiverTag:(NSData *)data;

+(NSData *)getCustomData:(NSData *)oriData;
*/

@end

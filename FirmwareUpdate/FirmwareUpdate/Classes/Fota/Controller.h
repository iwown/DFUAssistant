//
//  Controller.h
//  MTKBleManager
//
//  Created by user on 11/6/14.
//  Copyright (c) 2014 ___MTK___. All rights reserved.
//

#import <Foundation/Foundation.h>

const static int PRIORITY_NORMAL = 0;
const static int PRIORITY_LOW = 1;
const static int PRIORITY_HIGH = 2;

@interface Controller : NSObject

- (id) init: (NSString *)tag cmdtype: (int)cmdtype;

- (void)send: (NSString *)cmd data: (NSData *)dataBuffer response: (BOOL)re progress: (BOOL)pr priority: (int)priority;

- (void)onReceive:(NSData*)data;

- (void)onProgress: (float)sentPercent;

- (void)onConnectStateChange: (int)state;

- (void)onHandShakeDone;
/**
 *    get receiver tags of the controller
 *
 *    @return array which contains NSString *
 */
- (NSArray *)getReceiverTags;

/**
 *    set receiver tag of the controller
 *
 *    @param tagStrArray the array which contains tha receiver tag string
 */
- (void)setReceiversTags: (NSArray *)tagStrArray;

-(NSString*)getControllerTag;

-(void)cancelCurrentSending;

@end

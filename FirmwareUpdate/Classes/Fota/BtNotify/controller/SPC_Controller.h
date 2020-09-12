//
//  Controller.h
//  BtNotify
//
//  Created by user on 2017/2/20.
//  Copyright © 2017年 Mediatek. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SPC_Controller : NSObject

-(id)init:(NSString *)tag;

-(void)deinit;

-(void)send:(NSString *)sender
   receiver:(NSString *)receiver
     action:(int)action
 dataToSend:(NSData *)data
needProgress:(BOOL)needPro
   priority:(int)pri;

-(void)cancelCurrentSending;

-(void)onDataArrival:(NSData *)dataBuf;

-(void)onReadyToSend;

-(void)onProgress:(float)sendProgress;

-(NSString *)getControllerTag;

-(void)setReceiversTags:(NSArray *)tags;

-(NSArray *)getReceiverTags;

@end

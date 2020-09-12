//
//  SPC_ControllerManager.h
//  BtNotify
//
//  Created by user on 2017/2/20.
//  Copyright © 2017年 Mediatek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPC_Controller.h"

@interface SPC_ControllerManager : NSObject

+(id)CMSharedInstance;

-(void)deinit;

-(int)addController:(SPC_Controller *)addCh;

-(int)removeController:(SPC_Controller *)rmCh;

-(void)removeAllControllers;

-(void)updateHandshakeDone:(BOOL)done;

//-(BOOL)checkReceiverExist:(NSString *)receiver;

-(BOOL)handleReceivedData:(NSString *)receiver handledData:(NSData *)data;

-(void)handleProgressUpdate:(NSString *)tag progress:(float)pro;

@end

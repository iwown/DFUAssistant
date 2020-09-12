//
//  SPC_FotaController.h
//  MTKBleManager
//
//  Created by user on 14/11/17.
//  Copyright (c) 2014年 ___MTK___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPC_Controller.h"

@protocol SPC_FotaControllerDelegate <NSObject>

-(void)onReceive:(NSData*)data;
-(void)onProgress: (float)sentPercent;
-(void)onReadyToSend;

@end

@interface SPC_FotaController : SPC_Controller

+(id)sharedInstance;

-(void)setControllerDelegate:(id<SPC_FotaControllerDelegate>)delegate;

@end

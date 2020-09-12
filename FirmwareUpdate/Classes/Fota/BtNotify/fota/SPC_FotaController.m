//
//  SPC_FotaController.m
//  MTKBleManager
//
//  Created by user on 14/11/17.
//  Copyright (c) 2014年 ___MTK___. All rights reserved.
//

#import "SPC_FotaController.h"

NSString * const SPC_TAG_FOTA_CONTROLLER = @"[FOTA][SPC_FotaController]";

@interface SPC_FotaController()
{
    @private
        id<SPC_FotaControllerDelegate> controllerDelegate;
}
@end


@implementation SPC_FotaController

static SPC_FotaController *sInstance;

+(id)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"[SPC_FotaController] [sharedInstance] +++");
        sInstance = [[super alloc] init:SPC_TAG_FOTA_CONTROLLER];
    });
    return sInstance;
}

-(void)deinit {
    controllerDelegate = nil;
    [super deinit];
    sInstance = nil;
}

-(void)setControllerDelegate:(id<SPC_FotaControllerDelegate>)delegate {
    if (delegate != nil) {
        controllerDelegate = delegate;
    }
}

-(void)onDataArrival:(NSData*)data {
//    NSLog(@"[SPC_FotaController][onReceive] ++++");
    if (data == nil || data.length == 0) {
        NSLog(@"[SPC_FotaController][onReceive] data is WRONG");
        return;
    }
    
    NSString* str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    if (str == nil || str.length == 0) {
        NSLog(@"[SPC_FotaController][onReceive] str is nil or length is 0");
        return;
    }
    
    NSArray* array = [str componentsSeparatedByString:@" "];
    if (array == nil || [array count] == 0) {
        NSLog(@"[SPC_FotaController][onReceive] array is WRONG");
        return;
    }
    
    [controllerDelegate onReceive:data];
}

-(void)onProgress: (float)sentPercent {
//    NSLog(@"[SPC_FotaController][onProgress] percent = %.02f", sentPercent);
    [controllerDelegate onProgress: sentPercent];
}

-(void)onReadyToSend {
    [controllerDelegate onReadyToSend];
}

@end

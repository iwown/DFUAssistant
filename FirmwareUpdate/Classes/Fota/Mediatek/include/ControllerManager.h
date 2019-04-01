//
// ControllerManager.h
// MTKBleManager
//
// Created by user on 11/9/14.
// Copyright (c) 2014 ___MTK___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Controller.h"

@interface ControllerManager : NSObject

+ (id)getControllerManagerInstance;
- (void)onReceive: (int)cmdType data: (NSData *)data;
- (void)addController:(Controller*)controller;
- (void)removeController:(Controller*)controller;
- (void)removeAllControllers;
- (void)onProgress: (float)sentPercent;
- (void)onConnectStateChange: (int)state;

@end

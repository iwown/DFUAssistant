//
//  SPC_SessionManager.h
//  BtNotify
//
//  Created by user on 2017/2/20.
//  Copyright © 2017年 Mediatek. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPC_Session.h"
#import "SPC_GattLinker.h"

@protocol SPC_SessionDelegate <NSObject>

@optional
-(void)onProgressUpdate:(NSString *)tag progress:(float)pro;

@end

@interface SPC_SessionManager : NSObject <SPC_LinkerDelegate>

+(id)SMSharedInstance:(SPC_GattLinker *)linker;

+(id)sharedInstance;

-(void)deinit;

-(void)addSession:(SPC_Session *)addSession;

-(void)removeSessionWithTag:(NSString *)tagToRemove;

-(void)removeAllSessions;

-(void)handleDisconnected;

-(void)setSessionDelegate:(id<SPC_SessionDelegate>)delegate;

@end

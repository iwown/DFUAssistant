//
//  Controller.m
//  BtNotify
//
//  Created by user on 2017/2/20.
//  Copyright © 2017年 Mediatek. All rights reserved.
//

#import "SPC_Controller.h"
#import "SPC_Session.h"
#import "SPC_SessionManager.h"
#import "SPC_Command.h"
#import "SPC_LogUtils.h"
#import "SPC_ControllerManager.h"
#import "SPC_CommandUtils.h"

@interface SPC_Controller() {
    
    int                     mCmdType;
    NSString                *mControllerTag;
    NSMutableSet            *mReceiverTags;
}

@end



@implementation SPC_Controller

-(id)init:(NSString *)tag {
    self = [super init];
    if (self != nil) {
        mCmdType = 9;
        mControllerTag = tag;
        mReceiverTags = [[NSMutableSet alloc] init];

        /*NSString *str = @"we had";
        unsigned char* keyChars = (unsigned char*)[str UTF8String];
        SPC_setKey(keyChars, (int)strlen((char *)keyChars));*/
    }
    return self;
}

-(void)deinit {
    [mReceiverTags removeAllObjects];
    mReceiverTags = nil;
}

-(void)send:(NSString *)sender
   receiver:(NSString *)receiver
     action:(int)action
 dataToSend:(NSData *)data
needProgress:(BOOL)needPro
   priority:(int)pri {

    if (mCmdType < 1 || mCmdType > 9) {
        LOG_E(mControllerTag, @"Wrong command type", nil);
        return;
    }
    SPC_Session *session = [[SPC_Session alloc] initSession:mControllerTag
                                       needProgress:needPro
                                       sendPriority:pri];

    NSData *cmdData = nil;
    NSString *cmd = [NSString stringWithFormat:@"%@ %@ %d %d %lu ", sender, receiver, action, 0, (unsigned long)[data length]];
    
    cmdData = [SPC_CommandUtils getCmdBuffer:mCmdType command:cmd];//[self getCmdBuffer:mCmdType command:cmd];
    
    [session setSendData:cmdData dataToSend:data];

    [[SPC_SessionManager sharedInstance] addSession:session];
}

-(void)cancelCurrentSending {
    [[SPC_SessionManager sharedInstance] removeSessionWithTag:mControllerTag];
}

-(void)onDataArrival:(NSData *)dataBuf {
    
}

-(void)onReadyToSend {
    
}

-(void)onProgress:(float)sendProgress {
    
}

-(NSString *)getControllerTag {
    return mControllerTag;
}

-(void)setReceiversTags:(NSArray *)tags {
    [mReceiverTags addObjectsFromArray:tags];
}

-(NSArray *)getReceiverTags {
    return [mReceiverTags allObjects];
}
/*
//private action
- (NSData *) getCmdBuffer: (int)cmdType command: (NSString *)cmd {
    LOG_D(mControllerTag, @"cmdtype = %d, cmd = %@", cmdType, cmd);
    
    int retLen = 0;
    int *pRetLen = &retLen;
    unsigned char* cmdChar = (unsigned char*)[cmd UTF8String];
    
    unsigned char *result = SPC_getDatacmd(cmdType, cmdChar, pRetLen);
    LOG_D(mControllerTag, @"retLen = %d", retLen);
    if (result != nil) {
        return [NSData dataWithBytes: result length: retLen];//need to improve
    }
    
    return nil;
}
*/

@end

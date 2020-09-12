//
//  SPC_Session.m
//  BtNotify
//
//  Created by user on 2017/2/20.
//  Copyright © 2017年 Mediatek. All rights reserved.
//

#import "SPC_Session.h"
#import "SPC_LogUtils.h"

@interface SPC_Session() {
    
    @private
    NSString                *mTag;
    //BOOL                    mNeedResponse;
    BOOL                    mNeedProgress;
    int                     mPriority;
    
    NSMutableData           *mSendBuf;
    unsigned long           mSentSize;
    unsigned long           mTotalSize;
}

@end

const NSString *S_LOG_TAG = @"SPC_Session";

@implementation SPC_Session

/*
-(id)initSession:(NSString *)tag
    needResponse:(BOOL)response
    needProgress:(BOOL)pro
    sendPriority:(int)pri {
*/
-(id)initSession:(NSString *)tag needProgress:(BOOL)pro sendPriority:(int)pri {
    self = [super init];
    mTag = tag;
    mNeedProgress = pro;
    //mNeedResponse = response;
    mPriority = pri;
    
    mSendBuf = [[NSMutableData alloc] init];
    mSentSize = 0;
    mTotalSize = 0;
    
    return self;
}

-(void)deinit {
    [mSendBuf replaceBytesInRange:NSMakeRange(0, [mSendBuf length]) withBytes:nil length:0];
    mSendBuf = nil;
    
    mTag = nil;
}

-(void)setSendData:(NSData *)cmdHeader dataToSend:(NSData *)dataBuf {
    if ((dataBuf == nil
        || [dataBuf length] == 0)
        && (cmdHeader == nil
            || [cmdHeader length] == 0)) {
            LOG_E(S_LOG_TAG, @"No data to send", nil);
        return;
    }
    
    if (cmdHeader != nil && [cmdHeader length] != 0) {
        [mSendBuf appendData:cmdHeader];
    }
    if (dataBuf != nil && [dataBuf length] != 0) {
        [mSendBuf appendData:dataBuf];
    }
    mTotalSize = [mSendBuf length];
    
    LOG_D(S_LOG_TAG, @"Send buf length : %lu", (unsigned long)[mSendBuf length], nil);
}

-(NSData *)getSendData:(int)maxLength {
    LOG_D(S_LOG_TAG, @"maxLength : %d, sendbulength : %lu", maxLength, (unsigned long)[mSendBuf length], nil);
    if ([mSendBuf length] == 0) {
        return nil;
    } else {
        unsigned long sendLen = 0;
        if ([mSendBuf length] > maxLength) {
            sendLen = maxLength;
        } else {
            sendLen = [mSendBuf length];
        }
        LOG_D(S_LOG_TAG, @"sendLen : %lu", sendLen, nil);
        NSData *data = [mSendBuf subdataWithRange:NSMakeRange(0, sendLen)];
        [mSendBuf replaceBytesInRange:NSMakeRange(0, sendLen) withBytes:nil length:0];
        return data;
    }
}

-(void)updateSentSize:(unsigned long)lastSentSize {
    mSentSize += lastSentSize;
}

-(float)getSendProgress {
    return (float)mSentSize / (float)mTotalSize;
}

-(NSString *)getTag {
    return mTag;
}

-(int)getPriority {
    return mPriority;
}

-(BOOL)getNeedProgress {
    return mNeedProgress;
}

/*
-(BOOL)getNeedResponse {
    return mNeedResponse;
}
*/

@end

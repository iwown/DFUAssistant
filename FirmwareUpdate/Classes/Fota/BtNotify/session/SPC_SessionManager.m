//
//  SPC_SessionManager.m
//  BtNotify
//
//  Created by user on 2017/2/20.
//  Copyright © 2017年 Mediatek. All rights reserved.
//

#import "SPC_SessionManager.h"
#import "SPC_LogUtils.h"


const NSString *SM_LOG_TAG = @"SPC_SessionManager";
static SPC_SessionManager *sInstance;

@interface SPC_SessionManager() {
    
    @private
    NSMutableArray              *mSessionList;
    NSThread                    *mSessionThread;
    BOOL                        mToStop;
    NSLock                      *mLock;
    SPC_GattLinker                  *mLinker;
    SPC_Session                     *mCurRunningSession;
    //BtNotify                    *mNotify;
    //SPC_ControllerManager           *mCMManager;
    dispatch_semaphore_t        mSendSemaphore;
    dispatch_semaphore_t        mSessionAddSemaphore;
    BOOL                        mSessionWait;
    unsigned int                mLastSendSize;
    
    id<SPC_SessionDelegate>         mSessionDelegate;

}

@end


@implementation SPC_SessionManager


+(id)SMSharedInstance:(SPC_GattLinker *)linker {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        LOG_I(SM_LOG_TAG, @"Start to init SPC_SessionManager", nil);
        sInstance = [[SPC_SessionManager alloc]init];
        [sInstance initialize:linker];
    });
    return sInstance;
}

+(id)sharedInstance {
    return sInstance;
}


-(void)initialize:(SPC_GattLinker *)linker {
    mSessionList = [[NSMutableArray alloc] init];
    mLock = [[NSLock alloc] init];
    mLinker = linker;

    [mLinker registerLinkerDelegate:self];
    mToStop = YES;
    mCurRunningSession = nil;
    mSendSemaphore = dispatch_semaphore_create(0);
    mSessionAddSemaphore = dispatch_semaphore_create(0);
    mLastSendSize = 0;
    mSessionWait = NO;
}

-(void)deinit {
    [self removeAllSessions];
    [mLinker unregisterLinkerDelegate:self];
    mLinker = nil;
    mToStop = YES;
    sInstance = nil;
    mCurRunningSession = nil;
    mLock = nil;
    mSessionWait = NO;
}

-(void)addSession:(SPC_Session *)addSession {
    if (addSession == nil) {
        LOG_E(SM_LOG_TAG, @"SPC_Session to add is nil", nil);
        return;
    }
    
    [mLock lock];
    
    if ([addSession getPriority] == SPC_PRIORITY_HIGH) {
        if ([mSessionList count] > 0) {
            [mSessionList insertObject:addSession atIndex:1];
        } else {
            [mSessionList addObject:addSession];
        }
    } else {
        [mSessionList addObject:addSession];
    }
    
    [mLock unlock];
    
    LOG_D(SM_LOG_TAG, @"SPC_Session Count : %lu", (unsigned long)[mSessionList count], nil);

    if ([mSessionList count] != 0 && mSessionThread == nil) {
        mSessionThread = [[NSThread alloc] initWithTarget:self selector:@selector(sessionThreadFireFunc) object:nil];
        mToStop = NO;
        [mSessionThread setQualityOfService:NSQualityOfServiceUserInitiated];
        [mSessionThread start];
        LOG_I(SM_LOG_TAG, @"Start SPC_Session thread", nil);
    } else {
        if ([mSessionList count] == 1 && mSessionThread != nil
                && mSessionWait == YES) {
            dispatch_semaphore_signal(mSessionAddSemaphore);
        }
    }
}

-(void)removeSessionWithTag:(NSString *)tagToRemove {

    if (tagToRemove == nil || [tagToRemove length] == 0) {
        return;
    }
    NSMutableArray *deleteSessionList = [[NSMutableArray alloc] init];
    
    [mLock lock];
    
    for (SPC_Session *session in mSessionList) {
        if ([[session getTag] isEqualToString:tagToRemove]) {
            [deleteSessionList addObject:session];
        }
    }

    LOG_D(SM_LOG_TAG, @"Before remove %lu", (unsigned long)[mSessionList count], nil);
    LOG_D(SM_LOG_TAG, @"Remove ^^%@^^ SPC_Session count (%lu)", tagToRemove, (unsigned long)[deleteSessionList count], nil);
    for (SPC_Session *ss in deleteSessionList) {
        [ss deinit];
        [mSessionList removeObject:ss];
    }
    
    [mLock unlock];
    
    [deleteSessionList removeAllObjects];

    LOG_I(SM_LOG_TAG, @"After remove %lu", (unsigned long)[mSessionList count], nil);
}

-(void)removeAllSessions {
    LOG_I(SM_LOG_TAG, @"Remove all SPC_Sessions", nil);
    
    [mLock lock];
    
    for (SPC_Session *ss in mSessionList) {
        [ss deinit];
    }

    [mSessionList removeAllObjects];
    [mLock unlock];
}

-(void)removeSession:(SPC_Session *)session {

    [mLock lock];
    if ([mSessionList containsObject:session] == YES) {
        [session deinit];
        [mSessionList removeObject:session];
    }
    [mLock unlock];
}

-(void)handleDisconnected {
    [self removeAllSessions];
    dispatch_semaphore_signal(mSendSemaphore);
    if (mSessionWait == YES) {
        dispatch_semaphore_signal(mSessionAddSemaphore);
    }
    mToStop = YES;
}

-(void)setSessionDelegate:(id<SPC_SessionDelegate>)delegate {
    mSessionDelegate = delegate;
}

#pragma mark - SPC_GattLinker delegate callback
-(void)onDataSent {
    if (mCurRunningSession != nil) {
        dispatch_semaphore_signal(mSendSemaphore);
    }
}

-(SPC_Session *)getWorkingSession {
    if ([mSessionList count] != 0) {
        return [mSessionList objectAtIndex:0];
    }
    return nil;
}

#pragma mark - SPC_Session Thread Fire Function
-(void)sessionThreadFireFunc {
    LOG_I(SM_LOG_TAG, @"Start to run SPC_Session thread fire func", nil);
    while (mToStop == NO) {
        
        if ([mLinker getHandshakeDone] == NO) {
            mToStop = YES;
            [self removeAllSessions];
            break;
        }

        mCurRunningSession = [self getWorkingSession];
        if (mCurRunningSession == nil) {
            //[NSThread sleepForTimeInterval:0.5];
            mSessionWait = YES;
            dispatch_semaphore_wait(mSessionAddSemaphore, DISPATCH_TIME_FOREVER);
            continue;
        }
        
        mSessionWait = NO;
        
        LOG_D(SM_LOG_TAG, @"Start to send ^^%@^^ SPC_Session", [mCurRunningSession getTag], nil);

        NSData *sendData = [mCurRunningSession getSendData:[mLinker getSendMaxSize]];

        while (sendData != nil) {
            float pro = 0;
            mLastSendSize = (unsigned int)[sendData length];
            LOG_D(SM_LOG_TAG, @"Sent size : %d", mLastSendSize, nil);

//            while ([mLinker getIsWriting] == YES) {
//                [NSThread sleepForTimeInterval:0.05];
//            }
            LOG_D(SM_LOG_TAG, @"Start to write", nil);
            [mLinker write:sendData];
            LOG_D(SM_LOG_TAG, @"After write finished", nil);

            dispatch_semaphore_wait(mSendSemaphore, DISPATCH_TIME_FOREVER);
            LOG_D(SM_LOG_TAG, @"After write response", nil);

            [mCurRunningSession updateSentSize:[sendData length]];

            if ([mLinker getHandshakeDone] == NO) {
                mToStop = YES;
                [self removeAllSessions];
                break;
            }
            if ([mCurRunningSession getNeedProgress] == YES) {
                pro = [mCurRunningSession getSendProgress];
                if (mSessionDelegate != nil
                    && [mSessionDelegate respondsToSelector:@selector(onProgressUpdate:progress:)] == YES) {
                    [mSessionDelegate onProgressUpdate:[mCurRunningSession getTag] progress:pro];
                }
            }
            sendData = [mCurRunningSession getSendData:[mLinker getSendMaxSize]];
        }

        LOG_D(SM_LOG_TAG, @"SPC_Session ^^%@^^ send finished", [mCurRunningSession getTag], nil);
        
        [self removeSession:mCurRunningSession];
        mCurRunningSession = nil;
        mLastSendSize = 0;
    }
    
    [mSessionThread cancel];
    mSessionThread = nil;
}

@end

//
//  SPC_ControllerManager.m
//  BtNotify
//
//  Created by user on 2017/2/20.
//  Copyright © 2017年 Mediatek. All rights reserved.
//

#import "SPC_ControllerManager.h"
#import "SPC_LogUtils.h"
#import "BtNotify.h"
#import "SPC_SessionManager.h"
#import "SPC_CommandUtils.h"

@interface SPC_ControllerManager() {
    
    NSMutableArray      *mControllerArry;
    NSLock              *mLock;
    
}

@end

static SPC_ControllerManager   *sInstance;

const NSString *CM_LOG_TAG = @"SPC_ControllerManager";

@implementation SPC_ControllerManager

+(id)CMSharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        LOG_I(CM_LOG_TAG, @"Start to init SPC_ControllerManager", nil);
        sInstance = [[SPC_ControllerManager alloc] init];
        [sInstance initialize];
    });
    return sInstance;
}

-(void)initialize {
    mControllerArry = [[NSMutableArray alloc] init];
    mLock = [[NSLock alloc] init];
}

-(SPC_Controller *)getController:(NSString *)tag {

    [mLock lock];
    for (SPC_Controller *cc in mControllerArry) {
        if ([[cc getControllerTag] isEqualToString:tag] == YES) {
            [mLock unlock];
            return cc;
        }
    }
    [mLock unlock];
    return nil;
}


-(void)deinit {
    LOG_I(CM_LOG_TAG, @"Deinit SPC_ControllerManager", nil);
    [mControllerArry removeAllObjects];
    mControllerArry = nil;
    mLock = nil;
    sInstance = nil;
}

-(int)addController:(SPC_Controller *)addCh {
    if (addCh == nil) {
        LOG_E(CM_LOG_TAG, @"Controller is nil to add", nil);
        return SPC_ERROR_CODE_WRONG_PARAMETER;
    }
    
    [mLock lock];
    if ([mControllerArry containsObject:addCh] == YES) {
        LOG_E(CM_LOG_TAG, @"Controller already added", nil);
        return -2;
    }
    for (SPC_Controller *con in mControllerArry) {
        if ([[con getControllerTag] isEqualToString:[addCh getControllerTag]] == YES) {
            LOG_E(CM_LOG_TAG, @"Controller tag already existed", nil);
            return -3;
        }
    }
    
    [mControllerArry addObject:addCh];
    [mLock unlock];
    
    return SPC_ERROR_CODE_OK;
}

-(int)removeController:(SPC_Controller *)rmCh {
    if (rmCh == nil) {
        LOG_E(CM_LOG_TAG, @"Controller is nil to remove", nil);
        return SPC_ERROR_CODE_WRONG_PARAMETER;
    }
    
    [mLock lock];
    if ([mControllerArry containsObject:rmCh] == NO) {
        LOG_E(CM_LOG_TAG, @"Controller not exist - (%@)", [rmCh getControllerTag], nil);
        return -4;
    }
    [mControllerArry removeObject:rmCh];
    [mLock unlock];
    return SPC_ERROR_CODE_OK;
}

-(void)removeAllControllers {
    LOG_I(CM_LOG_TAG, @"Remove all controllers", nil);
    [mLock lock];
    [mControllerArry removeAllObjects];
    [mLock unlock];
}

-(void)updateHandshakeDone:(BOOL)done {
    if (done == YES) {
        for (SPC_Controller *c in mControllerArry) {
            [c onReadyToSend];
        }
    }
}
/*
-(BOOL)checkReceiverExist:(NSString *)receiver {
    for (Controller *c in mControllerArry) {
        NSArray *revTags = [c getReceiverTags];
        if (revTags != nil && [revTags containsObject:receiver] == YES) {
            return true;
        }
    }
    return false;
}*/

-(BOOL)handleReceivedData:(NSString *)receiver handledData:(NSData *)data {
    //NSString *receiver = [SPC_CommandUtils getReceiverTag:data];//[self getReceiverTag:data];
    LOG_D(CM_LOG_TAG, @"Received receiver : %@", receiver, nil);
    if (receiver == nil || [receiver isEqualToString:@""] == YES) {
        LOG_E(CM_LOG_TAG, @"Receiver is nil or empty", nil);
        return false;
    }
    BOOL exist = false;
    for (SPC_Controller *c in mControllerArry) {
        NSArray *revTags = [c getReceiverTags];
        if (revTags != nil && [revTags containsObject:receiver] == YES) {
            [c onDataArrival:data];
            exist = true;
        }
    }
    if (exist == true) {
        return true;
    }
    return false;
}

-(void)handleProgressUpdate:(NSString *)tag progress:(float)pro {
    if (tag == nil || [tag isEqualToString:@""] == YES) {
        LOG_E(CM_LOG_TAG, @"Tag is nul", nil);
        return;
    }
    SPC_Controller *cc = [self getController:tag];
    LOG_D(CM_LOG_TAG, @"cc is %@", [cc getControllerTag], nil);
    if (cc == nil) {
        LOG_E(CM_LOG_TAG, @"Failed to get Controller", nil);
        return;
    }
    [cc onProgress:pro];
}
/*
-(NSString *)getReceiverTag: (NSData *)data {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (str == nil || [str length] == 0) {
        LOG_E(CM_LOG_TAG, @"Return data is Wrong (data is empty)", nil);
        return nil;
    }
    NSArray *arr = [str componentsSeparatedByString:@" "];
    if (arr == nil || [arr count] < 4) {
        LOG_E(CM_LOG_TAG, @"Components is Wrong (length %lu)", (unsigned long)[arr count], nil);
        return nil;
    }
    return [arr objectAtIndex:1];
    

    //at least 4 spaces
    Byte *dataBytes = (Byte *)[data bytes];
    
    int totalSpace = 0;
    int secondSpace = 0;
    
    for (int i = 0; i < [data length]; i++) {
        
        if (dataBytes[i] == 0x20) {
            totalSpace ++;
            
            if (totalSpace == 2) {
                secondSpace = i;
            }
            
            if (totalSpace == 4) {
                break;
            }
        }
    }
    
    if (totalSpace < 4) {
        LOG_E(CM_LOG_TAG, @"Wrong format (Space count < 4)", nil);
        return nil;
    }
    
    LOG_D(CM_LOG_TAG, @"SecondSpace = %d,totalspce = %d, datalength = %lu", secondSpace, totalSpace, (unsigned long)[data length]);
    
    NSData *subData = [data subdataWithRange: NSMakeRange(0, secondSpace)];
    
    NSString *subString = [[NSString alloc] initWithData: subData encoding: NSUTF8StringEncoding];
    
    NSArray *subArray = [subString componentsSeparatedByString: @" "];
    
    if ([subArray count] >= 2) {
        return subArray[1];
    }
    
    return nil;

}
*/
@end

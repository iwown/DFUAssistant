//
//  SPC_CommandUtils.m
//  BtNotify
//
//  Created by user on 2017/3/1.
//  Copyright © 2017年 Mediatek. All rights reserved.
//

#import "SPC_CommandUtils.h"
#import "SPC_Command.h"
#import "SPC_LogUtils.h"

@implementation SPC_UtilData


@end

@implementation SPC_CommandUtils

+(NSData *)getCmdBuffer:(int)cmdType command:(NSString *)cmd {
    LOG_D(@"SPC_CommandUtils", @"cmdtype = %d, cmd = %@", cmdType, cmd);
    
    int retLen = 0;
    int *pRetLen = &retLen;
    unsigned char* cmdChar = (unsigned char*)[cmd UTF8String];
    
    unsigned char *result = SPC_getDatacmd(cmdType, cmdChar, pRetLen);
    LOG_D(@"SPC_CommandUtils", @"retLen = %d", retLen);
    if (result != nil) {
        return [NSData dataWithBytes: result length: retLen];
    }
    
    return nil;
}

+(SPC_UtilData *)parseData:(NSData *)data {
    SPC_UtilData        *retData = NULL;
    Byte            *bytes = (Byte *)[data bytes];
    int             state = 0;
    int             index = 0;
    int             length = 0;
    int             last = 0;
    NSData          *tt;
    NSString        *temp;
    
    retData = [[SPC_UtilData alloc] init];
    
    for (index = 0; index < [data length]; index ++) {
        if (bytes[index] != 0x20 || state == 4) {
            length ++;
        } else {
            state ++;
            if (last == 0) {
                tt = [data subdataWithRange:NSMakeRange(last, length)];
            } else {
                tt = [data subdataWithRange:NSMakeRange(last + 1, length)];
            }
            length = 0;
            last = index;
            temp = [[NSString alloc] initWithData:tt encoding:NSUTF8StringEncoding];
            if (state == 1) {
                retData.sender = temp;
            } else if (state == 2) {
                retData.receiver = temp;
            } else if (state == 3) {
                retData.dataType = [temp intValue];
            } else if (state == 4) {
                retData.dataLen = [temp intValue];
            }
        }
    }
    
    retData.data = [data subdataWithRange:NSMakeRange(last + 1, length)];
    LOG_D(@"SPC_CommandUtils", @"Parsed data (%@, %@, %d, %lu)", retData.sender, retData.receiver,
          retData.dataLen, (unsigned long)[retData.data length]);
    
    return retData;
}

/*
+(NSString *)getReceiverTag:(NSData *)data {

    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (str == nil || [str length] == 0) {
        LOG_E(@"SPC_CommandUtils", @"Return data is Wrong (data is empty)", nil);
        return nil;
    }
    NSArray *arr = [str componentsSeparatedByString:@" "];
    if (arr == nil || [arr count] < 4) {
        LOG_E(@"SPC_CommandUtils", @"Components is Wrong (length %lu)", (unsigned long)[arr count], nil);
        return nil;
    }
    return [arr objectAtIndex:1];

}


+(NSData *)getCustomData:(NSData *)oriData {
    Byte *bytes = (Byte *)[oriData bytes];
    int forthSpaceIndex = 0;
    int index = 0;
    int count = 0;
    for (index = 0; index < [oriData length]; index++) {
        if (bytes[index] == 0x20) {
            count ++;
        }
        if (count == 4) {
            forthSpaceIndex = index;
            break;
        }
    }
    NSString *str = [[NSString alloc] initWithData:oriData encoding:NSUTF8StringEncoding];
    NSArray *arr = [str componentsSeparatedByString:@" "];
    NSString *ll = [arr objectAtIndex:3];
    int length = [ll intValue];
    LOG_D(@"SPC_CommandUtils", @"length = %d - %lu", length, (unsigned long)([oriData length] - forthSpaceIndex - 1));
    NSData *retData = [oriData subdataWithRange:NSMakeRange(forthSpaceIndex + 1, length)];
    return retData;
    
}
*/

@end

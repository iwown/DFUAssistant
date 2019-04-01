//
//  Linker.h
//  MTKBleManager
//
//  Created by user on 11/6/14.
//  Copyright (c) 2014 ___MTK___. All rights reserved.
//

#import <Foundation/Foundation.h>

const static int LINKER_IDLE = 0;
const static int LINKER_WRITING = 1;

const static int STATE_NONE = 0;
const static int STATE_LISTEN = 1;
const static int STATE_CONNECTING = 2;
const static int STATE_CONNECTED = 3;
const static int STATE_CONNECT_FAIL = 4;
const static int STATE_CONNECT_LOST = 5;
const static int STATE_DISCONNECTING = 6;

@interface Linker : NSObject

- (void) setSentSize: (int)sentSize Tag: (NSString *)tag;
- (void) changeDataBuffer: (int)SessionDataSize;
- (void) write: (NSData *)data;

@end

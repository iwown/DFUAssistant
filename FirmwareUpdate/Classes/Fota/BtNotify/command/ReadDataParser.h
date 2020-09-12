//
//  ReadDataParser.h
//  MTKBleManager
//
//  Created by user on 11/8/14.
//  Copyright (c) 2014 ___MTK___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReadDataParser : NSObject

+ (id) initReadDataParser;

-(void)deinit;

- (void) syncReadData: (NSData *)data;

@end

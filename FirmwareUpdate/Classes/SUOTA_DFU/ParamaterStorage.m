//
//  ParamaterStorage.m
//  SUOTA
//
//  Created by Martijn Houtman on 03/10/14.
//  Copyright (c) 2014 Martijn Houtman. All rights reserved.
//

#import "ParamaterStorage.h"

@implementation ParamaterStorage

static ParamaterStorage* sharedParameterStorage = nil;

+ (ParamaterStorage*) getInstance {
    if (sharedParameterStorage == nil) {
        sharedParameterStorage = [[ParamaterStorage alloc] init];
    }
    return sharedParameterStorage;
}

- (id) init {
    if (self = [super init]) {
    }
    return self;
}

@end

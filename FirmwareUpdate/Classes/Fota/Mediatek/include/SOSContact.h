//
//  SOSContact.h
//  MTKBleManager
//
//  Created by user on 15-1-28.
//  Copyright (c) 2015年 ___MTK___. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOSContact : NSObject <NSCoding>

@property (nonatomic) NSString *name;
@property (nonatomic) NSString *number;

- (BOOL)isEqual:(SOSContact *)object;

@end

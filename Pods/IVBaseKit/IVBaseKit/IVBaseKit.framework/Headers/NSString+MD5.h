//
//  NSString+MD5.h
//  ZLYIwown
//
//  Created by CY on 2017/4/20.
//  Copyright © 2017年 Iwown. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MD5)
+ (NSString *)MD5ByAStr:(NSString *)aSourceStr;
- (NSString *)MD5;
@end

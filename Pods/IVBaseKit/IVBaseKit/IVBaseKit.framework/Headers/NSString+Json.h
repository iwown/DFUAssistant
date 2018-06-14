//
//  NSString+Json.h
//  ZLV3
//
//  Created by Jackie on 15/7/10.
//  Copyright (c) 2015年 Jackie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Json)

+(NSString *) jsonStringWithArray:(NSArray *)array;
+(NSString *) jsonStringWithDictionary:(NSDictionary *)dictionary;
+(NSString *) jsonStringWithString:(NSString *) string;
+(NSString *) jsonStringWithObject:(id) object;
- (id)jsonToObject ;
@end

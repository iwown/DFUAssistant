//
//  NSString+Util.h
//  ZLYIwown
//
//  Created by 曹凯 on 16/4/28.
//  Copyright © 2016年 Iwown. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Util)

- (NSString *)escapeHTML;
- (NSString *)deleteHTMLTag;
- (BOOL)stringContainsSubString:(NSString *)subStr;
- (BOOL)judgeForStrIsEqualToNull ;
- (NSString *)changeToUTF8String ;

- (int)countWordLenth;


@end

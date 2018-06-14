//
//  UIColor+Util.h
//  Linyi
//
//  Created by caike on 16/11/18.
//  Copyright © 2016年 iwown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Util)
+ (UIColor *)colorWithHex:(int)hexValue alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHex:(int)hexValue;
+ (UIColor *)colorWithRGBAHex:(int)hexValue;
+ (UIColor *)colorFromCode:(int)hexCode inAlpha:(float)alpha;
@end

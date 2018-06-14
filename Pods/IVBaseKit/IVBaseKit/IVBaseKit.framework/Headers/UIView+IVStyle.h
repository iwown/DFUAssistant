//
//  UIView+IVStyle.h
//  ZLYIwown
//
//  Created by 曹凯 on 16/5/13.
//  Copyright © 2016年 Iwown. All rights reserved.
//

typedef enum{
    IVNavigationBarStyleNone = 0,
    IVNavigationBarStyleBlueSky ,
    IVNavigationBarStyleLiveGreen ,
}IVNavigationBarStyle;

#import <UIKit/UIKit.h>

@interface UIView (IVStyle)


/**
 画导航栏

 @param lefticon image name in "XXX_nor|XXX_down"
 @param ivStyle IVNavigationBarStyle
 */
+ (UIView *) drawMenuBarTitle:(NSString *)title delegate:(UIViewController *)vc leftIcon:(NSString *)lefticon leftText:(NSString *)lefttext leftAction:(SEL)leftAction rightIcon:(NSString *)righticon rightText:(NSString *)righttext rightAction:(SEL)rightAction andBgStyle:(IVNavigationBarStyle)ivStyle;

+ (UIView *)drawMenuBarTitle:(NSString *)title delegate:(UIViewController *)vc leftIcon:(NSString *)lefticon leftText:(NSString *)lefttext leftAction:(SEL)leftAction rightIcon:(NSString *)righticon rightText:(NSString *)righttext rightAction:(SEL)rightAction;

- (void)resetMenuTitle:(NSString *)title;

+ (UILabel *)labelWithFrame:(CGRect)frame withTitle:(NSString *)title titleFontSize:(UIFont *)font textColor:(UIColor *)color backgroundColor:(UIColor *)bgColor alignment:(NSTextAlignment)textAlignment;
@end

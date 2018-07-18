//
//  YSProgressView.h
//  12.25.YSSlider
//
//  Created by Color on 15/12/25.
//  Copyright © 2015年 com.moon-box. All rights reserved.
//
//  说明：1、frame 高度被限制 5~100
//       2、进度条progressValue 最大为 YSProgressView的宽度
//
//



#import <UIKit/UIKit.h>

@interface YSProgressView : UIView

/**
 *  进度条高度  height: 5~100
 */
@property (nonatomic) CGFloat progressHeight;

/**
 *  进度值  maxValue:  <= YSProgressView.width
 */
@property (nonatomic) CGFloat progressValue;

/**
 *   动态进度条颜色  Dynamic progress
 */
@property (nonatomic, strong) UIColor *trackTintColor;
/**
 *  静态背景颜色    static progress
 */
@property (nonatomic, strong) UIColor *progressTintColor;

- (void)updateProgress:(CGFloat)p color:(UIColor *)color;
@end

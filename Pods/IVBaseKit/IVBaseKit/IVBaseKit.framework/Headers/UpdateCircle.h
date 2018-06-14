//
//  UpdateCircle.h
//  ZLingyi
//
//  Created by Jackie on 15/1/15.
//  Copyright (c) 2015年 Jackie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UpdateCircle : UIView

@property (nonatomic, assign) CGFloat percent;
@property (nonatomic, strong) UIColor *coverColor;
@property (nonatomic, strong) UIColor *baseColor;

- (id)initWithFrame:(CGRect)frame baseColor:(UIColor *)baseColor coverColor:(UIColor *)coverColor withPercent:(CGFloat)per;
- (void) updateProgress:(CGFloat)per color:(UIColor *)color;


- (void)startAnimation;
- (void)stopAnimation;
@end

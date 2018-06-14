//
//  DFUAlertView.h
//  ZLYIwown
//
//  Created by caike on 16/10/18.
//  Copyright © 2016年 Iwown. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DFUAlertView : UIView
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UILabel *contentLabel;
@property (nonatomic,strong)UILabel *detailLabel;
@property (nonatomic,strong)UIButton    *leftButton;
@property (nonatomic,strong)UIButton    *rightButton;


- (void)show;

- (void)hideWithAnimate:(BOOL)animate;

- (void)setLeftTitle:(NSString *)tLeft leftAction:(void (^)())left andRightTitle:(NSString *)tRight rightAction:(void (^)())right;

+ (instancetype)createInView:(UIView *)view;

- (void)setContentHead:(NSString *)head andString:(NSString *)str;
@end

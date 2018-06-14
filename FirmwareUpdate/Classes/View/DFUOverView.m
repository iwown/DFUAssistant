//
//  DFUOverView.m
//  ZLYIwown
//
//  Created by 曹凯 on 2017/1/7.
//  Copyright © 2017年 Iwown. All rights reserved.
//
#import "FUHandle.h"
#import <IVBaseKit/IVBaseKit.h>
#import "DFUOverView.h"

@implementation DFUOverView
{
    DFUAction _leftAction;
    DFUAction _rightAction;
}

- (instancetype)initWithFrame:(CGRect)frame andSELLeft:(DFUAction)leftAciton andSELRight:(DFUAction)rightAction {
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor whiteColor]];
        _leftAction = leftAciton;
        _rightAction = rightAction;
    }
    return self;
}

- (void)drawRect:(CGRect)rect{
    
    UIImageView *completeView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"upgradeOver"]];
    [self addSubview:completeView];
    [completeView setCenter:CGPointMake(SCREEN_WIDTH *0.5, SCREEN_HEIGHT*0.2)];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT*0.4, SCREEN_WIDTH, FONT(30))];
    [lab setText:@"[升级成功]"];
    [lab setTextColor:[UIColor colorFromCode:[FUHandle shareInstance].fuNBCI inAlpha:1]];
    [lab setTextAlignment:NSTextAlignmentCenter];
    [lab setFont:[UIFont systemFontOfSize:FONT(25)]];
    [self addSubview:lab];
    
    UILabel *laba = [[UILabel alloc] initWithFrame:CGRectMake(20, SCREEN_HEIGHT*0.5, SCREEN_WIDTH-40, FONT(25))];
    [laba setText:@"请确认升级后手环是否自动开机"];
    [laba setTextColor:[UIColor colorFromCode:[FUHandle shareInstance].fuNBCI inAlpha:1]];
    [laba setTextAlignment:NSTextAlignmentCenter];
    [laba setNumberOfLines:0];
    [self addSubview:laba];
    
    UIButton *btnA = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*0.5-FONT(70), SCREEN_HEIGHT*0.58, FONT(50), FONT(25))];
    [btnA addTarget:self action:@selector(completeBtnClickLeft) forControlEvents:UIControlEventTouchUpInside];
    [btnA setTitleColor:[UIColor colorFromCode:[[FUHandle shareInstance] fuNBCI] inAlpha:1.0] forState:UIControlStateNormal];
//    [btnA setTitleColor:[Utils colorFromCode:0xffffff inAlpha:1.0] forState:UIControlStateHighlighted];
    [btnA setImage:[UIImage createImageWithColor:[UIColor colorFromCode:0xffffff inAlpha:1.0]] forState:UIControlStateNormal];
    [btnA setImage:[UIImage createImageWithColor:[UIColor colorFromCode:[[FUHandle shareInstance] fuNBCI] inAlpha:1.0]] forState:UIControlStateHighlighted];
    [btnA setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [btnA setTitle:@"是" forState:UIControlStateNormal];
    [[btnA titleLabel] setFont:[UIFont boldSystemFontOfSize:(17.0/414.0*SCREEN_WIDTH)]];
    [[btnA titleLabel] setNumberOfLines:0];
    [[btnA titleLabel] setAdjustsFontSizeToFitWidth:YES];
    [[btnA layer] setMasksToBounds:YES];
    [[btnA layer] setCornerRadius:FONT(12.5)];
    [[btnA layer] setBorderWidth:1.0];
    [[btnA layer] setBorderColor:[UIColor colorFromCode:[[FUHandle shareInstance] fuNBCI] inAlpha:1.0].CGColor];
    [self addSubview:btnA];
    
    UIButton *btnB = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*0.5+FONT(20), SCREEN_HEIGHT*0.58, FONT(50), FONT(25))];
    [btnB addTarget:self action:@selector(completeBtnClickRight) forControlEvents:UIControlEventTouchUpInside];
    [btnB setTitleColor:[UIColor colorFromCode:[[FUHandle shareInstance] fuNBCI] inAlpha:1.0] forState:UIControlStateNormal];
//    [btnB setTitleColor:[Utils colorFromCode:0xffffff inAlpha:1.0] forState:UIControlStateHighlighted];
    [btnB setImage:[UIImage createImageWithColor:[UIColor colorFromCode:0xffffff inAlpha:1.0]] forState:UIControlStateNormal];
    [btnB setImage:[UIImage createImageWithColor:[UIColor colorFromCode:[[FUHandle shareInstance] fuNBCI] inAlpha:1.0]] forState:UIControlStateHighlighted];
    [btnB setTitle:@"否" forState:UIControlStateNormal];
    [btnB setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [[btnB titleLabel] setFont:[UIFont boldSystemFontOfSize:15.0]];
    [[btnB titleLabel] setNumberOfLines:0];
    [[btnB titleLabel] setAdjustsFontSizeToFitWidth:YES];
    [[btnB layer] setMasksToBounds:YES];
    [[btnB layer] setCornerRadius:FONT(12.5)];
    [[btnB layer] setBorderWidth:1.0];
    [[btnB layer] setBorderColor:[UIColor colorFromCode:[[FUHandle shareInstance] fuNBCI] inAlpha:1.0].CGColor];
    [self addSubview:btnB];
}


- (void)completeBtnClickLeft {
    _leftAction();
}

- (void)completeBtnClickRight {
    _rightAction();
}


@end

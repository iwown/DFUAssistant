//
//  DFUAlertView.m
//  ZLYIwown
//
//  Created by caike on 16/10/18.
//  Copyright © 2016年 Iwown. All rights reserved.
//
#import "Masonry.h"
#import <IVBaseKit/IVBaseKit.h>
#import "DFUAlertView.h"

@interface DFUAlertView ()
@property (nonatomic,copy)void (^leftClicked)();
@property (nonatomic,copy)void (^rightClicked)();
@end

@implementation DFUAlertView

+(instancetype)createInView:(UIView *)view
{
    UIView *coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    if (view == nil) {
        view = [[UIApplication sharedApplication].delegate window];
    }
    [view addSubview:coverView];
    coverView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    coverView.hidden = YES;

    DFUAlertView *alert = [[DFUAlertView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0)];
    [coverView addSubview:alert];
    return alert;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupSubviews];
        [self setupLayouts];
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 3;
    }
    return self;
}


- (void)setupSubviews
{
    self.titleLabel = [UILabel new];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    CALayer *line = [[CALayer alloc]init];
    line.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1].CGColor;
    [line setFrame:CGRectMake(0, FONT(40), CGRectGetWidth(self.layer.frame), 1)];
    [self.layer addSublayer:line];
    
    self.contentLabel = [UILabel new];
    self.contentLabel.numberOfLines = 0;

    self.detailLabel = [UILabel new];
    self.detailLabel.numberOfLines = 0;
    self.detailLabel.textColor = [UIColor colorFromCode:0x999999 inAlpha:1];
    self.detailLabel.font = [UIFont systemFontOfSize:15];
    
    self.leftButton = [UIButton new];
    self.leftButton.titleLabel.font = [UIFont systemFontOfSize:16];
    
    
    self.rightButton = [UIButton new];
    self.rightButton.titleLabel.font = [UIFont systemFontOfSize:16];
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.contentLabel];
    [self addSubview:self.detailLabel];
    [self addSubview:self.leftButton];
    [self addSubview:self.rightButton];
    
    [self.leftButton setTitle:NSLocalizedString(@"取消", @"取消") forState:UIControlStateNormal];
    [self.rightButton setTitle:NSLocalizedString(@"确定", @"确定") forState:UIControlStateNormal];
    [self.leftButton setBackgroundColor:[UIColor colorFromCode:0x2ec990 inAlpha:1]];
    [self.rightButton setBackgroundColor:[UIColor colorFromCode:0x2ec990 inAlpha:1]];
    
    [self.leftButton setTitleColor:[UIColor colorWithWhite:0.85 alpha:1] forState:UIControlStateHighlighted];
    [self.rightButton setTitleColor:[UIColor colorWithWhite:0.85 alpha:1] forState:UIControlStateHighlighted];
    
    [self.leftButton addTarget:self action:@selector(leftAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton addTarget:self action:@selector(rightAction:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)setupLayouts
{
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.centerX.equalTo(self);
        make.width.equalTo(self);
        make.height.mas_equalTo(FONT(40));
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
        make.left.equalTo(self).offset(15);
        make.right.equalTo(self.mas_right).offset(-15);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.top.lessThanOrEqualTo(self.contentLabel.mas_bottom).offset(20);
        make.right.equalTo(self.mas_right).offset(-15);
    }];
    
    
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.detailLabel.mas_bottom).offset(15);
        make.left.equalTo(self);
        make.width.equalTo(self).multipliedBy(0.5).offset(-0.5);
        make.height.mas_equalTo(FONT(40));
        make.bottom.equalTo(self);
    }];
    
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.leftButton);
        make.right.equalTo(self);
        make.size.equalTo(self.leftButton);
    }];
    
    UILabel *line = [UILabel new];
    line.backgroundColor = [UIColor colorFromCode:0x2ec990 inAlpha:0.7];
    [self addSubview:line];
    
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.leftButton);
        make.left.equalTo(self.leftButton.mas_right);
        make.width.mas_equalTo(1);
        make.height.equalTo(self.leftButton);
    }];
    
}

- (void)setLeftTitle:(NSString *)tLeft leftAction:(void (^)())left andRightTitle:(NSString *)tRight rightAction:(void (^)())right
{
    [self.leftButton setTitle:tLeft forState:UIControlStateNormal];
    self.leftClicked = left;
    
    [self.rightButton setTitle:tRight forState:UIControlStateNormal];
    self.rightClicked = right;
}

- (void)setContentHead:(NSString *)head andString:(NSString *)str
{
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByWordWrapping;
    paraStyle.paragraphSpacing = 2;
    NSDictionary *attribute = @{NSForegroundColorAttributeName:[UIColor lightGrayColor],
                          NSFontAttributeName:[UIFont systemFontOfSize:14],
                          NSParagraphStyleAttributeName:paraStyle};
    NSMutableAttributedString *s = [[NSMutableAttributedString alloc]initWithString:[head stringByAppendingString:str] attributes:attribute];
    
    NSMutableParagraphStyle *paraStyle1 = [[NSMutableParagraphStyle alloc] init];
    paraStyle1.lineBreakMode = NSLineBreakByWordWrapping;
    paraStyle1.lineSpacing = 10;
    NSDictionary *dic = @{NSForegroundColorAttributeName:[UIColor blackColor],
                          NSFontAttributeName:[UIFont systemFontOfSize:15],
                          NSParagraphStyleAttributeName:paraStyle1};
    [s addAttributes:dic range:NSMakeRange(0, head.length)];
    self.contentLabel.attributedText = s;
    
}


#pragma mark action
- (void)leftAction:(UIButton *)sender
{
    if (self.leftClicked) {
        self.leftClicked();
    }else {
        [self hideWithAnimate:YES];
    }
}

- (void)rightAction:(UIButton *)sender
{
    if (self.rightClicked) {
        self.rightClicked();
    }
    else {
        [self hideWithAnimate:YES];
    }
}


- (void)show
{
    if (self.contentLabel.text.length == 0) {
        [self.detailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(15);
            make.top.lessThanOrEqualTo(self.contentLabel.mas_bottom).offset(5);
            make.right.equalTo(self.mas_right).offset(-15);
        }];
    }
    
    UIView *view = self.superview;
    [view setHidden:NO];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(30);
        make.right.equalTo(view).offset(-30);
        make.center.equalTo(view);
    }];
}


- (void)hideWithAnimate:(BOOL)animate
{
    if (animate) {
        [self setAnchorPoint:CGPointMake(0, 0)];
        
        [UIView animateWithDuration:0.2 animations:^{
            self.transform = CGAffineTransformMakeRotation(M_PI_2/6);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.4f animations:^{
                self.center = CGPointMake(self.center.x, self.center.y+SCREEN_HEIGHT/2+CGRectGetHeight(self.frame)/2);
            } completion:^(BOOL finished) {
                [self.superview removeFromSuperview];
            }];
        }];
    }
    else {
        [self.superview removeFromSuperview];
    }
}


- (void)setAnchorPoint:(CGPoint)anchorPoint
{
    CGRect oldFrame = self.frame;
    self.layer.anchorPoint = anchorPoint;
    self.frame = oldFrame;
}


- (void)dealloc{
    NSLog(@"%s",__FUNCTION__);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

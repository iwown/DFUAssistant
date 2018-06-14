//
//  ToastView.m
//  TT
//
//  Created by 曹凯 on 16/7/2.
//  Copyright © 2016年 leopard. All rights reserved.
//
#import <UIKit/UIKit.h>

// activity
static const CGFloat CSToastActivityWidth       = 50.0;
static const CGFloat CSToastActivityHeight      = 8.0;

#import "ToastView.h"

@implementation ToastView


- (void)drawRect:(CGRect)rect {
   
    
}

- (void)activityView {
    self.layer.cornerRadius = FONT(4);
    self.layer.masksToBounds = YES;
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicatorView.center = self.center;
    [self addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
}

- (void)viwaView:(NSString *)text {
    
    self.layer.cornerRadius = FONT(4);
    self.layer.masksToBounds = YES;
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"加载成功青蛙"]];
    [image setFrame:CGRectMake(20, 13, CSToastActivityWidth, CSToastActivityWidth+6)];
    [self addSubview:image];
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicatorView.center = CGPointMake(10,90);
    [self addSubview:activityIndicatorView];
    [activityIndicatorView startAnimating];
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, 80, 20)];
    [lab setText:text];
    [lab setTextAlignment:NSTextAlignmentRight];
    [lab setFont:[UIFont systemFontOfSize:12]];
    [lab setTextColor:[UIColor lightGrayColor]];
    [self addSubview:lab];
}


- (void)failureViwaView:(NSString *)text {
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"加载失败青蛙"]];
    [image setFrame:CGRectMake(0, 0, 100, 112)];
    [self addSubview:image];
    image.center = CGPointMake(self.center.x, self.center.y - 20);
    
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(0, image.frame.origin.y + image.frame.size.height + 30, self.frame.size.width, 20)];
    [lab setText:text];
    [lab setTextAlignment:NSTextAlignmentCenter];
    [lab setFont:[UIFont systemFontOfSize:18]];
    [lab setTextColor:[UIColor lightGrayColor]];
    [self addSubview:lab];
}


- (void)circleView {
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    pathAnimation.duration = 1.6;
    pathAnimation.fromValue = [NSNumber numberWithFloat:0.0f];
    pathAnimation.toValue = [NSNumber numberWithFloat:2 * M_PI];
    pathAnimation.repeatCount = LONG_MAX;
    pathAnimation.beginTime = 0.4;
    
    CALayer *layer = [[CALayer alloc] init];
    layer.frame = CGRectMake(0, 0, CSToastActivityHeight, CSToastActivityHeight);
    layer.backgroundColor = [UIColor redColor].CGColor;
    [self.layer addSublayer:layer];
    //    layer.cornerRadius = CSToastActivityHeight*0.5;
    //    layer.masksToBounds = YES;
    
    CALayer *layerB = [[CALayer alloc] init];
    layerB.frame = CGRectMake(CSToastActivityWidth -CSToastActivityHeight, 0, CSToastActivityHeight, CSToastActivityHeight);
    layerB.backgroundColor = [UIColor redColor].CGColor;
    [self.layer addSublayer:layerB];
    
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    scaleAnimation.fromValue = [NSNumber numberWithFloat:2 * M_PI];
    scaleAnimation.toValue = [NSNumber numberWithFloat:0.0f];
    
    CABasicAnimation *anoleAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    anoleAnimation.fromValue = (id)@1.0;
    anoleAnimation.toValue = (id)@0.0;
    
    CAAnimationGroup * theGroup = [CAAnimationGroup animation];
    theGroup.duration = 2.0;
    theGroup.animations = @[scaleAnimation,anoleAnimation];
    
    theGroup.repeatCount = LONG_MAX;
    theGroup.beginTime = 0.2;
    [layer addAnimation:pathAnimation forKey:@"AAnimation"];
    [layerB addAnimation:pathAnimation forKey:@"BAnimation"];
    [self.layer addAnimation:theGroup forKey:@"rotate-layer"];
}

+ (instancetype)defaultView {
  
   return [self activityView:TOASTViewTypeActivity];
}

+ (instancetype)activityView:(TOASTViewType)toastType {
    
    switch (toastType) {
        case TOASTViewTypeActivity:
        {
            ToastView *toast = [[ToastView alloc] initWithFrame:CGRectMake(0, 0, CSToastActivityWidth,CSToastActivityWidth)];
            [toast activityView];
            return toast;
        }
            break;
        case TOASTViewTypeViwa:
        {
            ToastView *toast = [[ToastView alloc] initWithFrame:CGRectMake(0, 0, 2*CSToastActivityWidth, 2*CSToastActivityWidth)];
            [toast viwaView:NSLocalizedString(@"小哇正在努力", nil)];
            toast.backgroundColor = [UIColor whiteColor];
            return toast;
        }
            break;
        case TOASTViewTypeCycle:
        {
            ToastView *toast = [[ToastView alloc] initWithFrame:CGRectMake(0, 0, CSToastActivityWidth, CSToastActivityHeight)];
            [toast circleView];
            toast.backgroundColor = [UIColor clearColor];
            return toast;
        }
            break;
            
        default:
        {
            ToastView *toast = [[ToastView alloc] initWithFrame:CGRectMake(0, 0, CSToastActivityWidth,CSToastActivityWidth)];
            [toast activityView];
            return toast;
        }
            break;
    }
 
}

+ (instancetype)viwaActivityWithText:(NSString *)title {
    ToastView *toast = [[ToastView alloc] initWithFrame:CGRectMake(0, 0, 2*CSToastActivityWidth, 2*CSToastActivityWidth)];
    [toast viwaView:title];
    toast.backgroundColor = [UIColor whiteColor];
    return toast;
}

+ (instancetype)failureViwaWithText:(NSString *)title {
    ToastView *toast = [[ToastView alloc] initWithFrame:CGRectMake(0, 0, 4*CSToastActivityWidth, 4*CSToastActivityWidth)];
    [toast failureViwaView:title];
    toast.backgroundColor = [UIColor clearColor];
    return toast;
}

- (void)dealloc {
    [self.layer removeAnimationForKey:@"rotate-layer"];
}
@end

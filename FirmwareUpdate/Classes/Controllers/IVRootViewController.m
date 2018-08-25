//
//  IVRootViewController.m
//  FirmwareUpdate
//
//  Created by 曹凯 on 2016/11/7.
//  Copyright © 2016年 west. All rights reserved.
//
#import "ViewController.h"
#import "IVRootViewController.h"
#import "DUViewController.h"
#import "DCViewController.h"
#import "ZGViewController.h"
#import "EPOViewController.h"
#import "PBViewController.h"
#import "LightBlueViewController.h"

@interface IVRootViewController ()

@end

@implementation IVRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[self imageWithText:@"Firmware Upgrade"]];
    
    self.title = @"Firmware Upgrade";
    NSArray *arr = @[
  @{@"btnTitle":@"DFU", @"btnSelectorMethod":@"dfuBtnClick"},
  @{@"btnTitle":@"DFU\nColorful", @"btnSelectorMethod":@"dfuCBtnClick"},
  @{@"btnTitle":@"ENTRY\nDFU", @"btnSelectorMethod":@"lightBlueBtnClick"},
  @{@"btnTitle":@"SOUTA", @"btnSelectorMethod":@"soutaBtnClick"},
  @{@"btnTitle":@"FOTA", @"btnSelectorMethod":@"fotaBtnClick"},
  @{@"btnTitle":@"EPO", @"btnSelectorMethod":@"epoBtnClick"},
  @{@"btnTitle":@"PB_DFU", @"btnSelectorMethod":@"pbDfuBtnClick"},
  @{@"btnTitle":@"DFU-L\nColorful", @"btnSelectorMethod":@"dfuLoopCBtnClick"}];
    
    CGFloat width = SCREEN_WIDTH * 0.2;
    int total = (int)arr.count;
    for (int i = 0; i < total; i ++) {
        NSDictionary *dict = arr[i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.titleLabel.numberOfLines = 0;
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.font = [UIFont systemFontOfSize:FONT(15)];
        CGFloat x = SCREEN_WIDTH * (0.1 + (i%3) * 0.3);
        CGFloat y = SCREEN_HEIGHT*0.18 + SCREEN_WIDTH * (0.1 + (i/3) * 0.3);
        [btn setFrame:CGRectMake(x, y, width, width)];
        [btn setTitle:dict[@"btnTitle"] forState:UIControlStateNormal];
        CGFloat red = (i*1.0/total + 0.1) * 0.9;
        CGFloat green = (1 - i*1.0/total) * 0.9;
        CGFloat blue = (i*1.0/total) * 0.9;
        [btn setBackgroundColor:[UIColor colorWithRed:red green:green blue:blue alpha:1]];
        SEL selector = NSSelectorFromString(dict[@"btnSelectorMethod"]);
        [btn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}

- (void)lightBlueBtnClick {
    [self.navigationController pushViewController:[LightBlueViewController new] animated:YES];
}

- (void)dfuCBtnClick {
    [self.navigationController pushViewController:[ZGViewController new] animated:YES];
}

- (void)dfuBtnClick {
    [self.navigationController pushViewController:[ViewController new] animated:YES];
}

- (void)dfuLoopCBtnClick {
    ZGViewController *zgVC = [ZGViewController new];
    zgVC.autoUpgrading = YES;
    [self.navigationController pushViewController:zgVC animated:YES];
}

- (void)soutaBtnClick {
    [self.navigationController pushViewController:[[DUViewController alloc] init] animated:YES];
}

- (void)fotaBtnClick {
    [self.navigationController pushViewController:[[DCViewController alloc] init] animated:YES];
}

- (void)epoBtnClick {
    [self.navigationController pushViewController:[[EPOViewController alloc] init] animated:YES];
}

- (void)pbDfuBtnClick {
    [self.navigationController pushViewController:[[PBViewController alloc] init] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)imageWithText:(NSString *)text{
    
    /**
     这里之所以外面再放一个UIView，是因为直接用label画图的话，旋转就不起作用了
     */
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 100)];
    view.backgroundColor = [UIColor clearColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:view.bounds];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithRed:0.23 green:0.87 blue:0.34 alpha:0.5];
    label.font = [UIFont systemFontOfSize:14.0];
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    label.transform = CGAffineTransformMakeRotation(-M_PI/4.0);
    [view addSubview:label];
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end

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
#import "LightBlueViewController.h"

@interface IVRootViewController ()

@end

@implementation IVRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Firmware Upgrade";
    NSArray *arr = @[
  @{@"btnTitle":@"DFU", @"btnSelectorMethod":@"dfuBtnClick"},
  @{@"btnTitle":@"DFU\nColorful", @"btnSelectorMethod":@"dfuCBtnClick"},
  @{@"btnTitle":@"ENTRY\nDFU", @"btnSelectorMethod":@"lightBlueBtnClick"},
  @{@"btnTitle":@"SOUTA", @"btnSelectorMethod":@"soutaBtnClick"},
  @{@"btnTitle":@"FOTA", @"btnSelectorMethod":@"fotaBtnClick"},
  @{@"btnTitle":@"EPO", @"btnSelectorMethod":@"epoBtnClick"},
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

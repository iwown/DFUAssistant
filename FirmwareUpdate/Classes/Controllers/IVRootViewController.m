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
@interface IVRootViewController ()

@end

@implementation IVRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"固件升级";
    UIButton *btnA = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnA setFrame:CGRectMake((SCREEN_WIDTH-200)*0.33,SCREEN_HEIGHT*0.2, 100, 100)];
    [btnA setTitle:@"DFU升级" forState:UIControlStateNormal];
    [btnA setBackgroundColor:[UIColor colorWithRed:189/255.0 green:245/255.0 blue:122/255.0 alpha:1]];
    [btnA addTarget:self action:@selector(dfuBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnA];
    
    UIButton *btnB = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnB setFrame:CGRectMake((SCREEN_WIDTH-200)*0.67 + 100,SCREEN_HEIGHT*0.2, 100, 100)];
    btnB.titleLabel.numberOfLines = 0;
    btnB.titleLabel.textAlignment = NSTextAlignmentCenter;
    [btnB setTitle:@"DFU升级\n彩屏" forState:UIControlStateNormal];
    [btnB setBackgroundColor:[UIColor colorWithRed:65/255.0 green:173/255.0 blue:229/255.0 alpha:1]];
    [btnB addTarget:self action:@selector(lightBlueBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnB];
    
    UIButton *btnC = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnC setFrame:CGRectMake((SCREEN_WIDTH-200)*0.33,SCREEN_HEIGHT*0.5, 100, 100)];
    [btnC setTitle:@"SOUTA升级" forState:UIControlStateNormal];
    [btnC setBackgroundColor:[UIColor colorWithRed:92/255.0 green:193/255.0 blue:147/255.0 alpha:1]];
    [btnC addTarget:self action:@selector(soutaBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnC];
    
    UIButton *btnD = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnD setFrame:CGRectMake((SCREEN_WIDTH-200)*0.67 + 100,SCREEN_HEIGHT*0.5, 100, 100)];
    [btnD setTitle:@"FOTA升级" forState:UIControlStateNormal];
    [btnD setBackgroundColor:[UIColor colorWithRed:124/255.0 green:160/255.0 blue:38/255.0 alpha:1]];
    [btnD addTarget:self action:@selector(fotaBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnD];
    // Do any additional setup after loading the view.
}

- (void)lightBlueBtnClick {
  
}

- (void)dfuBtnClick {
    [self.navigationController pushViewController:[ViewController new] animated:YES];
}

- (void)soutaBtnClick {
    [self.navigationController pushViewController:[[DUViewController alloc] init] animated:YES];
}

- (void)fotaBtnClick {
    [self.navigationController pushViewController:[[DCViewController alloc] init] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

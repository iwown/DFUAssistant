//
//  PBViewController.m
//  FirmwareUpdate
//
//  Created by A$CE on 2018/8/23.
//  Copyright © 2018年 west. All rights reserved.
//
#import "PBViewController.h"

@interface PBViewController ()

@end

@implementation PBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"PB_DFU";
    CBUUID *bUuid = [CBUUID UUIDWithString:@"FE59"];
    self.uuids = @[bUuid];
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

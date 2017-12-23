//
//  BlueViewController.h
//  FirmwareUpdate
//
//  Created by 曹凯 on 2016/10/31.
//  Copyright © 2016年 west. All rights reserved.
//
#import <UIKit/UIKit.h>

@class BluetoothManager;
@interface BlueViewController : UIViewController
@property (nonatomic ,strong) BluetoothManager *manager;

@property (nonatomic ,assign) BOOL autoState;
@end

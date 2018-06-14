//
//  FirmwareListController.h
//  FirmwareUpdate
//
//  Created by west on 16/9/20.
//  Copyright © 2016年 west. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FileManager.h"


@protocol FirmwareListControllerDelegate <NSObject>

@optional

- (void)selectFirmware:(NSString *)path;

@end

@interface FirmwareListController : UIViewController

@property (nonatomic, unsafe_unretained)id<FirmwareListControllerDelegate> delegate;

@end

//
//  NetWorkHandle.h
//  FirmwareUpdate
//
//  Created by 曹凯 on 2016/11/16.
//  Copyright © 2016年 west. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IVFirmwareModel;
@interface NetWorkHandle : NSObject

+ (NSArray <IVFirmwareModel *>*)selectFirmwareList;
@end

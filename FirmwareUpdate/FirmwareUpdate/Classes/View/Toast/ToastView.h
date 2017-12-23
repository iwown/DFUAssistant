//
//  ToastView.h
//  TT
//
//  Created by 曹凯 on 16/7/2.
//  Copyright © 2016年 leopard. All rights reserved.
//


typedef enum{
        TOASTViewTypeActivity = 0,
        TOASTViewTypeViwa ,
        TOASTViewTypeCycle
}TOASTViewType;

#import <UIKit/UIKit.h>

@interface ToastView : UIView
+ (instancetype)defaultView;
+ (instancetype)activityView:(TOASTViewType)toastType;

+ (instancetype)viwaActivityWithText:(NSString *)title;
+ (instancetype)failureViwaWithText:(NSString *)title;
@end

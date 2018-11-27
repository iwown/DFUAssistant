//
//  DFUOverView.h
//  ZLYIwown
//
//  Created by 曹凯 on 2017/1/7.
//  Copyright © 2017年 Iwown. All rights reserved.
//

typedef void(^DFUAction)(void);
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface DFUOverView : UIView

- (instancetype)initWithFrame:(CGRect)frame andSELLeft:(DFUAction)leftAciton andSELRight:(DFUAction)rightAction;
@end

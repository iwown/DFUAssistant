//
//  PercentView.m
//  FirmwareUpdate
//
//  Created by west on 16/9/21.
//  Copyright © 2016年 west. All rights reserved.
//

#import "PercentView.h"

@implementation PercentView
{
    UISlider *_mySlider;
    UILabel *_modeLabel;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self drawUI];
    }
    return self;
}

- (void)drawUI
{
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width - 86, 3)];
    bgView.backgroundColor = [UIColor lightGrayColor];
    bgView.center = CGPointMake(width / 2, height / 2);
    [self addSubview:bgView];
    
    _mySlider = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, width - 70, 30)];
    _mySlider.backgroundColor = [UIColor clearColor];
    [_mySlider setMinimumTrackTintColor:[UIColor blueColor]];
    [_mySlider setMaximumTrackTintColor:[UIColor clearColor]];
    [_mySlider setThumbTintColor:[UIColor clearColor]];
    _mySlider.minimumValue = 0;
    _mySlider.maximumValue = 100;
    _mySlider.value = 0;
    _mySlider.center = CGPointMake(width / 2 + 6, height / 2);
    _mySlider.enabled = NO;
    [self addSubview:_mySlider];
    
    _modeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _mySlider.frame.origin.y + 40, width, 30)];
    _modeLabel.textColor = [UIColor blueColor];
    _modeLabel.textAlignment = NSTextAlignmentCenter;
    _modeLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:_modeLabel];
    
}


- (void)setPercent:(NSInteger)percent
{
    if (percent > 100) {
        return;
    }
    _percent = percent;
    _mySlider.value = _percent;
    _modeLabel.text = [NSString stringWithFormat:@"%ld%%", percent];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

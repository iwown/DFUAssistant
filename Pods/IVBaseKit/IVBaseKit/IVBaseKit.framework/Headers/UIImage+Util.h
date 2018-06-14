//
//  UIImage+Util.h
//  linyi
//
//  Created by caike on 16/12/21.
//  Copyright © 2016年 com.kunekt.healthy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Util)
+ (UIImage *)imageWithNameNotCache:(NSString *)imageName;

- (UIImage *)imageMaskedWithColor:(UIColor *)maskColor;
- (UIImage *)cropToRect:(CGRect)rect;
- (UIImage *)blurredImageWithRadius:(CGFloat)radius iterations:(NSUInteger)iterations tintColor:(UIColor *)tintColor;

+ (UIImage *) imageScale:(UIImage *)sourceImage toSize:(CGSize)dsize;

/**
 * 将UIColor变换为UIImage
 *
 **/
+ (UIImage *)createImageWithColor:(UIColor *)color;

+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

@end

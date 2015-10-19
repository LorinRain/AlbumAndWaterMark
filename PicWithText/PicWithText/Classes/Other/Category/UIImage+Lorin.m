//
//  UIImage+Lorin.m
//  PicWithText
//
//  Created by Lorin on 14/11/9.
//  Copyright (c) 2014年 Lighting-Vista. All rights reserved.
//

#import "UIImage+Lorin.h"

@implementation UIImage (Lorin)

#pragma mark - 图片加文字
/*
 注释：在调用完该方法后会返回一张新的图片，这张图片就已经和将文字合成在上面了，而非是在图片上添加label
 */

#pragma mark - 图片加上文字
+ (UIImage *)imageWithStringWaterMark:(NSString *)markString atImage:(UIImage *)image
{
    if(image.size.width > 1440 || image.size.width > 1440) {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width * 0.5, image.size.height * 0.5), NO, 0.0);
        
        // 原图
        [image drawInRect: CGRectMake(0, 0, image.size.width * 0.5, image.size.height * 0.5)];
        // 文字颜色
        [[UIColor whiteColor] set];
        // 文字字体
        UIFont *font;
        if(image.size.width < [UIScreen mainScreen].applicationFrame.size.width) {
            //font = [UIFont boldSystemFontOfSize: 20];
            font = [UIFont fontWithName: @"迷你简菱心" size: 20];
        } else {
            //font = [UIFont boldSystemFontOfSize: 50];
            font = [UIFont fontWithName: @"迷你简菱心" size: 60];
        }
        // 文字位置
        CGPoint point = CGPointMake(image.size.width * 0.1 * 0.5, image.size.height * 0.5 * 0.8);
        // 水印文字
        [markString drawAtPoint: point withAttributes: @{NSFontAttributeName:font}];
        
    } else {
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(image.size.width * 0.7, image.size.height * 0.7), NO, 0.0);
        
        // 原图
        [image drawInRect: CGRectMake(0, 0, image.size.width * 0.7, image.size.height * 0.7)];
        // 文字颜色
        [[UIColor whiteColor] set];
        // 文字字体
        UIFont *font;
        if(image.size.width < [UIScreen mainScreen].applicationFrame.size.width) {
            //font = [UIFont boldSystemFontOfSize: 20];
            font = [UIFont fontWithName: @"迷你简菱心" size: 20];
        } else {
            //font = [UIFont boldSystemFontOfSize: 50];
            font = [UIFont fontWithName: @"迷你简菱心" size: 60];
        }
        // 文字位置
        CGPoint point = CGPointMake(image.size.width * 0.1 * 0.7, image.size.height * 0.7 * 0.8);
        // 水印文字
        [markString drawAtPoint: point withAttributes: @{NSFontAttributeName:font}];
    }
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSLog(@"%@",newImage);
    
    return newImage;
}

#pragma mark - 图片上加图片logo
+ (UIImage *)imageWithTransImage:(UIImage *)useImage addtransparentImage:(UIImage *)transparentimg alpha:(CGFloat)alpha
{
    if(useImage.size.width > 1440 || useImage.size.width > 1440) {
        UIGraphicsBeginImageContext(CGSizeMake(useImage.size.width * 0.5, useImage.size.height * 0.5));
        
        [useImage drawInRect: CGRectMake(0, 0, useImage.size.width * 0.5, useImage.size.height * 0.5)];
        [transparentimg drawInRect: CGRectMake(useImage.size.width * 0.6 * 0.5, useImage.size.height * 0.95 * 0.5, useImage.size.width * 0.4 * 0.5, useImage.size.height * 0.05 * 0.5) blendMode: kCGBlendModeDestinationAtop alpha: alpha];
    } else {
        UIGraphicsBeginImageContext(CGSizeMake(useImage.size.width * 0.7, useImage.size.height * 0.7));
        
        [useImage drawInRect: CGRectMake(0, 0, useImage.size.width * 0.7, useImage.size.height * 0.7)];
        [transparentimg drawInRect: CGRectMake(useImage.size.width * 0.6 * 0.7, useImage.size.height * 0.9 * 0.7, useImage.size.width * 0.4 * 0.7, useImage.size.height * 0.1 * 0.7) blendMode: kCGBlendModeOverlay alpha: alpha];
    }
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultingImage;
}

#pragma mark - 封装成一个方法，在添加文字时自动加上logo
+ (UIImage *)imageWithLogo:(UIImage *)currentImage logoImage:(UIImage *)logoImage text:(NSString *)text alpha:(CGFloat)alpha
{
    UIImage *textImage = [UIImage imageWithStringWaterMark: text atImage: currentImage];
    UIImage *resultImage = [UIImage imageWithTransImage: textImage addtransparentImage: logoImage alpha: alpha];
    return resultImage;
}



@end

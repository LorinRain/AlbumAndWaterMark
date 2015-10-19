//
//  UIImage+Lorin.h
//  PicWithText
//
//  Created by Lorin on 14/11/9.
//  Copyright (c) 2014年 Lighting-Vista. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Lorin)

// 为图片加上文字
+ (UIImage *)imageWithStringWaterMark:(NSString *)markString atImage:(UIImage *)image;

// 添加半透明图片logo（透明度应该为动态输入）
+ (UIImage *)imageWithTransImage:(UIImage *)useImage addtransparentImage:(UIImage *)transparentimg alpha:(CGFloat)alpha;

// 封装后的方法，直接输入文字，自动添加logo
+ (UIImage *)imageWithLogo:(UIImage *)currentImage logoImage:(UIImage *)logoImage text:(NSString *)text alpha:(CGFloat)alpha;

@end

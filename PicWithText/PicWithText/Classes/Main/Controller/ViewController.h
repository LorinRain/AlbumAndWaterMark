//
//  ViewController.h
//  PicWithText
//
//  Created by Lorin on 14/11/8.
//  Copyright (c) 2014年 Lighting-Vista. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UITextViewDelegate>

@property (nonatomic, retain) UIImagePickerController *imagePicker;

@end


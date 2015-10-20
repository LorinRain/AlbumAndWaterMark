//
//  ViewController.m
//  PicWithText
//
//  Created by Lorin on 14/11/8.
//  Copyright (c) 2014年 Lighting-Vista. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+Lorin.h"

#define kStatusBarHeight 20.0  // 状态栏高度
#define kNavgationBarHeight self.navigationController.navigationBar.frame.size.height  // 导航栏高度
#define kLogoImage [UIImage imageNamed: @"logo_png_TM_clear.png"]    // logo图片

@interface ViewController ()
{
    UIImageView *_uploadPic;   // 显示图片的imageView
    UILabel *_tipLabel;        // 图片中提示用户添加图片的label
    UIView *_shadeView;        // 要添加到图片上面的视图（包括文字和图片，图片自动生成，文字用户输入）
    UITextView *_txtView;      // 输入文字框
    UIButton *_btnDone;        // 在键盘出现后添加一个“完成编辑”的按钮
    UIImage *_firstImg;        // 添加完图片后，想换文字的时候，检测当前图片是否已经有文字，有文字就清除文字，这个图片作为原始图片
    UIControl *_changePic;     // 切换图片，蒙版显示
}

@end

@implementation ViewController

#pragma mark - ViewLifeCycle 视图生命周期

- (void)viewDidLoad {
    [super viewDidLoad];
    // 1.搭建界面
    [self buildUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 将输入框的文字清空
    _txtView.text = nil;
    
    // 注册键盘出现通知
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(keyboardDidShow:) name: UIKeyboardDidShowNotification object: nil];
    
    // 注册键盘隐藏通知
    [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(keyboardDidHide:) name: UIKeyboardDidHideNotification object: nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 解除键盘出现通知
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIKeyboardDidShowNotification object: nil];
    
    // 解除键盘隐藏通知
    [[NSNotificationCenter defaultCenter] removeObserver: self name: UIKeyboardDidHideNotification object: nil];
    
}

#pragma mark - 键盘出现通知
// 键盘出现时，导航栏相应变化
- (void)keyboardDidShow:(NSNotification *)notif
{
    // 获得键盘尺寸
    NSDictionary *info = [notif userInfo];
    NSValue *aValue = [info objectForKey: UIKeyboardFrameEndUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    
    // 键盘出现时，在键盘上面添加一个关闭键盘的按钮
    if(!_btnDone) {
        _btnDone = [UIButton buttonWithType: UIButtonTypeCustom];
        _btnDone.frame = CGRectMake(self.view.frame.size.width - 70, self.view.frame.size.height - keyboardSize.height - 30, 70, 30);
        _btnDone.titleLabel.font = [UIFont systemFontOfSize: 13];
        [_btnDone setTitle: @"完成编辑" forState: UIControlStateNormal];
        _btnDone.backgroundColor = [UIColor lightGrayColor];
        [_btnDone addTarget: self action: @selector(hideKeyBoard) forControlEvents: UIControlEventTouchUpInside];
        
        [self.view addSubview: _btnDone];
    }
    
}

- (void)keyboardDidHide:(NSNotification *)notif
{
    [_btnDone removeFromSuperview];
    _btnDone = nil;
}


#pragma mark - 搭建界面
- (void)buildUI
{
    // 1.设置标题
    self.title = @"图片";
    
    // 2.导航栏加按钮
    // 导航栏右边，“添加文字”按钮
    UIButton *btnAdd = [UIButton buttonWithType: UIButtonTypeContactAdd];
    btnAdd.frame = CGRectMake(self.view.frame.size.width * 0.85, 10, 30, 20);
    [btnAdd addTarget: self action: @selector(addTextandPic) forControlEvents: UIControlEventTouchUpInside];
    
    [self.navigationController.navigationBar addSubview: btnAdd];
    
    // 导航栏左边，“保存到相册”按钮
    UIButton *btnSave = [UIButton buttonWithType: UIButtonTypeCustom];
    [btnSave setTitle: @"保存" forState: UIControlStateNormal];
    btnSave.bounds = CGRectMake(0, 0, 50, 30);
    btnSave.titleLabel.font = [UIFont systemFontOfSize: 15];
    [btnSave setTitleColor: [UIColor blackColor] forState: UIControlStateNormal];
    [btnSave addTarget: self action: @selector(saveToAlbum) forControlEvents: UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: btnSave];
    
    // 3.设置背景颜色为白色
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 4.添加图片框图
    _uploadPic = [[UIImageView alloc] init];
    _uploadPic.frame = CGRectMake(0, kStatusBarHeight + kNavgationBarHeight, self.view.frame.size.width, 200);
    _uploadPic.backgroundColor = [UIColor colorWithWhite: 0.9 alpha: 1];
    // 设置允许用户交互
    _uploadPic.userInteractionEnabled = YES;
    _uploadPic.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.view addSubview: _uploadPic];
    
    // 5.添加”添加图片“label
    _tipLabel = [[UILabel alloc] init];
    _tipLabel.center = CGPointMake(_uploadPic.frame.origin.x + _uploadPic.frame.size.width * 0.5, _uploadPic.frame.size.height * 0.5);
    _tipLabel.bounds = CGRectMake(0, 0, _uploadPic.frame.size.width * 0.5, _uploadPic.frame.size.height * 0.5);
    _tipLabel.text = @"添加图片";
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    
    [_uploadPic addSubview: _tipLabel];
    
    
    // 6.提示用户输入文字的label
    UILabel *label = [[UILabel alloc] init];
    label.frame = CGRectMake(10, _uploadPic.frame.origin.y + _uploadPic.frame.size.height + 10, 150, 20);
    label.text = @"输入文字：";
    
    [self.view addSubview: label];
    
    // 7.输入文字框
    _txtView = [[UITextView alloc] init];
    _txtView.frame = CGRectMake(10, _uploadPic.frame.origin.y + _uploadPic.frame.size.height + 40, self.view.frame.size.width - 20, 100);
    _txtView.backgroundColor = [UIColor lightGrayColor];
    _txtView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    _txtView.returnKeyType = UIReturnKeyDone;
    // 设置代理
    _txtView.delegate = self;
    
    [self.view addSubview: _txtView];
    
}

#pragma mark - UITextView Delegate 点击完成键隐藏键盘
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString: @"\n"]) {
        [textView resignFirstResponder];
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - 点击“添加图片”后，跳转到相册添加图片
- (void)addPic
{
    // 弹出选择框，用户选择图片来源
    UIActionSheet *chooseFrom = [[UIActionSheet alloc] initWithTitle: @"选择图片来源" delegate: self cancelButtonTitle: @"取消" destructiveButtonTitle: nil otherButtonTitles: @"相册", @"拍照", nil];
    
    [chooseFrom showInView: self.view];
    
}

#pragma mark - UIActionSheetDelegate协议，选择相册进入相册
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0) {  // 从相册选取
        // 访问相册
        // 选取完成后截取照片
        self.imagePicker.allowsEditing = YES;
        // 以摩擦动画的方式显示
        [self presentViewController: self.imagePicker animated: YES completion:^{
            
        }];
    }
    
    if(buttonIndex == 1) {   // 拍照，调用摄像头
        // 判断是否是在模拟器上运行
        if([[UIDevice currentDevice].name isEqualToString: @"iPhone Simulator"]) {
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"当前设备不支持摄像头" message: @"模拟器不支持摄像头" delegate: self cancelButtonTitle: @"确定" otherButtonTitles: nil, nil];
            [alert show];
        } else {

            //UIImagePickerControllerCameraDeviceFront === 前摄像头
            //UIImagePickerControllerCameraDeviceRear === 后摄像头
            BOOL isCamera = [UIImagePickerController isCameraDeviceAvailable: UIImagePickerControllerCameraDeviceRear];
            if(!isCamera) {
                return;
            }
            // 摄像头
            self.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            // 允许编辑
            self.imagePicker.allowsEditing = YES;
            
            [self presentViewController: self.imagePicker animated: YES completion:^{
                
            }];
        }
        
    }
}

#pragma mark 懒加载imagePicker
- (UIImagePickerController *)imagePicker
{
    if(!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
    }
    
    return _imagePicker;
}

#pragma mark - 相册的访问
// 相册选中之后调用
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey: UIImagePickerControllerEditedImage];
    _uploadPic.image = image;
    // 将这张图片设置为最初的图片
    _firstImg = image;
    // 选完后，将“添加图片”字去掉
    [_tipLabel removeFromSuperview];
    // 选完后，退出相册
    
    [picker dismissViewControllerAnimated: YES completion: nil];
}

// 取消按钮的点击事件
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated: YES completion: nil];
}

#pragma mark - “添加”按钮点击事件
- (void)addTextandPic
{
    // 1.关闭键盘
    [_txtView resignFirstResponder];
    
    // 2.检测当前是否有图片
    if(_uploadPic.image) {
        // 1.1有图片，在点击之后将文字合成到图片上
        // 检测文字长度的优先级高，所以应该放在判断图片是否已经添加过之前
        // 限制文字长度
        if(_txtView.text.length >= 15) {
            // 超出字数限制（15字），弹出提示框
            UIAlertView *alter = [[UIAlertView alloc] initWithTitle: @"输入文字太长" message: @"限制15个字" delegate: self cancelButtonTitle: @"确定" otherButtonTitles: nil, nil];
            [alter show];
        } else {   // 此else对应判断文字长度
            
            // 检测图片上是否已经添加过文字
            UIImage *after = [UIImage imageWithStringWaterMark: _txtView.text atImage: _uploadPic.image];
            if(UIImageJPEGRepresentation(_firstImg, 1).length == UIImageJPEGRepresentation(after, 1).length) {
                
            } else {    // 此else对应判断图片是否已经添加过文字
                // 先将图片置为原始图片
                _uploadPic.image = _firstImg;
                // 添加水印
                _uploadPic.image = [UIImage imageWithLogo: _uploadPic.image logoImage: kLogoImage text: _txtView.text alpha: 1];
            }
            
        }
        
    } else {   // 此else对应判断是否有图片
        // 1.2没有图片，提示用户添加图片
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle: @"没有选取图片" message: @"没有图片！" delegate: self cancelButtonTitle: @"确定" otherButtonTitles: nil, nil];
        [alter show];
    }
}

#pragma mark - “保存到相册”按钮点击事件
- (void)saveToAlbum
{
    // 1.检测是否有图片
    if(_uploadPic.image) {
        // 1.1有图片，则将图片保存至相册
        // 将图片转换成数据
        //NSData *imageData = UIImageJPEGRepresentation(_uploadPic.image, 1);
        // 保存至相册
        UIImageWriteToSavedPhotosAlbum(_uploadPic.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    } else {
        // 1.2没有图片，弹出提示框
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle: @"没有图片" message: @"没有图片！" delegate: self cancelButtonTitle: @"确定" otherButtonTitles: nil, nil];
        [alter show];
    }
}

#pragma mark - 将图片保存
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *) contextInfo
{
    NSLog(@"error = %@",error);
    // 保存到相册之后会调用这个方法
    // 在保存完成之后，应该弹出用户提示框，并且在没有出错的情况下弹出成功信息
    if(error == nil) {
        // 弹出成功信息
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle: @"保存成功" message: @"保存到相册成功!" delegate: self cancelButtonTitle: @"确定" otherButtonTitles: nil, nil];
        [alter show];
        // 成功之后，将文字清空
        _txtView.text = nil;
    } else {
        // 弹出失败信息
        UIAlertView *alter = [[UIAlertView alloc] initWithTitle: @"保存失败" message: @"保存失败!" delegate: self cancelButtonTitle: @"确定" otherButtonTitles: nil, nil];
        [alter show];
    }
}

/*
 方法1：通过点击屏幕其他地方来关闭键盘
 注意：次方法点击屏幕其他区域必须为View
 */
#pragma mark - 当输入文字，键盘出现时，点击屏幕其他地方，关闭键盘
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // 键盘出现时，当点击非输入区域，关闭键盘
    if(![_txtView isExclusiveTouch]) {
        [_txtView resignFirstResponder];
    }
    
    // 点击图片区域，出现一层蒙版，可以切换图片
    CGPoint picPoint = [[touches anyObject] locationInView: _uploadPic];
    CGRect picRect = CGRectMake(0, 0, _uploadPic.frame.size.width, _uploadPic.frame.size.height);
    if(CGRectContainsPoint(picRect, picPoint)) {
        // 点击了图片
        // 首先判断是否已经有图片
        if(_uploadPic.image) {
            // 有图片，添加一层UIControl，设置可以换其他图片
            _changePic = [[UIControl alloc] init];
            _changePic.frame = CGRectMake(0, 0, _uploadPic.frame.size.width, _uploadPic.frame.size.height);
            [_changePic setBackgroundColor: [UIColor colorWithWhite: 0 alpha: 0.7]];
            [_changePic addTarget: self action: @selector(changePicture) forControlEvents: UIControlEventTouchUpInside];
            
            _tipLabel.text = @"切换图片";
            _tipLabel.textColor = [UIColor whiteColor];
            [_changePic addSubview: _tipLabel];
            
            [_uploadPic addSubview: _changePic];
        } else {
            // 没有图片，去相册取图片
            [self addPic];
        }
    }
}

/*
 方法2：通过在键盘出现后添加一个“关闭键盘”按钮，通过点击按钮关闭键盘
 */
#pragma mark - 点击按钮关闭键盘
- (void)hideKeyBoard
{
    [_btnDone removeFromSuperview];
    _btnDone = nil;
    [_txtView resignFirstResponder];
}

#pragma mark - UIControl空白地方点击，可以切换图片
- (void)changePicture
{
    // 蒙版去掉
    [_changePic removeFromSuperview];
    // 再次进入相册选取
    [self addPic];
}

@end

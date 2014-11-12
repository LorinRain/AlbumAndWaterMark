iOS_AlbumAndWaterMark
=====================

访问相册摄像头保存图片至相册以及图片加水印

------------------访问相册摄像头---------------

在ViewController.h中：

@interface ViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, retain) UIImagePickerController *imagePicker;
@property(nonatomic,retain)UIImageView* imageview1;

@end

在ViewController.m中：

    //----------1 从网络加载图片
    imageview1 = [[UIImageView alloc]initWithFrame:CGRectMake(10, 50, 300, 200)];
    imageview1.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:imageview1];
    NSURL* url = [[NSURL alloc]initWithString:@"https://www.google.com.hk/images/srpr/logo11w.png"];
    NSData* data = [NSData dataWithContentsOfURL:url];
    //把data转成image
    UIImage* image = [UIImage imageWithData:data];
    //显示图片
    imageview1.image = image;
     
    //把图片转化为数据
    NSData* imagedata = UIImageJPEGRepresentation(image, 1);
    NSLog(@"%d",imagedata.length);
     
    //保存到相册里面，这个可以到模拟器里的相册产查看的。
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
     
    //---------2 相册的访问
     
    UIButton *buttonphoto = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    buttonphoto.tag = 100;
    buttonphoto.frame = CGRectMake(50, 250, 80, 50);
    [buttonphoto setTitle:@"访问相册" forState:UIControlStateNormal];
    [buttonphoto addTarget:self action:@selector(look:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttonphoto];
     
    //---------3 摄像头的访问
    UIButton *buttoncamera = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    buttoncamera.tag = 200;
    buttoncamera.frame = CGRectMake(50, 310, 80, 50);
    [buttoncamera setTitle:@"访问摄像头" forState:UIControlStateNormal];
    [buttoncamera addTarget:self action:@selector(look:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:buttoncamera];
    
    // 访问相册以及摄像头
    -(void)look:(UIButton*)button
    {
        if (button.tag == 100) {
            imagepicker = [[UIImagePickerController alloc]init];
            imagepicker.delegate = self;
            //访问相册类型的类型
            //UIImagePickerControllerSourceTypePhotoLibrary,
            //UIImagePickerControllerSourceTypeCamera, =====  访问摄像头
            //UIImagePickerControllerSourceTypeSavedPhotosAlbum ======= 只能访问第一列的图片
            imagepicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            //以摩擦动画的方式显示
            [self presentViewController:imagepicker animated:YES completion:^{
                 
            }];
     
        }else {
             
            //注意摄像头的访问需要在真机上进行
             
            //UIImagePickerControllerCameraDeviceFront === 前摄像头
            //UIImagePickerControllerCameraDeviceRear === 后摄像头
            BOOL isCamrma = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear];
            if (!isCamrma) {
                NSLog(@"没有摄像头");
                return;
            }
            //摄像头
            imagepicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            //允许编辑
            imagepicker.allowsEditing =YES;
        }
    }

//---------2 相册的访问
#pragma mark - UIImagePickerControllerDelegate
 
 
//相册选中之后调用
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //UIImagePickerControllerOriginalImage === 取原始图片
    //UIImagePickerControllerEditedImage === 去编辑以后的图片
    UIImage* image = [info objectForKey:UIImagePickerControllerEditedImage];
    imageview1.image = image;
    NSLog(@"info = %@",info);
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//取消按钮的点击事件
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

//将图片保存
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSLog(@"error = %@",error);
}
 

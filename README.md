iOS_AlbumAndWaterMark
=====================

访问相册摄像头保存图片至相册以及图片加水印


#pragma mark - 访问相册摄像头
----------------------------访问相册摄像头---------------------------

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
 


#pragma mark - 图片加水印
----------------------------图片加水印---------------------------

1.加文字

    - (UIImage *)imageWithLogoText:(UIImage *)img text:(NSString *)text1
    {     
        /////注：此为后来更改，用于显示中文。zyq,2013-5-8
        CGSize size = CGSizeMake(200, img.size.height);          //设置上下文（画布）大小
        UIGraphicsBeginImageContext(size);                       //创建一个基于位图的上下文(context)，并将其设置为当前上下文
        CGContextRef contextRef = UIGraphicsGetCurrentContext(); //获取当前上下文
        CGContextTranslateCTM(contextRef, 0, img.size.height);   //画布的高度
        CGContextScaleCTM(contextRef, 1.0, -1.0);                //画布翻转
        CGContextDrawImage(contextRef, CGRectMake(0, 0, img.size.width, img.size.height), [img CGImage]);  //在上下文种画当前图片
         
        [[UIColor redColor] set];                                //上下文种的文字属性
        CGContextTranslateCTM(contextRef, 0, img.size.height);
        CGContextScaleCTM(contextRef, 1.0, -1.0);
        UIFont *font = [UIFont boldSystemFontOfSize:16];
        [text1 drawInRect:CGRectMake(0, 0, 200, 80) withFont:font];       //此处设置文字显示的位置
        UIImage *targetimg =UIGraphicsGetImageFromCurrentImageContext();  //从当前上下文种获取图片
        UIGraphicsEndImageContext();                            //移除栈顶的基于当前位图的图形上下文。
        return targetimg;
         
         
        //注：此为原来，不能显示中文。无用。
        //get image width and height
        int w = img.size.width;
        int h = img.size.height;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        //create a graphic context with CGBitmapContextCreate
        CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
        CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
        CGContextSetRGBFillColor(context, 0.0, 1.0, 1.0, 1);
        char* text = (char *)[text1 cStringUsingEncoding:NSUnicodeStringEncoding];
        CGContextSelectFont(context, "Georgia", 30, kCGEncodingMacRoman);
        CGContextSetTextDrawingMode(context, kCGTextFill);
        CGContextSetRGBFillColor(context, 255, 0, 0, 1);
        CGContextShowTextAtPoint(context, w/2-strlen(text)*5, h/2, text, strlen(text));
        //Create image ref from the context
        CGImageRef imageMasked = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        return [UIImage imageWithCGImage:imageMasked];
     
    }
    
2.新的添加文字水印的方法一

    - (UIImage *) imageWithStringWaterMark:(NSString *)markString inRect:(CGRect)rect color:(UIColor *)color font:(UIFont *)font
    {
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
        {
            UIGraphicsBeginImageContextWithOptions([self size], NO, 0.0); // 0.0 for scale means "scale for device's main screen".
        }
    #else
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0)
        {
            UIGraphicsBeginImageContext([self size]);
        }
    #endif
         
        //原图
        [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
         
        //文字颜色
        [color set];
         
        //水印文字
        [markString drawInRect:rect withFont:font];
         
        UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
         
        return newPic;
    }

3.还是添加文字水印方法二

    - (UIImage *) imageWithStringWaterMark:(NSString *)markString atPoint:(CGPoint)point color:(UIColor *)color font:(UIFont *)font
    {
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
        {
            UIGraphicsBeginImageContextWithOptions([self size], NO, 0.0); // 0.0 for scale means "scale for device's main screen".
        }
    #else
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0)
        {
            UIGraphicsBeginImageContext([self size]);
        }
    #endif
         
        //原图
        [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
         
        //文字颜色
        [color set];
         
        //水印文字
        [markString drawAtPoint:point withFont:font];
         
        UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
         
        return newPic;
    }
    
4.加图片

    -(UIImage *)imageWithLogoImage:(UIImage *)img logo:(UIImage *)logo
    {
        //get image width and height
        int w = img.size.width;
        int h = img.size.height;
        int logoWidth = logo.size.width;
        int logoHeight = logo.size.height;
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        //create a graphic context with CGBitmapContextCreate
        CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
        CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
        CGContextDrawImage(context, CGRectMake(w-logoWidth, 0, logoWidth, logoHeight), [logo CGImage]);
        CGImageRef imageMasked = CGBitmapContextCreateImage(context);
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        return [UIImage imageWithCGImage:imageMasked];
        //  CGContextDrawImage(contextRef, CGRectMake(100, 50, 200, 80), [smallImg CGImage]);
    }
    
5.新的添加图片水印的方法

    - (UIImage *) imageWithWaterMask:(UIImage*)mask inRect:(CGRect)rect
    {
    #if __IPHONE_OS_VERSION_MAX_ALLOWED >= 40000
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
        {
            UIGraphicsBeginImageContextWithOptions([self size], NO, 0.0); // 0.0 for scale means "scale for device's main screen".
        }
    #else
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 4.0)
        {
            UIGraphicsBeginImageContext([self size]);
        }
    #endif
         
        //原图
        [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
        //水印图
        [mask drawInRect:rect];
         
        UIImage *newPic = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
         
        return newPic;
    }
    
6 .加半透明的水印

    //加半透明的水印
    -(UIImage *)imageWithTransImage:(UIImage *)useImage addtransparentImage:(UIImage *)transparentimg
    {
        UIGraphicsBeginImageContext(useImage.size);
        [useImage drawInRect:CGRectMake(0, 0, useImage.size.width, useImage.size.height)];
        [transparentimg drawInRect:CGRectMake(0, useImage.size.height-transparentimg.size.height, transparentimg.size.width, transparentimg.size.height) blendMode:kCGBlendModeOverlay alpha:0.4f];
         
        UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return resultingImage;
    }

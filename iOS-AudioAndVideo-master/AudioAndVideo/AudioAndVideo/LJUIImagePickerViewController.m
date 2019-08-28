//
//  LJUIImagePickerViewController.m
//  AudioAndVideo
//
//  Created by LiJie on 2017/2/20.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "LJUIImagePickerViewController.h"

@interface LJUIImagePickerViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property(nonatomic,strong)UIImagePickerController *imagePickerViewController;
@end

@implementation LJUIImagePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
    
}

- (void)setupUI {
    UIButton *takePhotoButton = [self produceButtonWithTitle:@"拍照"];
    UIButton *photoAlbumButton = [self produceButtonWithTitle:@"相册"];
    UIButton *recordVideoButton = [self produceButtonWithTitle:@"录像"];
   __weak __typeof(self)weakSelf = self;
    [takePhotoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        make.centerX.mas_equalTo(strongSelf.view.mas_centerX);
        make.centerY.mas_equalTo(strongSelf.view.mas_centerY).offset(-100);
    }];
    
    [photoAlbumButton mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        make.centerX.mas_equalTo(strongSelf.view.mas_centerX);
        make.centerY.mas_equalTo(strongSelf.view.mas_centerY);
    }];
    
    [recordVideoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        make.centerX.mas_equalTo(strongSelf.view.mas_centerX);
        make.centerY.mas_equalTo(strongSelf.view.mas_centerY).offset(100);
    }];
}

#pragma mark - produceButton
- (UIButton *)produceButtonWithTitle:(NSString *)title {
    UIButton *button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor purpleColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClickWithButton:) forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    [self.view addSubview:button];
    return button;
}

#pragma mark - buttonClick
- (void)buttonClickWithButton:(UIButton *)button {
    if ([button.currentTitle isEqualToString:@"拍照"]) {
        [self produceImagePickerControllerWithSourceType:UIImagePickerControllerSourceTypeCamera CameraCaptureMode:UIImagePickerControllerCameraCaptureModePhoto];
    }else if ([button.currentTitle isEqualToString:@"录像"]) {
        [self produceImagePickerControllerWithSourceType:UIImagePickerControllerSourceTypeCamera CameraCaptureMode:UIImagePickerControllerCameraCaptureModeVideo];
    } else {
        [self produceImagePickerControllerWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary CameraCaptureMode:0];
    }
}

#pragma mark - produceImagePickerController
- (void)produceImagePickerControllerWithSourceType:(UIImagePickerControllerSourceType)sourceType CameraCaptureMode:(UIImagePickerControllerCameraCaptureMode)mode {
    _imagePickerViewController = [[UIImagePickerController alloc] init];
    //资源的来源
    _imagePickerViewController.sourceType = sourceType;
    //这是 VC 的各种 modal 形式
    _imagePickerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    //支持的摄制类型,拍照或摄影,此处将本设备支持的所有类型全部获取,并且同时赋值给imagePickerController的话,则可左右切换摄制模式
    _imagePickerViewController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];
    _imagePickerViewController.delegate = self;
    //允许拍照后编辑
    _imagePickerViewController.allowsEditing = YES;
    //显示相机的 UI 样式, 默认是系统的, YES
    //    imagePickerViewController.showsCameraControls = NO;
    //拍照
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        //设置模式 - 拍照
        _imagePickerViewController.cameraCaptureMode = mode;
        //默认开启的摄像头, 前, 后
        _imagePickerViewController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        //设置默认的闪光灯模式-->开/关/自动
        _imagePickerViewController.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        //拍摄时预览view的transform属性，可以实现旋转，缩放功能
//        imagePickerViewController.cameraViewTransform = CGAffineTransformMakeRotation(M_PI);
//        imagePickerViewController.cameraViewTransform = CGAffineTransformMakeScale(2.0,2.0);
        
        //自定义界面上的覆盖物, 类似于头像等, 眼睛等
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timg.jpeg"]];
        imageView.width = 200;
        imageView.height = 200;
        _imagePickerViewController.cameraOverlayView = imageView;
    } else {
        NSLog(@"相册");
    }
    [self presentViewController:_imagePickerViewController animated:YES completion:nil];
}

//取消屏幕旋转
- (BOOL)shouldAutorotate {
    return NO;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    //如果[mediaType isEqualToString:@"public.image"] 是图片或拍照  [mediaType isEqualToString:@"public.movie"]是视频
    if ([mediaType isEqualToString:@"public.image"]) {
        //获取图片裁剪的图
        UIImage* editImage = [info objectForKey:UIImagePickerControllerEditedImage];
        [self saveImage:editImage];
    } else{
        NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
        NSString *urlStr=[url path];
        [self saveWithVideoPath:urlStr];
    }
    [_imagePickerViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [_imagePickerViewController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 保存图片
- (void)saveImage: (UIImage *)image{
    //保存到相册的第一种方式 iOS 9.0 之后过期
    [[ALAssetsLibrary alloc] writeImageToSavedPhotosAlbum:image.CGImage orientation:(ALAssetOrientation)image.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"Save image fail：%@",error);
        }else{
            NSLog(@"Save image succeed.");
        }
    }];
    
    //保存到相册的第二种方式
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    //保存到相册的第三种方式
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //写入图片到相册
       [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        NSLog(@"success = %d, error = %@", success, error);
    }];
}

#pragma mark - 保存视频
- (void)saveWithVideoPath:(NSString *)videoPath {
    //保存到相册的第一种方式: iOS 9.0 之后过期
    [[ALAssetsLibrary alloc] writeVideoAtPathToSavedPhotosAlbum:[NSURL URLWithString:videoPath] completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"Save video fail：%@",error);
        }else{
            NSLog(@"Save video succeed.");
        }
    }];
    
    //保存到相册的第二种方式 :
        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath)) {
            //保存视频到相簿，
            UISaveVideoAtPathToSavedPhotosAlbum(videoPath, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);//保存视频到相簿
        }else{
            NSLog(@"您的设备不支持保存视频到相册");
        }
}


- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    
    if (error) {
        NSLog(@"保存照片过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"照片保存成功.");
    }
}

- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功.");
    }
}



@end

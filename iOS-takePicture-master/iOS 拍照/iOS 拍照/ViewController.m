//
//  ViewController.m
//  iOS 拍照
//
//  Created by LiJie on 2017/2/10.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <SystemConfiguration/SystemConfiguration.h>

@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property(nonatomic,strong) UIImagePickerController *imagePickerController;
@property(nonatomic,strong) UIImage *image;
@property(nonatomic,strong) UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    button.center = self.view.center;
    [button addTarget:self action:@selector(setupPickerControllrt) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"点击拍照" forState: UIControlStateNormal];
    [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 310, 200, 200)];
    [self.view addSubview:_imageView];

    
}


#pragma mark - 跳转
- (void)setupPickerControllrt {
    //提示音
    SystemSoundID soundID;
    NSString *strSoundFile = [[NSBundle mainBundle] pathForResource:@"ZR436" ofType:@"WAV"];
    if (strSoundFile) {
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:strSoundFile],&soundID);
    }
    AudioServicesPlaySystemSound(soundID);
    
    _imagePickerController = [[UIImagePickerController alloc] init];
    _imagePickerController.view.backgroundColor = [UIColor whiteColor];
    _imagePickerController.delegate = self;
    _imagePickerController.allowsEditing = YES;
    
    //判断是否有摄像头
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else {
        _imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    
    //解决present 时卡住的问题
    _imagePickerController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    // presentViewController 方式
    [self presentViewController:_imagePickerController animated:YES completion:nil];
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo NS_DEPRECATED_IOS(2_0, 3_0) {
    
}

//图片选择结束
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (image == nil) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    //保存到相册
    UIImageWriteToSavedPhotosAlbum(image, self,@ selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    if ([self saveImageWithImage:image pathName:@"image"]) {
        [_imagePickerController dismissViewControllerAnimated:YES completion:nil];
        //读取图片
        _imageView.image = [self readImageFromBoxWithPathName:@"image"];

    } else {
        NSLog(@"保存失败");
        [_imageView removeFromSuperview];
        _imageView = nil;
        [_imagePickerController dismissViewControllerAnimated:YES completion:nil];
    }
}

//退出选择
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [_imagePickerController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 保存图片到沙盒
- (BOOL)saveImageWithImage:(UIImage *)image pathName:(NSString *)pathName {
    //保存到沙盒的路径
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[pathArray objectAtIndex:0] stringByAppendingPathComponent:pathName];
    //保存文件
    BOOL result = [UIImagePNGRepresentation(image)writeToFile: filePath atomically:YES];
    return result;
}

#pragma mark -读取图片
- (UIImage *)readImageFromBoxWithPathName:(NSString *)pathName {
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *filePath = [[pathArray objectAtIndex:0] stringByAppendingPathComponent:pathName];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    UIImage *image = [UIImage imageWithData:data];
    return image;
}

//用于上传图片到服务器
#pragma mark -  图片处理
- (NSData *)imageProcessWithImage:(UIImage *)image {
    NSData *data=UIImageJPEGRepresentation(image, 1.0);
    NSData *imageData = [NSData data];
    if (data.length>100*1024) {
        if (data.length>1024*1024) {//1M以及以上
            imageData=UIImageJPEGRepresentation(image, 0.1);
        }else if (data.length>512*1024) {//0.5M-1M
            imageData=UIImageJPEGRepresentation(image, 0.4);
        }else if (data.length>200*1024) {//0.25M-0.5M
            imageData=UIImageJPEGRepresentation(image, 0.6);
        }
}
    return imageData;
}

#pragma mark - 保存到相册的回调方法
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error == NULL)
    {
        NSLog(@"保存到相册成功");
    }
    else
    {
        NSLog(@"保存到相册失败");
    }
}
 @end


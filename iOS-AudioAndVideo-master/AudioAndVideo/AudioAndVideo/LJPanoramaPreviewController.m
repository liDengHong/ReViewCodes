//
//  LJPanoramaPreviewController.m
//  AudioAndVideo
//
//  Created by LiJie on 2017/2/16.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "LJPanoramaPreviewController.h"
/**< 必须导入AVFoundation框架 >**/
#import <AVFoundation/AVFoundation.h>

/**< 查看真机沙盒文件的方法:   连上你的设备，windows-> devices，选择你的设备，右边installed apps，选择你的APP，download container
 下载的文件，显示包内容，即是沙盒内的文件  >**/

@interface LJPanoramaPreviewController ()<AVCaptureFileOutputRecordingDelegate,UIAlertViewDelegate>
@property(nonatomic,strong)AVCaptureSession *captureSession;                         /**< 会话层 >**/
@property(nonatomic,strong)AVCaptureDeviceInput *captureDeviceInput;               /**< 输入设备 >**/
@property(nonatomic,strong)AVCaptureMovieFileOutput *captureMovieFileOutput;     /**< 视屏输出 >**/
@property(nonatomic,strong)AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;/**< 相机拍摄预览图层 >**/
@property(nonatomic,strong)UIAlertView *alertView;
@end

@implementation LJPanoramaPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //    self.captureSession = ({
    //
    //        AVCaptureSession *session = [[AVCaptureSession alloc] init];
    //        if ([session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
    //            [session setSessionPreset:AVCaptureSessionPresetHigh];
    //        }
    //        session;
    //    });
    NSError *error = nil;
    [self setupSessionInputs:error];
    
    //初始化设备输出对象，用于获得输出数据
    self.captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    AVCaptureConnection *captureConnection = [self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
    if ([captureConnection isVideoStabilizationSupported]) {
        captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
    if ([self.captureSession canAddOutput:self.captureMovieFileOutput]) {
        [self.captureSession addOutput:self.captureMovieFileOutput];
    }
    
    //初始化展示层
    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    _captureVideoPreviewLayer.frame=  CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    _captureVideoPreviewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;//填充模式
    [self.view.layer addSublayer:self.captureVideoPreviewLayer];
    self.view.layer.masksToBounds = YES;
    //开启会话层
    [self.captureSession startRunning];
    
    
}
#pragma mark - 初始化输入设备
- (BOOL)setupSessionInputs:(NSError *)error {
    // 添加摄像头
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:&error];
    // 判断是否存在摄像头或有权限打开
    if (!videoInput) {
        return NO;
    }
    // 判断是否能添加到会话层
    if ([self.captureSession canAddInput:videoInput]) {
        [self.captureSession addInput:videoInput];
    } else {
        return NO;
    }
    
    // 添加话筒
    AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:&error];
    // 判断是否存在或有权限打开话筒
    if (!audioInput) {
        return NO;
    }
    //判断是否能添加到会话层
    if ([self.captureSession canAddInput:audioInput]) {
        [self.captureSession addInput:audioInput];
    } else {
        return NO;
    }
    return YES;
    
}

#pragma mark - 初始化输入设备
- (AVCaptureSession *)captureSession {
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
        //设置分辨率
        if ([_captureSession canSetSessionPreset:AVCaptureSessionPresetHigh]) {
            [_captureSession canSetSessionPreset:AVCaptureSessionPresetHigh];
        }
    }
    return _captureSession;
}

#pragma mark -  开始录制视频
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (![self.captureMovieFileOutput isRecording]) {
        
        _alertView = [[UIAlertView alloc] initWithTitle:@"录制视频" message:@"是否录制?" delegate: self cancelButtonTitle:@"取消" otherButtonTitles:@"录制", nil];
        [_alertView show];
        
    }else{
        _alertView = [[UIAlertView alloc] initWithTitle:@"结束录制" message:@"是否结束录制?" delegate: self cancelButtonTitle:@"取消" otherButtonTitles:@"结束", nil];
        [_alertView show];
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    [self videoCompression];
}

-(void)videoCompression{
    NSURL *tempUrl = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"temp.mp4"]];
    //加载视频资源
    AVAsset *asset = [AVAsset assetWithURL:tempUrl];
    //创建视屏资源导出会话
    AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
    //创建导出视屏的 url
    session.outputURL = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingPathComponent:@"tempLow.mp4"]];
    //必须配置输出属性
    session.outputFileType = AVFileTypeMPEG4;
    [session exportAsynchronouslyWithCompletionHandler:^{
                NSLog(@"导出结束");
    }];
}


//方便测试,清除沙盒
- (void)dealloc {
    NSString *path =[NSTemporaryDirectory() stringByAppendingString:@"temp.mp4"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([_alertView.title isEqualToString:@"录制视频"]) {
        if (buttonIndex == 0) { return;
        } else {  NSLog(@"开始录制了");
            AVCaptureConnection *captureConnection=[self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            captureConnection.videoOrientation=[self.captureVideoPreviewLayer connection].videoOrientation;
            [self.captureMovieFileOutput startRecordingToOutputFileURL:({
                // 录制 缓存地址。
                NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.mp4"]];
                if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {			}
                url;
            }) recordingDelegate:self];
        }
        }else if ([_alertView.title isEqualToString:@"结束录制"]) {
            if (buttonIndex == 0) {  return;
        } else {
            NSLog(@"结束录制了");
            [self.captureMovieFileOutput stopRecording];//停止录制
        }
        } else {
            return;
        }
}

@end

//
//  LJRecorder.m
//  AudioAndVideo
//
//  Created by LiJie on 2017/3/7.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "LJRecorder.h"
#import "LJRecordEncoder.h"

@interface LJRecorder()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate, CAAnimationDelegate> {
    CMTime _timeOffset;//录制的偏移CMTime
    CMTime _lastVideo;//记录上一次视频数据文件的CMTime
    CMTime _lastAudio;//记录上一次音频数据文件的CMTime
    
    NSInteger _resolutionWidth;//视频分辨的宽
    NSInteger _resolutionHeight;//视频分辨的高
    int _channels;//音频通道
    Float64 _samplerate;//音频采样率
}

@property(nonatomic,strong) LJRecordEncoder *encoder;  /**< 编码 >**/
@property(nonatomic,strong) AVCaptureSession *session; /**< 捕捉会话 >**/
@property(nonatomic,strong) AVCaptureVideoPreviewLayer *previewLayer; /**< 显示 layer >**/
@property(nonatomic,strong) AVCaptureDeviceInput *frontCameraInput; /**< 前置摄像头 >**/
@property(nonatomic,strong) AVCaptureDeviceInput *backCameraInput; /**< 后置摄像头 >**/
@property(nonatomic,strong) AVCaptureDeviceInput *micInput; /**< 麦克风输入 >**/
@property(nonatomic,copy) dispatch_queue_t queue; /**< 录制队列 >**/
@property(nonatomic,strong) AVCaptureConnection *audioConnection; /**< 音频连接 >**/
@property(nonatomic,strong) AVCaptureConnection *videoConnection; /**< 视频连接 >**/
@property(nonatomic,strong) AVCaptureAudioDataOutput *audioDataOutput; /**< 音频输出 >**/
@property(nonatomic,strong) AVCaptureVideoDataOutput *videoDataOutput; /**< 视频输出 >**/
@property(atomic,assign) BOOL isIntermit; /**< 是否中断 >**/

@property (atomic, assign) CMTime startTime;  /**< 开始录制的时间 >**/
@property (atomic, assign) CGFloat currentRecordTime;  /**< 当前录制时间 >**/

@end

@implementation LJRecorder

- (instancetype)init
{
    self = [super init];
    if (self) {
        //最长的录制时间是60s
        _maxRecordTime = 60.0f;
    }
    return self;
}

#pragma mark - 开启,关闭录制功能
/**< 启动录制功能 >**/
- (void)startUp {
    _isIntermit = NO;
    _isRecording = NO;
    _isPauseing = NO;
    _startTime = CMTimeMake(0, 0);
    [self.session startRunning];
}

/**< 关闭录制功能 >**/
- (void)shutDown {
    _startTime = CMTimeMake(0, 0);
    if (_session) {
        [_session stopRunning];
        [_encoder recordFinishWithCompletionHandler:^{
            NSLog(@"录制结束");
        }];
    }
}

#pragma mark - 操作

/**< 开始录制 >**/
- (void)startRecord {
    //添加互斥锁确保线程安全
    @synchronized (self) {
        if (!_isRecording) {
            NSLog(@"开始录制");
            _encoder = nil;
            _isPauseing = NO;
            _isIntermit = NO;
            _isRecording = YES;
            _timeOffset = CMTimeMake(0, 0);
            _isRecording = YES;
            
        }
    }
}

/**< 暂停录制 >**/
- (void)pauseRecord {
    @synchronized (self) {
        if (_isRecording) {
            NSLog(@"暂停录制");
            _isIntermit = YES;
            _isPauseing = YES;
        }
    }
}

/**< 继续录制 >**/
- (void)resumeRecord {
    @synchronized (self) {
        if (_isPauseing) {
            _isPauseing = NO;
        }
    }
}

/**< 停止录制 >**/
- (void)stopRecordHandler:(void(^)(UIImage *oneVideoPicture))handler {
    @synchronized (self) {
        if (_isRecording) {
            NSURL *url =[NSURL fileURLWithPath:self.encoder.path];
            _isRecording = NO;
            dispatch_async(self.queue, ^{
                [self.encoder recordFinishWithCompletionHandler:^{
                    self.encoder = nil;
                    self.startTime = CMTimeMake(0, 0);
                    self.currentRecordTime = 0;
                    if ([self.delegate respondsToSelector:@selector(recordProgress:)]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.delegate recordProgress:self.currentRecordTime/self.maxRecordTime];
                        });
                    }
                    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
                    } completionHandler:^(BOOL success, NSError * _Nullable error) {
                        NSLog(@"保存成功");
                    }];
                    [self getOneVideoPicture:handler];
                }];
            });
        }
    }
}

/**< 开启闪光灯 >**/
- (void)openFlashLight {
    //只有在后置摄像头才能开启摄像头
    AVCaptureDevice *device = [self backCamera];
    //必须锁定
    
    if (device.torchMode == AVCaptureTorchModeOff) {
        [device lockForConfiguration:nil];
        device.torchMode = AVCaptureTorchModeOn;
        device.flashMode = AVCaptureFlashModeOn;
        [device unlockForConfiguration];
    }
}

/**< 关闭闪光灯 >**/
- (void)closeFlashLight {
    AVCaptureDevice *device = [self backCamera];
    if (device.torchMode == AVCaptureTorchModeOn) {
        [device lockForConfiguration:nil];
        device.torchMode = AVCaptureTorchModeOff;
        device.flashMode = AVCaptureFlashModeOff;
        [device unlockForConfiguration];
    }
}

#pragma mark - 转换格式, 获取每一帧
/**< 将mov的视频转成mp4 >**/
- (void)changeMovtoMp4:(NSURL *)videoURL handler:(void (^)(UIImage *videoPicture))handler {
    AVAsset *videoAsset = [AVAsset assetWithURL:videoURL];
    AVAssetExportSession *exportSession = [AVAssetExportSession exportSessionWithAsset:videoAsset presetName:AVAssetExportPreset1280x720];
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.outputFileType = AVFileTypeMPEG4;
    self.videoPath = [[self getFilePath] stringByAppendingPathComponent:[self setFileNameWithVideoType:@"mp4"]];
    exportSession.outputURL = [NSURL fileURLWithPath:self.videoPath];
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        [self getOneVideoPicture:handler];
    }];
}

/**< 获取视频的第一帧 >**/
- (void)getOneVideoPicture:(void(^)(UIImage *videoPicture))handler {
    NSURL *url = [NSURL fileURLWithPath:self.videoPath];
    AVURLAsset *asset = [[AVURLAsset  alloc] initWithURL:url options:nil];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = TRUE;
    CMTime time = CMTimeMakeWithSeconds(0, 60);
    imageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    AVAssetImageGeneratorCompletionHandler generatorHandler =  ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result == AVAssetImageGeneratorSucceeded) {
            UIImage *firstImage = [UIImage imageWithCGImage:im];
            if (handler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    handler(firstImage);
                });
            }
        }
    };
    
    [imageGenerator generateCGImagesAsynchronouslyForTimes:
     [NSArray arrayWithObject:[NSValue valueWithCMTime:time]] completionHandler:generatorHandler];
}


#pragma mark - 切换动画
- (void)changeCameraAnimation {
    CATransition *animation = [CATransition animation];
    animation.delegate = self;
    animation.duration = 0.5;
    animation.type = @"oglFlip";
    animation.subtype = kCATransitionFromLeft;
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    [self.previewLayer addAnimation:animation forKey:@"anmiation"];
    
}

/**< CAAnimationDelegate >**/
- (void)animationDidStart:(CAAnimation *)anim {
    self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    [self.session startRunning];
}

#pragma mark - getter

/**< 捕捉会话 >**/
- (AVCaptureSession *)session {
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
        //添加硬件设备流
        if ([_session canAddInput:self.backCameraInput]) {
            [_session addInput:self.backCameraInput];
        }
        if ([_session canAddInput:self.micInput]) {
            [_session addInput:self.micInput];
            
            _resolutionWidth = 720;
            _resolutionHeight = 1280;
        }
        if ([_session canAddOutput:self.videoDataOutput]) {
            [_session addOutput:self.videoDataOutput];
        }
        if ([_session canAddOutput:self.audioDataOutput]) {
            [_session addOutput:self.audioDataOutput];
        }
        //设置视频录制的方向
        self.videoConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    return _session;
}

- (AVCaptureDeviceInput *)backCameraInput {
    if (!_backCameraInput) {
        NSError *error;
        _backCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backCamera] error:&error];
        if (error) {
            NSLog(@"获取后置摄像头失败");
        }
    }
    return _backCameraInput;
}

- (AVCaptureDeviceInput *)frontCameraInput {
    if (!_frontCameraInput) {
        NSError *error;
        _frontCameraInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontCamera] error:&error];
        if (error) {
            NSLog(@"获取前置摄像头失败");
        }
    }
    return _frontCameraInput;
}

- (AVCaptureDeviceInput *)micInput {
    if (!_micInput) {
        NSError *error;
        AVCaptureDevice *micDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
        _micInput = [[AVCaptureDeviceInput alloc] initWithDevice:micDevice error:&error];
        if (error) {
            NSLog(@"获取麦克风失败");
        }
    }
    return _micInput;
}

- (dispatch_queue_t)queue {
    if (!_queue) {
        //        此处应为串行队列, 配合@synchronized确保线程安全
        _queue = dispatch_queue_create("cn.lijie.video",  DISPATCH_QUEUE_SERIAL);
    }
    return _queue;
}

- (AVCaptureConnection *)audioConnection {
    if (!_audioConnection) {
    }
    return _audioConnection;
}

- (AVCaptureConnection *)videoConnection {
    if (!_videoConnection) {
        _videoConnection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    }
    return _videoConnection;
}

- (AVCaptureVideoDataOutput *)videoDataOutput {
    if (!_videoDataOutput) {
        _videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        [_videoDataOutput setSampleBufferDelegate:self queue:self.queue];
    }
    NSDictionary* setcapSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange], kCVPixelBufferPixelFormatTypeKey,
                                    nil];
    _videoDataOutput.videoSettings = setcapSettings;
    return _videoDataOutput;
}

- (AVCaptureAudioDataOutput *)audioDataOutput {
    if (!_audioDataOutput) {
        _audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
        [_audioDataOutput setSampleBufferDelegate:self queue:self.queue];
    }
    return _audioDataOutput;
}

/**< 呈现视频的 layer >**/
- (AVCaptureVideoPreviewLayer *)previewLayer {
    
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

#pragma mark - 摄像头
/**< 后置摄像头 >**/
- (AVCaptureDevice *)backCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

/**< 前置摄像头 >**/
- (AVCaptureDevice *)frontCamera {
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

/**< 返回前后摄像头 >**/
- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition) position {
    NSArray *deviceArray = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in deviceArray) {
        if (device.position == position) {
            return device;
        }
    }
    return nil;
}

/**< 切换摄像头 >**/
- (void)changeCameraInputDeviceisBack:(BOOL)isBack {
    if (isBack) {
        [self.session stopRunning];
        [self.session removeInput:self.backCameraInput];
        if ([self.session canAddInput:self.frontCameraInput]) {
            [self.session addInput:self.frontCameraInput];
            [self changeCameraAnimation];
        }
    }else {
        [self.session stopRunning];
        [self.session removeInput:self.frontCameraInput];
        if ([self.session canAddInput:self.backCameraInput]) {
            [self.session addInput:self.backCameraInput];
            [self changeCameraAnimation];
        }
    }
}

#pragma mark - 储存相关
/**< 文件基本地址 (最好设置一个类别, 后面转换格式会用到)>**/
- (NSString *)getFilePath {
    NSString *pathString = [NSTemporaryDirectory() stringByAppendingPathComponent:@"myVideos"];
    //是否是一个文件夹
    BOOL isDirectory = NO;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL existed = [fileManager fileExistsAtPath:self.videoPath isDirectory:&isDirectory];
    if (!(isDirectory == YES && existed == YES)) {
        [fileManager createDirectoryAtPath:pathString withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return pathString;
}

/**< 文件命名 >**/
- (NSString *)setFileNameWithVideoType:(NSString *)videoType {
    //从1970到现在走过的秒数
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH-mm-ss"];
    //从1970年到现在的日期,
    NSDate *dateNow = [NSDate dateWithTimeIntervalSince1970:currentTime];
    NSString *timeStr = [formatter stringFromDate:dateNow];
    NSString *fileName = [NSString stringWithFormat:@"video_%@.%@",timeStr,videoType];
    return fileName;
}

#pragma mark - 调整
/**< 设置音频格式 >**/
- (void)setAudioFormat:(CMFormatDescriptionRef)audioFormat; {
    const  AudioStreamBasicDescription *audioDescription = CMAudioFormatDescriptionGetStreamBasicDescription(audioFormat);
    _samplerate = audioDescription -> mSampleRate;
    _channels = audioDescription -> mChannelsPerFrame;
}

/**< 调整媒体数据的时间,主要解决在不同平台的设备上播放卡的问题 >**/
- (CMSampleBufferRef)adjustTime:(CMSampleBufferRef)sample by:(CMTime)offset {
    CMItemCount count;
    CMSampleBufferGetSampleTimingInfoArray(sample, 0, nil, &count);
    CMSampleTimingInfo* pInfo = malloc(sizeof(CMSampleTimingInfo) * count);
    CMSampleBufferGetSampleTimingInfoArray(sample, count, pInfo, &count);
    for (CMItemCount i = 0; i < count; i++) {
        pInfo[i].decodeTimeStamp = CMTimeSubtract(pInfo[i].decodeTimeStamp, offset);
        pInfo[i].presentationTimeStamp = CMTimeSubtract(pInfo[i].presentationTimeStamp, offset);
    }
    CMSampleBufferRef sout;
    CMSampleBufferCreateCopyWithNewTiming(nil, sample, count, pInfo, &sout);
    free(pInfo);
    return sout;
}

#pragma mark - 写入数据
- (void) captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    BOOL isVideo = YES;
    @synchronized (self) {
        if (!self.isRecording || self.isPauseing) {
            return;
        }
        if (captureOutput != self.videoDataOutput) {
            isVideo = NO;
        }
        //初始化编码器，当有音频和视频参数时创建编码器
        if ((self.encoder == nil) && !isVideo) {
            CMFormatDescriptionRef fmt = CMSampleBufferGetFormatDescription(sampleBuffer);
            [self setAudioFormat:fmt];
            NSString *videoName = [self setFileNameWithVideoType:@"mp4"];
            self.videoPath = [[self getFilePath] stringByAppendingPathComponent:videoName];
            self.encoder = [LJRecordEncoder encoderForPath:self.videoPath resolutionHeight:_resolutionHeight resolutionWidth:_resolutionWidth videoChannels:_channels samples:_samplerate];
        }
        //判断是否中断录制过
        if (self.isIntermit) {
            if (isVideo) {
                return;
            }
            self.isIntermit = NO;
            // 计算暂停的时间
            CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            CMTime last = isVideo ? _lastVideo : _lastAudio;
            if (last.flags & kCMTimeFlags_Valid) {
                if (_timeOffset.flags & kCMTimeFlags_Valid) {
                    pts = CMTimeSubtract(pts, _timeOffset);
                }
                CMTime offset = CMTimeSubtract(pts, last);
                if (_timeOffset.value == 0) {
                    _timeOffset = offset;
                }else {
                    _timeOffset = CMTimeAdd(_timeOffset, offset);
                }
            }
            _lastVideo.flags = 0;
            _lastAudio.flags = 0;
        }
        // 增加sampleBuffer的引用计时,这样我们可以释放这个或修改这个数据，防止在修改时被释放
        CFRetain(sampleBuffer);
        if (_timeOffset.value > 0) {
            CFRelease(sampleBuffer);
            //根据得到的timeOffset调整
            sampleBuffer = [self adjustTime:sampleBuffer by:_timeOffset];
        }
        // 记录暂停上一次录制的时间
        CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        CMTime dur = CMSampleBufferGetDuration(sampleBuffer);
        if (dur.value > 0) {
            pts = CMTimeAdd(pts, dur);
        }
        if (isVideo) {
            _lastVideo = pts;
        }else {
            _lastAudio = pts;
        }
    }
    CMTime dur = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    if (self.startTime.value == 0) {
        self.startTime = dur;
    }
    CMTime sub = CMTimeSubtract(dur, self.startTime);
    self.currentRecordTime = CMTimeGetSeconds(sub);
    if (self.currentRecordTime > self.maxRecordTime) {
        if (self.currentRecordTime - self.maxRecordTime < 0.1) {
            if ([self.delegate respondsToSelector:@selector(recordProgress:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate recordProgress:self.currentRecordTime/self.maxRecordTime];
                });
            }
        }
        return;
    }
    if ([self.delegate respondsToSelector:@selector(recordProgress:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate recordProgress:self.currentRecordTime/self.maxRecordTime];
        });
    }
    // 进行数据编码
    [self.encoder encodeFrame:sampleBuffer isVideo:isVideo];
    CFRelease(sampleBuffer);
}

@end

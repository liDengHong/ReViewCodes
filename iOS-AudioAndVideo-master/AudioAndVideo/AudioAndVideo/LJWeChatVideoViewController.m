//
//  LJWeChatVideoViewController.m
//  AudioAndVideo
//
//  Created by LiJie on 2017/2/20.
//  Copyright © 2017年 LiJie. All rights reserved.
//


/**< 最长录制时间 >**/
#define kDuration 10
#define kTrans kWidth/kDuration/60.000f

#import "LJWeChatVideoViewController.h"
#import "LJPlayerViewController.h"

typedef NS_ENUM(NSInteger, videoStatus) {
    VideoStatusEnded = 0,
    VideoStatusStarted
};/**< 视频录制的状态 >**/


@interface LJWeChatVideoViewController ()<UIAlertViewDelegate,AVCaptureFileOutputRecordingDelegate>

@property(nonatomic,strong) UIButton *flashButton;
@property(nonatomic,strong) UIButton *changeButton;
@property(nonatomic,strong) UIView *videoView;
@property(nonatomic,strong) UIView *progressView;
@property(nonatomic,strong) UILabel *cancelLabel;
@property(nonatomic,strong) UILabel *tapLable; /**< 因为 button 有自己的响应方法,所以 button 不能检测到 touch 父视图的事件 >**/
@property(nonatomic,strong) UILabel *clickLable;
@property(nonatomic,assign) BOOL canSave; /**< 是否可以保存 >**/
@property(nonatomic,assign) videoStatus status;
@property (nonatomic,strong) CADisplayLink *link; /**< 定时器 >**/
@property(nonatomic,assign) CGFloat progressViewWidth;
@property (nonatomic,strong) UIView *focusCircle; /**< 光圈 >**/
@property(nonatomic,assign) BOOL canBack;
@property(nonatomic,copy) NSString *currentTimeString; /**< 当前的时间 >**/

@end

@implementation LJWeChatVideoViewController {
    
    AVCaptureDevice *_videoDevice; /**< 摄像头 >**/
    AVCaptureDevice *_audioDevice; /**< 麦克风 >**/
    AVCaptureSession *_captureSession; /**会话层**/
    AVCaptureDeviceInput *_videoDeviceInput; /**< 摄像头输入流 >**/
    AVCaptureDeviceInput *_audioDeviceInput; /**< 麦克风输入流 >**/
    AVCaptureMovieFileOutput *_captureMovieFileOutput; /**< 输出 >**/
    AVCaptureVideoPreviewLayer *_previewLayer; /**< 呈现视频预览 >**/
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //在退出时如果手电筒是开启的 摄像头会记忆手电筒的属性状态, 所以需要在退出时关闭摄像头
    [self changeDevicePropertySafety:^(AVCaptureDevice *captureDevice) {
        if (captureDevice.flashMode == AVCaptureFlashModeOn) {
            captureDevice.flashMode = AVCaptureFlashModeOff;
        }
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self addTapGestureRecognize];
    [self getAuthorizationVideo];
    
}

/*\*******************************  授权  *******************************\*/
#pragma mark - 获取授权(摄像头.麦克风授权的判错异常处理)
- (void)getAuthorizationVideo {
    /*
     AVAuthorizationStatusNotDetermined = 0,// 未进行授权选择
     
     AVAuthorizationStatusRestricted,　　　　// 未授权，且用户无法更新，如家长控制情况下
     
     AVAuthorizationStatusDenied,　　　　　　 // 用户拒绝App使用
     
     AVAuthorizationStatusAuthorized,　　　　// 已授权，可使用
     */
    //摄像头权限
    _canBack = YES;
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]) {
        case AVAuthorizationStatusAuthorized :  //已授权，可使用 ,在此处做摄像处理
        {
            NSLog(@"摄像头授权成功");
            [self setupAVCaptureInfo];
            break;
        }
        case AVAuthorizationStatusNotDetermined ://没有进行授权选择,需要重新授权,
        {
            NSLog(@"摄像头没有进行授权选择,需要重新授权");
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                //此处最好切回主线程,因为此方法不是在主线操作的,如果不切回会有很大的延迟, 还可能导致无名的崩溃
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (granted) {
                        NSLog(@"摄像头重新选择授权成功了");  //此处做摄像处理
                        //授权成功摄像头后授权麦克风
                        [self setupAVCaptureInfo];
                        return ;
                    } else  {
                        [LJUtility showMsgWithTitle:@"出错了" andContent:@"用户拒绝授权摄像头的使用权,返回上一页.请打开\n设置-->隐私\n 授权"];
                        return ;
                    }
                });
                
            }];
            break;
        }
        default:                    //未授权
        {
            [LJUtility showMsgWithTitle:@"出错了" andContent:@"用户拒绝授权摄像头的使用权,返回上一页.请打开\n设置-->隐私\n 授权"];
            break;
        }
    }
}

#pragma mark - setupUI
- (void)setupUI {
    _videoView = [[UIView alloc] init];
    _videoView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_videoView];
    __weak __typeof(self)weakSelf = self;
    [_videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        make.left.mas_equalTo(strongSelf.view.mas_left);
        make.right.mas_equalTo(strongSelf.view.mas_right);
        make.top.mas_equalTo(strongSelf.view.mas_top).offset(64);
        make.height.mas_equalTo(kScale(400));
    }];
    
    _flashButton = [[UIButton alloc] init];
    [_flashButton setTitle:@"闪光灯状态: 关" forState: UIControlStateNormal];
    [_flashButton setTitle:@"闪光灯状态: 开" forState: UIControlStateSelected];
    [_flashButton setTintColor:[UIColor whiteColor]];
    [_flashButton sizeToFit];
    [_flashButton addTarget:self action:@selector(buttonClickWithButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_flashButton];
    
    [_flashButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(_videoView.mas_left).offset(kScale(20));
        make.top.mas_equalTo(_videoView.mas_top).offset(kScale(20));
    }];
    
    _changeButton = [[UIButton alloc] init];
    [_changeButton setTitle:@"摄像头状态: 后" forState: UIControlStateNormal];
    [_changeButton setTitle:@"摄像头状态: 前" forState: UIControlStateSelected];
    [_changeButton setTintColor:[UIColor whiteColor]];
    [_changeButton addTarget:self action:@selector(buttonClickWithButton:) forControlEvents:UIControlEventTouchUpInside];
    [_changeButton sizeToFit];
    [self.view addSubview:_changeButton];
    
    [_changeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(_videoView.mas_right).offset(kScale(-20));
        make.top.mas_equalTo(_videoView.mas_top).offset(kScale(20));
    }];
    
    _cancelLabel = [[UILabel alloc] init];
    _cancelLabel.backgroundColor = [UIColor greenColor];
    _cancelLabel.text = @"上滑取消录制";
    [_cancelLabel sizeToFit];
    _cancelLabel.hidden = YES;
    [self.view addSubview:_cancelLabel];
    
    [_cancelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(_videoView.mas_bottom).offset(kScale(-20));
        make.centerX.mas_equalTo(_videoView.mas_centerX);
    }];
    
    _progressView = [[UIView alloc]init];
    _progressView.backgroundColor = [UIColor redColor];
    _progressView.hidden = YES;
    [self.view addSubview:_progressView];
    
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(_videoView.mas_bottom);
        make.left.mas_equalTo(_videoView.mas_left);
        make.right.mas_equalTo(_videoView.mas_right);
        make.height.mas_equalTo(kScale(2));
    }];
    
    _tapLable = [[UILabel alloc] init];
    _tapLable.text = @"按住录制";
    _tapLable.textColor = [UIColor whiteColor];
    _tapLable.backgroundColor = [UIColor blackColor];
    _tapLable.layer.borderWidth = kScale(2);
    _tapLable.layer.borderColor = [UIColor cyanColor].CGColor;
    _tapLable.layer.cornerRadius = kScale(45);
    _tapLable.textAlignment = NSTextAlignmentCenter;
    _tapLable.layer.masksToBounds = YES;
    [self.view addSubview:_tapLable];
    
    [_tapLable mas_makeConstraints:^(MASConstraintMaker *make) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        make.centerX.mas_equalTo(_videoView.mas_centerX);
        make.width.mas_equalTo(kScale(90));
        make.height.mas_equalTo(kScale(90));
        make.bottom.mas_equalTo(strongSelf.view.mas_bottom).offset(kScale(-20));
    }];
    
    _clickLable = [[UILabel alloc] init];
    _clickLable.text = @"单击调焦, 双击拉近/远镜头距离";
    [_clickLable sizeToFit];
    [self.view addSubview:_clickLable];
    
    [_clickLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_videoView.mas_bottom).offset(kScale(5));
        make.centerX.mas_equalTo(_videoView.mas_centerX);
    }];
}

#pragma mark - 开启录像模式
- (void)setupAVCaptureInfo
{
    [self addCaptureSession];
    [_captureSession beginConfiguration];
    [self addCaptureVideo];
    [self addAudioInput];
    [self addCapturePreviewLayer];
    [_captureSession commitConfiguration];
    //开启会话-->注意,不等于开始录制
    [_captureSession startRunning];
}

//设置会话层
- (void)addCaptureSession {
    _captureSession = [[AVCaptureSession alloc] init];
    //设置视频分辨率
    /*  通常支持如下格式
     (
     AVAssetExportPresetLowQuality,
     AVAssetExportPreset960x540,
     AVAssetExportPreset640x480,
     AVAssetExportPresetMediumQuality,
     AVAssetExportPreset1920x1080,
     AVAssetExportPreset1280x720,
     AVAssetExportPresetHighestQuality,
     AVAssetExportPresetAppleM4A
     )
     */
    //注意,这个地方设置的模式/分辨率大小将影响你后面拍摄照片/视频的大小,
    if ([_captureSession canSetSessionPreset:AVAssetExportPreset1920x1080]) {
        [_captureSession setSessionPreset:AVAssetExportPreset1920x1080];
    }
}

- (void)addCaptureVideo {
    _videoDevice = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
    [self addVideoInput];
    [self addMovieOutput];
}

#pragma mark - 获取输入流
- (void)addVideoInput {
    NSError *videoError;
    _videoDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:_videoDevice error:&videoError];
    // 视频输入对象
    // 根据输入设备初始化输入对象，用户获取输入数据
    if (videoError) {
        NSLog(@"---- 取得摄像头设备时出错 ------ %@",videoError);
    } else {
        // 将视频输入对象添加到会话 (AVCaptureSession) 中
        if ([_captureSession canAddInput:_videoDeviceInput]) {
            [_captureSession addInput:_videoDeviceInput];
        }
    }
}

- (void)addAudioInput {
    NSError *audioError;
    _audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    _audioDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:_audioDevice error:&audioError];
    if (audioError) {
        NSLog(@"---- 取得麦克风设备时出错 ------ %@", audioError);
    } else {
        if ([_captureSession canAddInput:_audioDeviceInput]) {
            [_captureSession addInput:_audioDeviceInput];
        }
    }
}

#pragma mark - 输出流
- (void)addMovieOutput{
    // 拍摄视频输出对象
    // 初始化输出设备对象，用户获取输出数据
    _captureMovieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([_captureSession canAddOutput:_captureMovieFileOutput]) {
        [_captureSession addOutput:_captureMovieFileOutput];
        AVCaptureConnection *captureConnection = [_captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        
        //设置视频旋转方向
        /*
         typedef NS_ENUM(NSInteger, AVCaptureVideoOrientation) {
         AVCaptureVideoOrientationPortrait           = 1,
         AVCaptureVideoOrientationPortraitUpsideDown = 2,
         AVCaptureVideoOrientationLandscapeRight     = 3,
         AVCaptureVideoOrientationLandscapeLeft      = 4,
         } NS_AVAILABLE(10_7, 4_0) __TVOS_PROHIBITED;
         */
        // 视频稳定设置
        if ([captureConnection isVideoStabilizationSupported]) {
            captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
        }
        //比例
        captureConnection.videoScaleAndCropFactor = captureConnection.videoMaxScaleAndCropFactor;
    }
}

#pragma mark 获取摄像头-->前/后
- (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = devices.firstObject;
    for ( AVCaptureDevice *device in devices ) {
        if ( device.position == position ) {
            captureDevice = device;
            break;
        }
    }
    return captureDevice;
}

#pragma mark - 展示层
- (void)addCapturePreviewLayer {
    
    [self.view layoutIfNeeded];
    
    // 通过会话 (AVCaptureSession) 创建预览层
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_captureSession];
    _previewLayer.frame = self.view.bounds;
    /* 填充模式
     Options are AVLayerVideoGravityResize, AVLayerVideoGravityResizeAspect and AVLayerVideoGravityResizeAspectFill. AVLayerVideoGravityResizeAspect is default.
     */
    //有时候需要拍摄完整屏幕大小的时候可以修改这个
    //    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    // 如果预览图层和视频方向不一致,可以修改这个
    _previewLayer.connection.videoOrientation = [_captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo].videoOrientation;
    _previewLayer.position = CGPointMake(self.view.width*0.5,_videoView.height*0.5);
    
    // 显示在视图表面的图层
    CALayer *layer = self.videoView.layer;
    layer.masksToBounds = true;
    [self.view layoutIfNeeded];
    [layer addSublayer:_previewLayer];
}
#pragma mark -  触摸事件
// 在触摸方法中获取 tapButtopn 的触摸点
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"touch.................");
    //获取触摸点
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    BOOL isInTapButton = [self inTapButtonRect:touchPoint];
    if (isInTapButton) {
        [self setCancelLabelTextWithIsInTapButton:isInTapButton];
        [self startAnimation];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    BOOL isInTapButton = [self inTapButtonRect:touchPoint];
    [self setCancelLabelTextWithIsInTapButton:isInTapButton];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.view];
    BOOL isInTapButton = [self inTapButtonRect:touchPoint];
    /**<
     结束时候设定有两种情况依然算录制成功
     1.抬手时,录制时长 > 1/3总时长
     2.录制进度条完成时,就算手指超出按钮范围也算录制成功 -- 此时 end 方法不会调用,因为用户手指还在屏幕上,所以直接代码调用录制成功的方法,将控制器切换
     >**/
    if (isInTapButton) {
        if (_progressView.width < kWidth * 0.6) {
            [self recordComplete];
        } else {
            _canBack = NO;
            [LJUtility showMsgWithTitle:@"视频录制失败" andContent:@"视频太短,请录制大于五秒的视频"];
        }
    }
    [self stopAnimation];
}

//根据触摸点是否在 tapButton 内来显示不同的 canncelLabel 的文字
- (void)setCancelLabelTextWithIsInTapButton: (BOOL)isInTapButton {
    if (isInTapButton) {
        _cancelLabel.text = @"上滑取消录制";
        _cancelLabel.backgroundColor = [UIColor redColor];
        _cancelLabel.textColor = [UIColor whiteColor];
    }else {
        _cancelLabel.text = @"松开取消录制";
        _cancelLabel.backgroundColor = [UIColor greenColor];
        _cancelLabel.textColor = [UIColor blackColor];
    }
}

#pragma mark - 动画
- (void)startAnimation {
    if (_status == VideoStatusEnded) {
        _status = VideoStatusStarted;
        [UIView animateWithDuration:0.25 animations:^{
            _cancelLabel.hidden = _progressView.hidden = NO;
            _flashButton.hidden =  _changeButton.hidden = YES;
            _tapLable.transform = CGAffineTransformMakeScale(1.5, 1.5);
        }];
        
        //每次开始录制都是从初始位置进行录制的,
        [_progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(_videoView.mas_bottom);
            make.left.mas_equalTo(_videoView.mas_left);
            make.width.mas_equalTo(_videoView.mas_width);
            make.height.mas_equalTo(kScale(2));
        }];
        [self.view layoutIfNeeded];
        [self startLink];
    }
}

- (void)stopAnimation {
    if (_status == VideoStatusStarted) {
        _status = VideoStatusEnded;
        [self stopLink];
        [self stopRecord];
        [UIView animateWithDuration:0.25 animations:^{
            _cancelLabel.hidden = _progressView.hidden = YES;
            _changeButton.hidden= _flashButton.hidden = NO;
            _tapLable.transform = CGAffineTransformMakeScale(1.0, 1.0);
        }];
        
        //更新约束
        [_progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(_videoView.mas_bottom);
            make.left.mas_equalTo(_videoView.mas_left);
            make.width.mas_equalTo(_videoView.mas_width);
            make.height.mas_equalTo(kScale(2));
        }];
        [self.view layoutIfNeeded];
    }
}

//  定时器开始
-(void)startLink {
    [self startRecord];
    _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(refresh:)];
    [_link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

// 定时器销毁
- (void)stopLink {
    _link.paused = YES;
    [_link invalidate];
    _link = nil;
}

- (void)refresh:(CADisplayLink *)link
{
    if (_progressView.width <= 0) {
        _progressView.width = 0;
        [self recordComplete];
        [self stopAnimation];
        return;
    }
    
    _progressViewWidth = _progressView.width;
    NSLog(@"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$%f",_progressView.width);

    _progressViewWidth -= kTrans;
    NSLog(@"************************************%f",_progressViewWidth);

    //更新约束
    [_progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_videoView.mas_centerX);
        make.bottom.mas_equalTo(_videoView.mas_bottom);
        make.height.mas_equalTo(kScale(2));
        make.width.mas_equalTo(_progressViewWidth);
        
    }];
    [self.view layoutIfNeeded];// 必须实现,否则不会有 布局变化 效果
}


#pragma mark - 判断触摸屏幕的点是否在 tapButton 内
- (BOOL) inTapButtonRect:(CGPoint)point {
    CGFloat pointX = point.x;
    CGFloat pointY = point.y;
    return (pointX >=_tapLable.left && pointX <=_tapLable.right) && (pointY >= _tapLable.top && pointY <= _tapLable.bottom);
    
}

/*\*******************************  录制相关  *******************************\*/
#pragma mark - 录制相关
//录制路径
- (NSURL *)outPutFileUrl {
    return [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@WV_%@.MP4", NSTemporaryDirectory(),_currentTimeString]];
}

//开始录制
- (void)startRecord {
    _currentTimeString = [LJUtility stringWithCurrentTime];
    [_captureMovieFileOutput startRecordingToOutputFileURL:[self outPutFileUrl] recordingDelegate:self];
}

//取消录制
- (void)stopRecord {
    [_captureMovieFileOutput stopRecording];
}

//保存视频
- (void)recordComplete
{
    self.canSave = YES;
}

//会话退出
- (void)sessionQuit {
    [_captureSession stopRunning];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex  {
    if (self.navigationController && _canBack) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - AVCaptureFileOutputRecordingDelegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    _canBack = NO;
    NSLog(@"---- 录制结束 ---%@-%@ ",outputFileURL,captureOutput.outputFileURL);
    
    if (outputFileURL.absoluteString.length == 0 && captureOutput.outputFileURL.absoluteString.length == 0 ) {
        [LJUtility showMsgWithTitle:@"出错了" andContent:@"录制视频保存地址出错"];
        return;
    } else {
        //保存视频
        if (_canSave) {
            [self pushToPlayerWithFileUrl:outputFileURL];
            _canSave = NO;
        }
    }
}

- (void)pushToPlayerWithFileUrl:(NSURL *)fileUrl {
    LJPlayerViewController *playerViewController = [[LJPlayerViewController alloc] initWithFileUrl:fileUrl currentTime:_currentTimeString];
    [self.navigationController pushViewController:playerViewController animated:YES];
}

/*\*******************************  调焦, 闪光灯, 摄像头切换,拉近/远  *******************************\*/
#pragma mark - 调焦,拉近/远
- (void)addTapGestureRecognize {
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    singleTap.numberOfTapsRequired = 1;
    /**< 当捕捉到触摸方法时响应点击 >**/
    singleTap.delaysTouchesBegan = YES;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleAction:)];
    doubleTap.numberOfTapsRequired = 2;
    /**< 当捕捉到触摸方法时响应点击 >**/
    doubleTap.delaysTouchesBegan = YES;
    /**< 必须在双击识别失败后再响应单击方法 >**/
    [singleTap requireGestureRecognizerToFail:doubleTap];
    
    [_videoView addGestureRecognizer:singleTap];
    [_videoView addGestureRecognizer:doubleTap];
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    _canBack = NO;
    NSLog(@"单击");
    CGPoint tapPoint = [tap locationInView:_videoView];
    //将UI坐标转化为摄像头坐标,摄像头聚焦点范围0~1
    CGPoint cameraPoint = [_previewLayer captureDevicePointOfInterestForPoint:tapPoint];
    //光圈
    [self animateFocuCircleWithCenterPoint:tapPoint];
    //调焦
    [self changeDevicePropertySafety:^(AVCaptureDevice *captureDevice) {
        
        //聚焦
        if ([captureDevice isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
            [captureDevice setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
            NSLog(@"聚焦模式修改为%zd",AVCaptureFocusModeContinuousAutoFocus);
        }else{
            NSLog(@"聚焦模式修改失败");
        }
        
        //聚焦点的位置
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:cameraPoint];
        }
        //曝光模式
        if ([captureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }else{
            NSLog(@"曝光模式修改失败");
        }
        //曝光点的位置
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:cameraPoint];
        }
    }];
}

- (void)doubleAction:(UITapGestureRecognizer *)tap {
    NSLog(@"双击");
    [self changeDevicePropertySafety:^(AVCaptureDevice *captureDevice) {
        if (captureDevice.videoZoomFactor == 1.0) {
            CGFloat Zoom = 2.0;
            //判断当前的比例是否小于设备最大的镜头距离的比例
            if (Zoom < captureDevice.activeFormat.videoMaxZoomFactor) {
                [captureDevice rampToVideoZoomFactor:Zoom withRate:10];
            }
        }else {
            [captureDevice rampToVideoZoomFactor:1.0 withRate:10];
        }
    }];
}

#pragma mark - 动画光圈
-(void)animateFocuCircleWithCenterPoint:(CGPoint)point {
    self.focusCircle.center = point;
    self.focusCircle.transform = CGAffineTransformIdentity;
    self.focusCircle.alpha = 1.0;
    [UIView animateWithDuration:0.7 animations:^{
        self.focusCircle.transform=CGAffineTransformMakeScale(0.5, 0.5);
        self.focusCircle.alpha = 0.0;
    } ];
}

//光圈
- (UIView *)focusCircle {
    if (!_focusCircle) {
        _focusCircle = [[UIView alloc] init];
        _focusCircle.frame = CGRectMake(0, 0, kScale(100),kScale(100));
        _focusCircle.layer.cornerRadius = kScale(50);
        _focusCircle.layer.borderWidth = 3;
        _focusCircle.layer.borderColor = [UIColor greenColor].CGColor;
        _focusCircle.layer.masksToBounds = YES;
        [_videoView addSubview:_focusCircle];
    }
    return _focusCircle;
}

#pragma mark - 闪光灯, 摄像头切换
//闪光模式开启后,并无明显感觉,所以还需要开启手电筒
- (void)buttonClickWithButton:(UIButton *)button {
    _canBack = NO;
    //闪光灯 ,在更改设备的属性时一定要对设备进行锁定, 否则程序会直接 Crash
    if ([button.currentTitle containsString:@"闪光灯状态"]) {
        BOOL FlashlightMode = [_videoDevice hasTorch];//是否支持手电筒
        BOOL photoFlashMode = [_videoDevice hasFlash];//是否支持闪光模式
        if (FlashlightMode && photoFlashMode) {
            [self changeDevicePropertySafety:^(AVCaptureDevice *captureDevice) {
                if (captureDevice.flashMode == AVCaptureFlashModeOn) {
                    [captureDevice setFlashMode:AVCaptureFlashModeOff];
                    [captureDevice setTorchMode:AVCaptureTorchModeOff];
                } else if (captureDevice.flashMode == AVCaptureFlashModeOff) {
                    [captureDevice setFlashMode:AVCaptureFlashModeOn];
                    [captureDevice setTorchMode:AVCaptureTorchModeOn];
                }else {
                    [captureDevice setTorchMode:AVCaptureTorchModeAuto];
                    [captureDevice setFlashMode:AVCaptureFlashModeAuto];
                }
                _flashButton.selected = !_flashButton.selected;
            }];
        } else {
            [LJUtility showMsgWithTitle:@"闪关灯打开失败" andContent:@"您的手机不支持手电筒功能或你现在使用的是前置摄像头"];
        }
    } else {
        //切换摄像头
        if (_videoDevice.position == AVCaptureDevicePositionBack) {
            _videoDevice = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionFront];
        } else {
            _videoDevice = [self deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        }
        [self changeDevicePropertySafety:^(AVCaptureDevice *captureDevice) {
            NSError *error;
            //因为前后摄像头获取的视频流不一样所以需要切换流
            AVCaptureDeviceInput *newInput = [[AVCaptureDeviceInput alloc] initWithDevice:_videoDevice error:&error];
            if (newInput != nil) {
                //必须先移除之前的流
                [_captureSession removeInput:_videoDeviceInput];
                if ([_captureSession canAddInput:newInput]) {
                    [_captureSession addInput:newInput];
                    _videoDeviceInput = newInput;
                }else {
                    //新的输入流不能添加
                    [_captureSession addInput:_videoDeviceInput];
                }
                _changeButton.selected = !_changeButton.selected;
            } else {
                [LJUtility showMsgWithTitle:@"切换摄像头出错" andContent:@"错误信息见控制台打印"];
                NSLog(@"切换前/后摄像头失败, error = %@", error);
            }
        }];
    }
}

#pragma mark - 锁定(更改设备属性前一定要锁上)
- (void)changeDevicePropertySafety:(void(^)(AVCaptureDevice *captureDevice))propertyChange {
    AVCaptureDevice *captureDevice= [_videoDeviceInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁,意义是---进行修改期间,先锁定,防止多处同时修改
    BOOL lockAcquired = [captureDevice lockForConfiguration:&error];
    if (!lockAcquired) {
        [LJUtility showMsgWithTitle:@"锁定设备出错" andContent:@"错误信息见控制台打印"];
        NSLog(@"锁定设备过程error，错误信息：%@",error.localizedDescription);
    } else {
        [_captureSession beginConfiguration];
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
        [_captureSession commitConfiguration];
    }
}

#pragma mark - 清除缓存
- (void)dealloc  {
    [self cleanCacheWithpaths:NSCachesDirectory];
}

- (void)cleanCacheWithpaths:(NSInteger)searchPathDirectory {
    //异步清除缓存
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *cachPath = [NSSearchPathForDirectoriesInDomains(searchPathDirectory, NSUserDomainMask, YES) lastObject];
        NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
        for (NSString *p in files) {
            NSError *error;
            NSString *path = [cachPath stringByAppendingPathComponent:p];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
            }
        }
    });
}
@end

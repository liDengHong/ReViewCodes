//
//  LJAVAssetWriterViewController.m
//  AudioAndVideo
//
//  Created by LiJie on 2017/2/28.
//  Copyright © 2017年 LiJie. All rights reserved.
//


typedef NS_ENUM(NSInteger,VideoPlayStyle) {
    VideoPlayStyleRecord = 0,//录制的视频
    VideoPlayStyleLocation, //本地视频
};

#import "LJAVAssetWriterViewController.h"
#import "LJRecorder.h"
#import "LJRecordEncoder.h"
#import "LJRecordProgressView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import "LJRecorderTopView.h"
#import "LJRecorderBottomView.h"

@interface LJAVAssetWriterViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,LJRecorderDelegate,LJRecorderTopViewDelegate,LJRecorderBottomViewDelegate>

@property(nonatomic,strong)LJRecordProgressView *progressView;
@property(nonatomic,strong)LJRecorder *recorder;
@property(nonatomic,strong)MPMoviePlayerViewController *playerViewController;
@property (strong, nonatomic)UIImagePickerController *moviePicker;
@property (assign, nonatomic)BOOL allowRecord;
@property(nonatomic,strong)LJRecorderTopView *topView;
@property(nonatomic,strong)LJRecorderBottomView *bottomView;
@property (assign, nonatomic)VideoPlayStyle videoStyle;
@property(nonatomic,assign)BOOL isBackCamera;

@end

@implementation LJAVAssetWriterViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_recorder == nil) {
        [self.recorder previewLayer].frame = self.view.bounds;
        [self.view.layer insertSublayer:[self.recorder previewLayer] atIndex:0];
    }
    [self.recorder startUp];
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.recorder shutDown];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.allowRecord = YES;
    _isBackCamera = YES;
    
    [self setupUI];
}


#pragma mark - setupUI
- (void)setupUI {
    _bottomView = [[LJRecorderBottomView alloc] initWithFrame:CGRectMake(0, kHeight - kScale(120), kWidth, kScale(120))];
    _bottomView.delegate = self;
    [self.view addSubview:_bottomView];
    _topView = [[LJRecorderTopView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kScale(64))];
    _topView.delegate = self;
    [self.view addSubview:_topView];
    _progressView = [[LJRecordProgressView alloc] init];
    _progressView.left = self.view.left;
    _progressView.height = 5;
    _progressView.width = kWidth;
    _progressView.bottom = kHeight - _bottomView.height;
    _progressView.backgroundColor = [UIColor grayColor];
    _progressView.progressColor = [UIColor redColor];
    [self.view addSubview:_progressView];
}

#pragma mark - getter
- (LJRecorder *)recorder {
    if (!_recorder) {
        _recorder = [[LJRecorder alloc] init];
        _recorder.delegate = self;
    }
    return _recorder;
}

- (UIImagePickerController *)moviePicker {
    if (_moviePicker == nil) {
        _moviePicker = [[UIImagePickerController alloc] init];
        _moviePicker.delegate = self;
        _moviePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        _moviePicker.mediaTypes = @[(NSString *)kUTTypeMovie];
    }
    return _moviePicker;
}

#pragma mark - LJRecorderTopViewDelegate,LJRecorderBottomViewDelegate,LJRecorderDelegate
/**< 返回 >**/
- (void)backButtonClick:(UIButton *)button {
    [self.navigationController popViewControllerAnimated:YES];
}

/**< 闪光灯 >**/
- (void)flashButtonClick:(UIButton *)button {
    if (!_isBackCamera) {
        button.selected = NO;
        [LJUtility showMsgWithTitle:@"打开闪光灯失败" andContent:@"当前是前置摄像头, 不支持闪光灯!!!"];
        return;
    } else {
        if (button.selected) {
            [self.recorder closeFlashLight];
        } else {
            [self.recorder openFlashLight];
        }
        button.selected = !button.selected;
    }
}

/**< 摄像头切换 >**/
- (void)changeCameraButtonClick:(UIButton *)button {
    [self.recorder changeCameraInputDeviceisBack:_isBackCamera];
        [self.topView closeFlashStatusIsOpen:_isBackCamera];
       _isBackCamera = !_isBackCamera;
}

/**< 进入播放页面 >**/
- (void)nextPageButtonClick:(UIButton *)button {
    if (self.recorder.videoPath.length > 0) {
        __weak typeof(self) weakSelf = self;
        [self.recorder stopRecordHandler:^(UIImage *oneVideoPicture) {
            weakSelf.playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:weakSelf.recorder.videoPath]];
            [[NSNotificationCenter defaultCenter] addObserver:weakSelf selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:[weakSelf.playerViewController moviePlayer]];
            [[weakSelf.playerViewController moviePlayer] prepareToPlay];
            [weakSelf presentMoviePlayerViewControllerAnimated:weakSelf.playerViewController];
            [[weakSelf.playerViewController moviePlayer] play];
            
        }];
    }
}

/**< 本地视屏 >**/
- (void)locationButtonClick:(UIButton *)button {
    self.videoStyle = VideoPlayStyleLocation;
    if (_recorder.isPauseing) {
            NSLog(@"_recorder.isPauseing: %d",_recorder.isPauseing);
            [LJUtility showMsgWithTitle:@"错误提示" andContent:@"当前处于录制模式, 请点击左上角退出按钮退出当前页面重新进入"];
        return;
    }
    [_recorder shutDown];
    [self presentViewController:self.moviePicker animated:YES completion:nil];
}

/**< 录制按钮 >**/
- (void)videoRecorderButtonClick:(UIButton *)button {
    if (self.allowRecord) {
        self.videoStyle = VideoPlayStyleRecord;
        if (!button.selected) {
            if (self.recorder.isPauseing) {
                [self.recorder resumeRecord];
            } else {
                [self.recorder startRecord];
            }
        }else {
            [self.recorder pauseRecord];
        }
        [self changeTopViewAndBottomViewFramWithRecordButtonStauts:button.selected];
    }
}

//当点击Done按键或者播放完毕时调用此函数
- (void) playVideoFinished:(NSNotification *)theNotification {
    MPMoviePlayerController *player = [theNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    [player stop];
    [self.playerViewController dismissMoviePlayerViewControllerAnimated];
    self.playerViewController = nil;
}

- (void)recordProgress:(CGFloat)progress {
    if (progress >= 1) {
        self.allowRecord = NO;
    }
    self.progressView.progress = progress;
}

#pragma mark - UIImagePickerControllerDelegate 
//选择了某个视频,照片的回调函数/代理回调
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeMovie]) {
        //获取视频的名称
        NSString * videoPath=[NSString stringWithFormat:@"%@",[info objectForKey:UIImagePickerControllerMediaURL]];
        NSRange range =[videoPath rangeOfString:@"trim."];//匹配得到的下标
        NSString *content=[videoPath substringFromIndex:range.location+5];
        //视频的后缀
        NSRange rangeSuffix=[content rangeOfString:@"."];
        NSString *suffixName=[content substringFromIndex:rangeSuffix.location+1];
        //如果视频是mov格式的则转为MP4的
        if ([suffixName isEqualToString:@"MOV"]) {
            NSURL *videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];
            __weak typeof(self) weakSelf = self;
            [self.recorder changeMovtoMp4:videoUrl handler:^(UIImage *videoPicture) {
                [weakSelf.moviePicker dismissViewControllerAnimated:YES completion:^{
                    weakSelf.playerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL fileURLWithPath:weakSelf.recorder.videoPath]];
                    [[weakSelf.playerViewController moviePlayer] prepareToPlay];
                    [weakSelf presentMoviePlayerViewControllerAnimated:weakSelf.playerViewController];
                    [[weakSelf.playerViewController moviePlayer] play];
                     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoFinished:) name:MPMoviePlayerPlaybackDidFinishNotification object:[weakSelf.playerViewController moviePlayer]];
                }];
            }];
        }
    }
}

- (void)changeTopViewAndBottomViewFramWithRecordButtonStauts:(BOOL)isSelected {
    if (isSelected) {
        [UIView animateWithDuration:0.25 animations:^{
            _topView.frame = CGRectMake(0, 0, kWidth, kScale(64));
            [_bottomView  hiddenLocationButton:NO];
        }];
    }else {
        [UIView animateWithDuration:0.25 animations:^{
            [_bottomView hiddenLocationButton:YES];
            _topView.frame = CGRectMake(0, -64, kWidth, kScale(64));
        }];
    }
}

@end

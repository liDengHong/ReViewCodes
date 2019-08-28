//
//  LJCropVideoViewController.m
//  AudioAndVideo
//
//  Created by LiJie on 2017/4/27.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "LJCropVideoViewController.h"
#import "LJVideoHelper.h"
#import "LJVideoPlayerViewController.h"
#define AUDIO_URL [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"test" ofType:@"mp3"]]
@interface LJCropVideoViewController ()<UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *startTimeTextField;
@property (weak, nonatomic) IBOutlet UITextField *endTimeTextField;
@property (nonatomic,strong) UIAlertView *alertView;
@property (nonatomic,strong) NSURL *VideoPathURL;
@property (nonatomic,strong) LJVideoHelper *videoHelper;
@property (nonatomic,assign) BOOL isOrignalSound;

@end

@implementation LJCropVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _videoHelper = [[LJVideoHelper alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPathSelect:) name:@"videoSelectedNotification" object:nil];
    _isOrignalSound = YES;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"videoSelectedNotification" object:nil];
}


-  (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_startTimeTextField resignFirstResponder];
    [_endTimeTextField resignFirstResponder];
}

/**< 选择视频后通知事件 >**/
- (void)videoPathSelect:(NSNotification *)notifincaia  {
    _VideoPathURL = notifincaia.object;
}

/**< 是否保留原始的音频 >**/
- (IBAction)isOrignalSoundClick:(UISwitch *)sender {
    _isOrignalSound = sender.on;
}

/**< 选择视频 >**/
- (IBAction)selectVideoClick:(id)sender {
    _alertView = [[UIAlertView alloc] initWithTitle:@"选择视频来源" message: nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"相册",@"相机", nil];
    [_alertView show];
}

/**< 裁切视频 >**/
- (IBAction)cropVideoClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSLog(@"你按了 %@",button.currentTitle);
    [_videoHelper cropVideoWithVideoPath:_VideoPathURL videoStartTime:[_startTimeTextField.text integerValue] videoEndTime:[_endTimeTextField.text integerValue]  viewController:self completion:^(NSString *outPathString, BOOL isSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isSuccess) {
                _VideoPathURL = [NSURL fileURLWithPath:outPathString];
            } else {    return; }
            [_endTimeTextField resignFirstResponder];
            [_startTimeTextField resignFirstResponder];
        });
    }];
}

/**< 添加背景音乐 >**/
- (IBAction)addBackgroundMusicClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSLog(@"你按了 %@",button.currentTitle);
    [_videoHelper addBackgoundMusicWithVideoPath:_VideoPathURL audioPath:AUDIO_URL isOrignalSound:_isOrignalSound viewController:self completion:^(NSString *outPathString, BOOL isSuccess) {
        if (isSuccess) {
            _VideoPathURL = [NSURL fileURLWithPath:outPathString];
        } else { return; }
    }];
}

/**< 播放视频 >**/
- (IBAction)playVdieoClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSLog(@"你按了 %@",button.currentTitle);
    if (_VideoPathURL.path == nil) {
        [LJUtility showMsgWithTitle:@"播放错误" andContent:@"您没有选择需要播放的视频"];
        return;
    }else {
        [self playVideoWithVideoPathURL:_VideoPathURL];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 1:
            [_videoHelper selectVideoWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary mediaType:UIImagePickerControllerSourceTypePhotoLibrary pushViewController:self CameraCaptureMode:UIImagePickerControllerCameraCaptureModeVideo completion:nil];
            break;
        case 2:
            [_videoHelper selectVideoWithSourceType:UIImagePickerControllerSourceTypeCamera mediaType:UIImagePickerControllerSourceTypeCamera pushViewController:self CameraCaptureMode:UIImagePickerControllerCameraCaptureModeVideo completion:nil];
            break;
        default:
            break;
    }
}

/**< 创建播放器 >**/
- (void)playVideoWithVideoPathURL:(NSURL *)videoPathURL {
    LJVideoPlayerViewController *playerController = [[LJVideoPlayerViewController alloc] initWithVideoURL:_VideoPathURL];
    [self.navigationController pushViewController:playerController animated:YES];
}

@end

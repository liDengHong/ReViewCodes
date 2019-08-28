//
//  LJLocationMusicViewController.m
//  AudioAndVideo
//
//  Created by LiJie on 2017/5/9.
//  Copyright © 2017年 LiJie. All rights reserved.
//


#import <AudioToolbox/AudioToolbox.h>
#import "LJLocationMusicViewController.h"
#import "LJPlayMusicViewController.h"

@interface LJLocationMusicViewController ()<MPMediaPickerControllerDelegate,AVAudioPlayerDelegate,AVAudioRecorderDelegate>

@property (nonatomic,strong) MPMediaPickerController *mediaPickerController;
@property (nonatomic,strong) AVAudioPlayer *audioPalyer;
@property (nonatomic,strong) AVAudioRecorder *audioRecorder;

@end

@implementation LJLocationMusicViewController {
    
    SystemSoundID _soundID;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
}

- (void)dealloc
{
    _audioPalyer = nil;
    _audioPalyer.delegate = nil;
}

- (void)setupUI {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kScale(300), kScale(30))];
    button.backgroundColor = [UIColor purpleColor];
    [button setTitle:@"MPMediaPickerController选取" forState:UIControlStateNormal];
    button.center = self.view.center;
    [button addTarget:self action:@selector(playMusicButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    UIButton *audioPlayerButton = [[UIButton alloc] init];
    audioPlayerButton.x = button.x;
    audioPlayerButton.top = button.bottom + kScale(20);
    audioPlayerButton.width = button.width;
    audioPlayerButton.height = button.height;
    audioPlayerButton.backgroundColor = [UIColor purpleColor];
    [audioPlayerButton setTitle:@"播放" forState:UIControlStateNormal];
    [audioPlayerButton setTitle:@"停止" forState:UIControlStateSelected];
    [audioPlayerButton addTarget:self action:@selector(audioPlayerMusicButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:audioPlayerButton];
    
    UIButton *shortAudioButton = [[UIButton alloc] init];
    shortAudioButton.x = button.x;
    shortAudioButton.top = audioPlayerButton.bottom + kScale(20);
    shortAudioButton.width = audioPlayerButton.width;
    shortAudioButton.height = audioPlayerButton.height;
    shortAudioButton.backgroundColor = [UIColor purpleColor];
    [shortAudioButton setTitle:@"音效播放" forState:UIControlStateNormal];
    [shortAudioButton addTarget:self action:@selector(shortAudioButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shortAudioButton];
    
    UIButton *recordAudioButton = [[UIButton alloc] init];
    recordAudioButton.x = button.x;
    recordAudioButton. bottom = button.top + kScale(-55);
    recordAudioButton.width = audioPlayerButton.width;
    recordAudioButton.height = audioPlayerButton.height;
    recordAudioButton.backgroundColor = [UIColor purpleColor];
    [recordAudioButton setTitle:@"开始录音" forState:UIControlStateNormal];
    [recordAudioButton setTitle:@"停止录音" forState:UIControlStateSelected];
    [recordAudioButton addTarget:self action:@selector(recordAudioButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordAudioButton];
}

/**< MPMediaPickerController选取音乐 >**/
- (void)playMusicButtonClick {
    //iOS10之后必须在 info.plist 中配置访问媒体库的权限才能访问系统媒体库
    _mediaPickerController = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeAnyAudio];
    _mediaPickerController.delegate = self;
    _mediaPickerController.prompt = @"select The song to play";
    _mediaPickerController.allowsPickingMultipleItems = YES;
    _mediaPickerController.view.backgroundColor = [UIColor redColor];
    [self presentViewController:_mediaPickerController animated:YES completion:nil];
}

/**< AVAudioPlayer 播放音乐 >**/
- (void)audioPlayerMusicButtonClick:(UIButton *)button {
    [self playMusicWithName:@"test.mp3"];
    button.selected = !button.selected;
    button.selected!=YES?[_audioPalyer stop]:[_audioPalyer play];
    _audioPalyer.enableRate = YES;
    _audioPalyer.rate = 1.5;
    //    获得峰值 必须设置Metersenable为YES
    _audioPalyer.meteringEnabled = YES;
    //    更新峰值
    [_audioPalyer updateMeters];
    //    获得当前峰值
    NSLog(@"当前峰值%f",[_audioPalyer peakPowerForChannel:2]);
    NSLog(@"平均峰值%f",[_audioPalyer averagePowerForChannel:2]);
    //    设置播放次数
    //    负数是无限循环    0是一次  1是2次
    _audioPalyer.numberOfLoops = -1;
    _audioPalyer.delegate = self;
}

/**< 初始化AVAudioPlayer >**/
- (void)playMusicWithName:(NSString *)name {
    NSError *error;
    _audioPalyer = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:name withExtension:nil] error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
    // 预播放在初始化播放器和路径的同时给他设置预播放.不然后面播放其他音频文件还需要再次预播放
    [_audioPalyer prepareToPlay];
}

/**< 音效播放 >**/
- (void)shortAudioButtonClick:(UIButton *)button {
    button.userInteractionEnabled = NO;
    NSString *audioFile = [[NSBundle mainBundle] pathForResource:@"shortAudio.wav" ofType:nil];
    NSURL *fileURL =  [NSURL fileURLWithPath:audioFile];
    SystemSoundID soundID = 1;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef _Nonnull)(fileURL), &soundID);
    AudioServicesPlayAlertSound(soundID);
    AudioServicesPlayAlertSoundWithCompletion(soundID, ^{
        button.userInteractionEnabled = YES;
    });
}

- (void)recordAudioButtonClick:(UIButton *)button {
    button.selected = !button.selected;
    //需要获取当前应用的音频会话
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    //设置音频的类别(既能播放又能录音)
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    //激活当前会话层
    [audioSession setActive:YES error:nil];
    //设置录制参数
    if (!button.selected) {
        [self.audioRecorder stop];
        self.audioRecorder = nil;
    } else {
    [self.audioRecorder prepareToRecord];
    [self.audioRecorder record];
}
}

- (AVAudioRecorder *)audioRecorder {
    if (!_audioRecorder) {
        /**
          1.AVNumberOfChannelsKey 通道数 通常为双声道 值2
            2.AVSampleRateKey 采样率 单位HZ 通常设置成44100 也就是44.1k
            3.AVLinearPCMBitDepthKey 比特率 8 16 24 32
            4.AVEncoderAudioQualityKey 声音质量
                ① AVAudioQualityMin  = 0, 最小的质量
                ② AVAudioQualityLow  = 0x20, 比较低的质量
                ③ AVAudioQualityMedium = 0x40, 中间的质量
                ④ AVAudioQualityHigh  = 0x60,高的质量
                ⑤ AVAudioQualityMax  = 0x7F 最好的质量
            5.AVEncoderBitRateKey 音频编码的比特率 单位Kbps 传输的速率 一般设置128000 也就是128kbps
         */
        
        //设置录制参数
        NSDictionary *settingOpations = @{AVNumberOfChannelsKey:@2,AVSampleRateKey:@44100,AVLinearPCMBitDepthKey:@32,AVEncoderAudioQualityKey:@(AVAudioQualityMax),AVEncoderBitRateKey:@128000};
            NSString *path = [self saveVideoPath];
        _audioRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:path] settings:settingOpations error:nil];
        _audioRecorder.delegate = self;
    }
    return _audioRecorder;
}

/**< 录音保存名称 >**/
- (NSString *)saveVideoPath {
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH-mm-ss"];
    NSDate *nowDate = [NSDate dateWithTimeIntervalSince1970:currentTime];
    NSString *timeString = [formatter stringFromDate:nowDate];
    NSString *audioPathString = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-audioRecorder.wav",timeString]];
    return audioPathString;
}

#pragma mark - MPMediaPickerControllerDelegate
- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    NSArray *musicItems = mediaItemCollection.items;
    [self dismissViewControllerAnimated:YES completion:nil];
    LJPlayMusicViewController *playMusicViewController = [[LJPlayMusicViewController alloc] initWithMediaItemCollection:musicItems];
    [self.navigationController pushViewController:playMusicViewController animated:YES];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [LJUtility showMsgWithTitle:@"出错了" andContent:@"你还没选择任何歌曲,请先选择歌曲"];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - AVAudioPlayerDelegate
//播放完成的时候调用
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"播放结束");
}

//解码出现错误的时候调用
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError * __nullable)error {
    NSLog(@"播放错误");
}

//被打扰开始中断的时候调用
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player {
    NSLog(@"播放被中断");
    
}

//中断结束调用
- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags {
    NSLog(@"播放恢复");
}

#pragma mark - AVAudioRecorderDelegate
//录制成功
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag  {
    //  文件操作的类
    NSFileManager *manger = [NSFileManager defaultManager];
    NSString *path = NSTemporaryDirectory();
    //  获得当前文件的所有子文件subpathsAtPath
    NSArray *pathlList = [manger subpathsAtPath:path];
    //  需要只获得录音文件
    NSMutableArray *audioPathList = [NSMutableArray array];
    //  遍历所有这个文件夹下的子文件
    for (NSString *audioPath in pathlList) {
        //    通过对比文件的延展名（扩展名 尾缀） 来区分是不是录音文件
        if ([audioPath.pathExtension isEqualToString:@"wav"]) {
            //      把筛选出来的文件放到数组中
            [audioPathList addObject:audioPath];
        }
    }
    NSLog(@"%@--",audioPathList);
}

//录制失败
- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError * __nullable)error {
    
}

@end

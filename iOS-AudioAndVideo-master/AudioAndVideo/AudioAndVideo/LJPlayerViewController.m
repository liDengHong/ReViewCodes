//
//  LJPlayerViewController.m
//  AudioAndVideo
//
//  Created by LiJie on 2017/2/20.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "LJPlayerViewController.h"
@interface LJPlayerViewController ()
@property(nonatomic,copy)NSURL *fileUrlString;
@property(nonatomic,strong) UIButton *saveButton;
@property(nonatomic,strong) UIView *playerView;
@property(nonatomic,copy) NSString *currentTimeString;

@end

@implementation LJPlayerViewController {
    AVPlayer *_player;
    AVPlayerItem *_playerItem;
    AVPlayerLayer *_playerLayer;
    BOOL _isFullPlaying;
}

- (instancetype)initWithFileUrl:(NSURL *)fileUrl currentTime:(NSString *)timeString
{
    self = [super init];
    if (self) {
        _fileUrlString = fileUrl;
        _currentTimeString = timeString;
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"小视频播放";
    [self produceSaveButton];
    [self playVideo];
    
    //添加观察者监测视频一个循环播放结束
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playVideoAgain) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //当播放器正在播放时进入后台,
    //    //当程序从前台进入后台后播放视频会暂停, 从后台再进入前台时,  系统会自动截图展示,视频处于暂停状态.
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(play) name:@"name" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_player pause];
    _player = nil;
}

#pragma mark - 播放器
- (void)playVideo {
    _playerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScale(300), kScale(300))];
    _playerView.center = self.view.center;
    [self.view addSubview:_playerView];
    _playerItem = [AVPlayerItem playerItemWithURL:_fileUrlString];
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame = _playerView.bounds;
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;//视频填充模式
    [_playerView.layer addSublayer:_playerLayer];
    [_player play];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    if ([self isInPlayLayerWithPoint:point]) {
        
        if (_isFullPlaying) {
            [UIView animateWithDuration:0.25 animations:^{
                _playerView.frame = CGRectMake(0, 0, kScale(300), kScale(300));
                _playerView.center = self.view.center;
                _playerLayer.frame = _playerView.bounds;
            }];
        } else {
            [UIView animateWithDuration:0.25 animations:^{
                _playerView.frame = CGRectMake(0, 64, kWidth, kHeight - 64);
                _playerLayer.frame = _playerView.bounds;
            }];
        }
        _isFullPlaying = !_isFullPlaying;
    }
}

-  (void)playVideoAgain {
    /**< CMTime 是 Core Media框架中来表示精确时间的 >**/
    //seekToTime方法为 player 指定播放频率,间隔过长时间可以再次播放
    [_player seekToTime:CMTimeMake(0, 1)];
    [_player play];
}

- (BOOL)isInPlayLayerWithPoint:(CGPoint)point {
    CGFloat x = point.x;
    CGFloat y = point.y;
    return (x > _playerView.left && x < _playerView.right) && (y < _playerView.bottom && y > _playerView.top);
}

#pragma mark - saveButton
- (void)produceSaveButton {
    _saveButton = [[UIButton alloc] init];
    [_saveButton setTitle:@"压缩并保存到相册" forState:UIControlStateNormal];
    [_saveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _saveButton.backgroundColor = [UIColor orangeColor];
    [_saveButton addTarget:self action:@selector(saveVideos) forControlEvents:UIControlEventTouchUpInside];
    [_saveButton sizeToFit];
    [self.view addSubview:_saveButton];
    _saveButton.centerX = self.view.centerX;
    _saveButton.bottom = self.view.bottom - kScale(50);
}


//保存时需要先保存到本地沙盒, 再保存到相册
#pragma mark - 保存视频
- (void)saveVideos {
    NSLog(@"压缩之前的 size:%f",[self VideoSizeUrl:_fileUrlString]);
    _saveButton.enabled = NO;
    _saveButton.backgroundColor  = [UIColor lightGrayColor];
    //导出,此处拿取的是视频原来的路径
    AVURLAsset *urlAsset = [[AVURLAsset alloc] initWithURL:_fileUrlString options: nil];
    NSArray *exportSessionArray = [AVAssetExportSession exportPresetsCompatibleWithAsset:urlAsset];
    //先判断是否可以压缩成低质量的视频
    if ([exportSessionArray containsObject:AVAssetExportPresetLowQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:urlAsset presetName:AVAssetExportPreset640x480];
        exportSession.outputURL = [self savePath];
        //优化网络
        exportSession.shouldOptimizeForNetworkUse = YES;
        //转化要保存的格式
        exportSession.outputFileType = AVFileTypeMPEG4;
        //此处的导出是异步的
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            
            switch (exportSession.status) {
                case AVAssetExportSessionStatusUnknown: {
                    NSLog(@"导出结果未知");
                    break;
                }
                case AVAssetExportSessionStatusWaiting: {
                    NSLog(@"正在等待导出");
                    break;
                }
                case AVAssetExportSessionStatusExporting: {
                    NSLog(@"正在导出中");
                    break;
                }
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"导出失败 %@",exportSession.error);
                    break;
                }
                case AVAssetExportSessionStatusCompleted: {
                    [self saveVideo:[self savePath]];
                    NSLog(@"压缩完毕,压缩后大小 %f MB",[self VideoSizeUrl:[self savePath]]);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _saveButton.backgroundColor = [UIColor orangeColor];
                        _saveButton.enabled = YES;
                        NSLog(@"导出完成");
                    });
                    break;
                }
                default: {
                    NSLog(@"导出退出");
                    break;
                }
            }
        }];
    }
}

- (NSURL *)savePath  {
    return [NSURL fileURLWithPath:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"WV_%@.MP4",_currentTimeString]]];
}

- (CGFloat)VideoSizeUrl:(NSURL *)url {
    NSData *VideoData = [NSData dataWithContentsOfURL:url];
    CGFloat size = VideoData.length/1024.0/1024.0;
    return size;
}

- (void)saveVideo:(NSURL *)outputFileURL
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    if (error) {
                                        NSLog(@"保存视频失败:%@",error);
                                    } else {
                                        NSLog(@"保存视频到相册成功");
                                    }
                                }];
}

- (void)play {
    [_player play];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
}

@end

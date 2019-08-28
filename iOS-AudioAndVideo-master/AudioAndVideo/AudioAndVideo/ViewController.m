//
//  ViewController.m
//  AudioAndVideo
//
//  Created by LiJie on 2017/2/13.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "ViewController.h"
#import "LJUtility.h"

/**< 
 iOS中视频录制有三种方式:
 <1>  UIImagePickerController  将视频捕获集成到你的应用中的最简单的方法是使用 UIImagePickerController。这是一个封装了完整视频捕获管线和相机 UI 的 view controller.
 
 <2>  AVFoundation中的AVCaptureSession。它负责调配影音输入与输出之间的数据流,  AVCaptureMovieFileOutput可以对视频的一些输出属性设置.  AVAudioSession 对音频做更多的操作(大多数情况下，设置成默认的麦克风配置即可。后置麦克风会自动搭配后置摄像头使用 (前置麦克风则用于降噪)，前置麦克风和前置摄像头也是一样,例如，当用户正在使用后置摄像头捕获场景的时候，使用前置麦克风来录制解说也应是可能的。这就要依赖于 AVAudioSession。 为了变更要访问的音频，audio session 首先需要设置为支持这样做的类别。然后我们需要遍历 audio session 的输入端口和端口数据来源，来找到我们想要的麦克风)。
 
 <3>  AVFoundation中的AVCaptureDataOutput (AVCaptureVideoDataOutput,AVCaptureAudioDataOutput)和 AVAssetWriter, 可以对影音的输出做更多的操作。
 >**/

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSArray *titleArray;
@property(nonatomic,strong)NSArray *dataArray;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"音视频";
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_tableView];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [[UIView alloc] init];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    _titleArray = @[@"全屏拍摄并保存到沙盒",@"UIImagePickerViewController访问相机",@"微信小视频",@"AVAssetWriter录制音视频",@"视频裁剪, 添加背景音乐",@"选择并播放本地音频"];
    _dataArray = @[@"LJPanoramaPreviewController",@"LJUIImagePickerViewController",@"LJWeChatVideoViewController",@"LJAVAssetWriterViewController",@"LJCropVideoViewController",@"LJLocationMusicViewController"];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = _titleArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([_dataArray[indexPath.row] isEqualToString:@"LJCropVideoViewController"]) {
        UIStoryboard *cropVideoStoryBoard = [UIStoryboard storyboardWithName:@"LJCropVideoStoryboard" bundle:nil];
        UIViewController *cropVideoController = [cropVideoStoryBoard instantiateViewControllerWithIdentifier:@"cropVideo"];
        [self.navigationController pushViewController:cropVideoController animated:YES];
    } else {
    Class class = NSClassFromString(_dataArray[indexPath.row]);
    UIViewController *vc = [[class alloc] init];
    vc.title = _titleArray[indexPath.row];
    vc.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:vc animated:YES];
    }
}

@end

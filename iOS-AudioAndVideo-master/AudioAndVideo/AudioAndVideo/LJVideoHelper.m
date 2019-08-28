//
//  LJVideoHelper.m
//  AudioAndVideo
//
//  Created by LiJie on 2017/4/27.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "LJVideoHelper.h"

@interface LJVideoHelper() <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) UIImagePickerController *imagePickerController;
@property (nonatomic,strong) NSURL *videoPath;

@end

@implementation LJVideoHelper

#pragma mark - 裁切视频
- (void)cropVideoWithVideoPath:(NSURL *)videoPathURL videoStartTime:(CGFloat)startTime videoEndTime:(CGFloat)endTime viewController:(UIViewController *)viewController completion:(void(^)(NSString *outPathString,BOOL isSuccess))completionHandle {
    if (!(videoPathURL.path.length > 0)) {
        [LJUtility showMsgWithTitle:@"出错了" andContent:@"请先选择视频"];
        return;
    }
    //默认裁剪的开始时间是0秒
    if ( startTime < 0) {
        [LJUtility showMsgWithTitle:@"出错了" andContent:@"请先填写开始时间"];
        return;
    }
    if ( endTime <= 0 || endTime < startTime) {
        [LJUtility showMsgWithTitle:@"出错了" andContent:@"请正确填写结束时间"];
        return;
    }
    
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoPathURL options:nil];
    //CMTime 类型转换成 float
    CGFloat videoDuration = CMTimeGetSeconds(videoAsset.duration);
    if (endTime > videoDuration) {
        [LJUtility showMsgWithTitle:@"出错了" andContent:@"请在该视频的时长范围内进行裁剪"];
        return;
    }
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:videoAsset presetName:AVAssetExportPresetPassthrough];
    //视频输出的地址
    NSString *outFilePathString = [self saveVideoPath];
    NSURL *outFilePathURL = [NSURL fileURLWithPath:outFilePathString];
    exportSession.outputURL = outFilePathURL;
    
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.shouldOptimizeForNetworkUse= YES;
    
    //剪辑视频片段 设置timeRange
    CMTime start = CMTimeMakeWithSeconds(startTime, videoAsset.duration.timescale);
    CMTime duration = CMTimeMakeWithSeconds(endTime - startTime,videoAsset.duration.timescale);
    CMTimeRange range = CMTimeRangeMake(start, duration);
    
    exportSession.timeRange = range;
    
    [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    [exportSession exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         switch ([exportSession status]) {
             case AVAssetExportSessionStatusFailed: {
                 NSLog(@"剪切失败：%@",[[exportSession error] description]);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [MBProgressHUD hideHUDForView:viewController.view animated:YES];
                     [LJUtility showMsgWithTitle:@"剪切失败" andContent:@"视频类型有误, 再试一次吧"];
                 });
                 completionHandle(outFilePathString,NO);
             } break;
             case AVAssetExportSessionStatusCancelled: {
                 completionHandle(outFilePathString,NO);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [MBProgressHUD hideHUDForView:viewController.view animated:YES];
                 });
             } break;
             case AVAssetExportSessionStatusCompleted: {
                 completionHandle(outFilePathString,YES);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [MBProgressHUD hideHUDForView:viewController.view animated:YES];
                     [LJUtility showMsgWithTitle:@"剪切完成" andContent:@"请点击'播放视频' 播放剪切后的视频吧"];
                 });
             } break;
             default: {
                 completionHandle(outFilePathString,NO);
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [MBProgressHUD hideHUDForView:viewController.view animated:YES];
                 });
             } break;
         }
     }
     ];
}

#pragma mark - 添加背景音乐
- (void)addBackgoundMusicWithVideoPath:(NSURL *)videoPathURL audioPath:(NSURL *)audioPathURL isOrignalSound:(BOOL)isOrignal viewController:(UIViewController *)viewController completion:(void(^)(NSString *outPathString,BOOL isSuccess))completionHandle {
    if (!(videoPathURL.path.length > 0)) {
        [LJUtility showMsgWithTitle:@"出错了" andContent:@"请先选择视频"];
        return;
    }
    
    CMTime startCropTime = kCMTimeZero;
    //创建可变的音视频组合
    AVMutableComposition *audioComposition = [AVMutableComposition composition];
    AVURLAsset *backgoundAsset = [[AVURLAsset alloc] initWithURL:videoPathURL options:nil];
    CMTimeRange backgoundVideoTimeRange = CMTimeRangeMake(kCMTimeZero,backgoundAsset.duration);
    //可变轨迹
    AVMutableCompositionTrack *backgoundTrack = [audioComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    //可变轨迹插入的时间段
    [backgoundTrack insertTimeRange:backgoundVideoTimeRange ofTrack:[[backgoundAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:startCropTime error:nil];
    
    //    CMTime start = CMTimeMakeWithSeconds(startTime, backgoundAsset.duration.timescale);
    //    CMTime duration = CMTimeMakeWithSeconds(endTime -startTime, backgoundAsset.duration.timescale);
    //    CMTimeRange audionRange = CMTimeRangeMake(start, duration);
    
    if (isOrignal) {
        //视频声音采集(也可不执行这段代码不采集视频音轨，合并后的视频文件将没有视频原来的声音)
        AVMutableCompositionTrack *compositionVoiceTrack = [audioComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionVoiceTrack insertTimeRange:backgoundVideoTimeRange ofTrack:([backgoundAsset tracksWithMediaType:AVMediaTypeAudio].count>0)?[backgoundAsset tracksWithMediaType:AVMediaTypeAudio].firstObject:[backgoundAsset tracksWithMediaType:AVMediaTypeMuxed].firstObject atTime:kCMTimeZero error:nil];
    }
    
    //采集声音
    AVURLAsset *audionAsset = [[AVURLAsset alloc] initWithURL:audioPathURL options:nil];
    AVMutableCompositionTrack *audioTrack = [audioComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    [audioTrack insertTimeRange:backgoundVideoTimeRange ofTrack:[[audionAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0]atTime:kCMTimeZero error:nil];
    
    //创建导出对象
    AVAssetExportSession *audioExportSession = [[AVAssetExportSession alloc] initWithAsset:audioComposition presetName:AVAssetExportPresetMediumQuality];
    //视频输出的地址
    NSString *outFilePathString = [self saveVideoPath];
    NSURL *outFilePathURL = [NSURL fileURLWithPath:outFilePathString];
    audioExportSession.outputFileType = AVFileTypeQuickTimeMovie;
    audioExportSession.outputURL = outFilePathURL;
    audioExportSession.shouldOptimizeForNetworkUse = YES;
    [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
    [audioExportSession exportAsynchronouslyWithCompletionHandler:^{
        switch ([audioExportSession status]) {
            case AVAssetExportSessionStatusFailed: {
                NSLog(@"添加背景音乐失败：%@",[[audioExportSession error] description]);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:viewController.view animated:YES];
                    [LJUtility showMsgWithTitle:@"添加背景音乐失败" andContent:@"视频类型有误, 再试一次吧"];
                });
                completionHandle(outFilePathString,NO);
            } break;
            case AVAssetExportSessionStatusCancelled: {
                completionHandle(outFilePathString,NO);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:viewController.view animated:YES];
                });
            } break;
            case AVAssetExportSessionStatusCompleted: {
                completionHandle(outFilePathString,YES);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:viewController.view animated:YES];
                    [LJUtility showMsgWithTitle:@"添加背景音乐成功" andContent:@"请点击'播放视频' 播放视频吧"];
                });
            } break;
            default: {
                completionHandle(outFilePathString,NO);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [MBProgressHUD hideHUDForView:viewController.view animated:YES];
                });
            } break;
        }
    }];
}

#pragma mark - 选择视频
- (void)selectVideoWithSourceType:(UIImagePickerControllerSourceType)sourceType mediaType:(UIImagePickerControllerSourceType)mediaType pushViewController:(UIViewController *)viewController CameraCaptureMode:(UIImagePickerControllerCameraCaptureMode)mode  completion:(void(^)(NSString *outPathString,BOOL isSuccess))completionHandle {
    _imagePickerController = [[UIImagePickerController alloc] init];
    //资源的来源
    _imagePickerController.sourceType = sourceType;
    //这是 VC 的各种 modal 形式
    _imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
    //支持的摄制类型,拍照或摄影,此处将本设备支持的所有类型全部获取,并且同时赋值给imagePickerController的话,则可左右切换摄制模式
    _imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:mediaType];
    _imagePickerController.delegate = self;
    //允许拍照后编辑
    _imagePickerController.allowsEditing = YES;
    //显示相机的 UI 样式, 默认是系统的, YES
    //    imagePickerViewController.showsCameraControls = NO;
    //拍照
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        //设置模式 - 拍照
        _imagePickerController.cameraCaptureMode = mode;
        //默认开启的摄像头, 前, 后
        _imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        //设置默认的闪光灯模式-->开/关/自动
        _imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
    } else {
        NSLog(@"相册");
    }
    [viewController presentViewController:_imagePickerController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(nullable NSDictionary<NSString *,id> *)editingInfo {
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    //如果[mediaType isEqualToString:@"public.image"] 是图片或拍照  [mediaType isEqualToString:@"public.movie"]是视频
    if ([mediaType isEqualToString:@"public.image"]) {
        [LJUtility showMsgWithTitle:@"提示" andContent:@"你选取的是照片,请重新选取视频"];
        [_imagePickerController dismissViewControllerAnimated:YES completion:nil];
    } else{
        NSURL *url=[info objectForKey:UIImagePickerControllerMediaURL];//视频路径
        _videoPath = url;
    }
    [_imagePickerController dismissViewControllerAnimated:YES completion:nil];
    //选择视频后通知传值
    [[NSNotificationCenter defaultCenter] postNotificationName:@"videoSelectedNotification" object:_videoPath];
}

/**< 视频保存路径 >**/
- (NSString *)saveVideoPath {
    NSTimeInterval currentTime = [[NSDate date] timeIntervalSince1970];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH-mm-ss"];
    NSDate *nowDate = [NSDate dateWithTimeIntervalSince1970:currentTime];
    NSString *timeString = [formatter stringFromDate:nowDate];
    NSString *videoPathString = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-cropVideo.mp4",timeString]];
    return videoPathString;
}

@end

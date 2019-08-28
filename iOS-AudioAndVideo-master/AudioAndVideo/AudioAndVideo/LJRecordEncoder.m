//
//  LJRecordEncoder.m
//  AudioAndVideo
//
//  Created by LiJie on 2017/3/9.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "LJRecordEncoder.h"

@interface LJRecordEncoder()
@property(nonatomic,strong) AVAssetWriter *assetWriter; /**< 写入器 >**/
@property (nonatomic, strong) AVAssetWriterInput *videoInput; /**< 视频写入 >**/
@property (nonatomic, strong) AVAssetWriterInput *audioInput; /**< 音频写入 >**/
@property(nonatomic,copy) NSString *path;
@end

@implementation LJRecordEncoder

- (void)dealloc {

}

+(LJRecordEncoder *)encoderForPath:(NSString *)path resolutionHeight:(NSInteger)height resolutionWidth:(NSInteger)Width videoChannels:(int)channel samples:(Float64)rate {
    
    LJRecordEncoder *encoder = [LJRecordEncoder alloc];
    return [encoder initWithPath:path resolutionHeight:height resolutionWidth:Width videoChannels:channel samples:rate];
}

- (instancetype)initWithPath:(NSString *)path resolutionHeight:(NSInteger)height resolutionWidth:(NSInteger)Width videoChannels:(int)channel samples:(Float64)rate {
    self = [super init];
    if (self) {
        self.path = path;
        //移除之前的文件,保存做新的文件
        [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
        NSURL *url = [NSURL fileURLWithPath:self.path];
        //初始化写入器
        _assetWriter = [[AVAssetWriter  alloc] initWithURL:url fileType:AVFileTypeMPEG4 error:nil];
        //使其更适合在网络上播放
        _assetWriter.shouldOptimizeForNetworkUse = YES;
        //初始化视频输入
        [self initVideoInputWithResolutionHeight:height resolutionWidth:Width];
        
        if (rate != 0 && channel != 0 ) {
            [self initAudioInputWithChannel:channel samples:rate];
        }
        
    }
    return self;
}

#pragma mark - 初始化写入流
/**
 初始化视频输入
 
 @param height 分辨率的高
 @param width 分辨率的宽
 */
- (void)initVideoInputWithResolutionHeight:(NSInteger)height resolutionWidth:(NSInteger)width {
    //录制视频的一些配置
    NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              AVVideoCodecH264, AVVideoCodecKey,
                              [NSNumber numberWithInteger: width], AVVideoWidthKey,
                              [NSNumber numberWithInteger: height], AVVideoHeightKey,
                              nil];

    _videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
    //是否应该调整其对实时源的媒体数据的处理。
    _videoInput.expectsMediaDataInRealTime = YES;
    //将输入流添加到写入器
    [_assetWriter addInput:_videoInput];
}

/**
 初始化音频输入类
 
 @param channel 音频通道
 @param rate 音频的采样比率
 */
- (void)initAudioInputWithChannel:(int)channel samples:(Float64)rate {
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [ NSNumber numberWithInt: kAudioFormatMPEG4AAC], AVFormatIDKey,
                              [ NSNumber numberWithInt: channel], AVNumberOfChannelsKey,
                              [ NSNumber numberWithFloat: rate], AVSampleRateKey,
                              [ NSNumber numberWithInt: 128000], AVEncoderBitRateKey,
                              nil];
    _audioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:settings];
    //表明输入是否应该调整其处理为实时数据源的数据
    _audioInput.expectsMediaDataInRealTime = YES;
    //将音频输入源加入
    [_assetWriter addInput:_audioInput];
    
}

#pragma mark -  回调
- (void)recordFinishWithCompletionHandler:(void (^)(void))handler {
    [_assetWriter finishWritingWithCompletionHandler:handler];
}

#pragma mark - 写入数据
- (void)encodeFrame:(CMSampleBufferRef)sampleBuffer isVideo:(BOOL)isVideo {
    //数据是否准备写入
    if (CMSampleBufferDataIsReady(sampleBuffer)) {
        //如果写入状态未知
        if (_assetWriter.status == AVAssetWriterStatusUnknown && isVideo) {
            //获取开始写入的时间
            CMTime startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            //开始写入
            [_assetWriter startWriting];
            [_assetWriter startSessionAtSourceTime:startTime];
        }
        //写入失败
        if (_assetWriter.status == AVAssetWriterStatusFailed) {
            NSLog(@"writer error %@", _assetWriter.error.localizedDescription);
        }
        if (_assetWriter.status == AVAssetWriterStatusWriting) {
            NSLog(@"正在写入");
        }
        if (_assetWriter.status == AVAssetWriterStatusCompleted) {
            NSLog(@"写入完成");
        }
        if (_assetWriter.status == AVAssetWriterStatusCancelled) {
            NSLog(@"写入退出");
        }
        //判断是否是视频
        if (isVideo) {
            //视频输入是否准备接受更多的媒体数据
            if (_videoInput.readyForMoreMediaData == YES) {
                //拼接数据
                [_videoInput appendSampleBuffer:sampleBuffer];
            }
        }else {
            //音频输入是否准备接受更多的媒体数据
            if (_audioInput.readyForMoreMediaData) {
                //拼接数据
                [_audioInput appendSampleBuffer:sampleBuffer];
            }
        }
    }
}

@end

//
//  LJRecordEncoder.h
//  AudioAndVideo
//
//  Created by LiJie on 2017/3/9.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import <Foundation/Foundation.h>

/**< 此类是写入并且编码视频的类 >**/

@interface LJRecordEncoder : NSObject

@property(nonatomic,copy,readonly) NSString *path;



/**
 LJRecordEncoder遍历构造器

 @param path 媒体存放路径
 @param height 分辨率的高
 @param width 分辨率的宽
 @param channel 音频通道
 @param rate 音频的采样比率
 @return return LJRecordEncoder实体
 */
+(LJRecordEncoder *)encoderForPath:(NSString *)path resolutionHeight:(NSInteger)height resolutionWidth:(NSInteger)width videoChannels:(int)channel samples:(Float64)rate;


/**
 初始化方法

 @param path 媒体存放路径
 @param height 分辨率的高
 @param Width 分辨率的宽
 @param channel 音频通道
 @param rate 音频的采样比率
 @return return LJRecordEncoder实体
 */
- (instancetype)initWithPath:(NSString *)path resolutionHeight:(NSInteger)height resolutionWidth:(NSInteger)Width videoChannels:(int)channel samples:(Float64)rate;


/**
 录制结束后的回调

 @param handler 回调操作
 */
- (void)recordFinishWithCompletionHandler:(void (^)(void))handler;


/**
 通过这个方法写入数据

 @param sampleBuffer 写入的数据
 @param isVideo      是否写入的是视频
 */
- (void)encodeFrame:(CMSampleBufferRef)sampleBuffer isVideo:(BOOL)isVideo;

@end

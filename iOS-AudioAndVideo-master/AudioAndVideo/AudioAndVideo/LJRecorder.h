//
//  LJRecorder.h
//  AudioAndVideo
//
//  Created by LiJie on 2017/3/7.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol LJRecorderDelegate <NSObject>
- (void)recordProgress:(CGFloat)progress;
@end

@interface LJRecorder : NSObject

@property (weak, nonatomic) id<LJRecorderDelegate>delegate;

/**< 是否正在录制 >**/
@property(atomic,assign,readonly)BOOL isRecording;
/**< 是否暂停录制 >**/
@property(atomic,assign,readonly)BOOL isPauseing;
/**< 当前录制时间 >**/
@property(atomic,assign)CGFloat cuttentRecordTime;
/**< 最长的录制时间 >**/
@property(atomic,assign)CGFloat maxRecordTime;
/**< 视频录制路径 >**/
@property(atomic,copy)NSString *videoPath;

/**< 呈现视频的 layer >**/
- (AVCaptureVideoPreviewLayer *)previewLayer;
/**< 启动录制功能 >**/
- (void)startUp;
/**< 关闭录制功能 >**/
- (void)shutDown;
/**< 开始录制 >**/
- (void)startRecord;
/**< 暂停录制 >**/
- (void)pauseRecord;
/**< 继续录制 >**/
- (void)resumeRecord;
/**< 停止录制 >**/
- (void)stopRecordHandler:(void(^)(UIImage *oneVideoPicture))handler;
/**< 开启闪光灯 >**/
- (void)openFlashLight;
/**< 关闭闪光灯 >**/
- (void)closeFlashLight;
/**< 切换前后摄像头 >**/
- (void)changeCameraInputDeviceisBack:(BOOL)isBack;
/**< 将mov的视频转成mp4 >**/
- (void)changeMovtoMp4:(NSURL *)videoURL handler:(void (^)(UIImage *videoPicture))handler;
@end

//
//  LJVideoHelper.h
//  AudioAndVideo
//
//  Created by LiJie on 2017/4/27.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LJVideoHelper : NSObject

/**
 裁切视频

 @param videoPathURL 视频路径
 @param startTime 开始裁切的时间
 @param endTime 结束裁切的时间
 @param viewController UI操作的VC
 @param completionHandle 完成回调
 */
- (void)cropVideoWithVideoPath:(NSURL *)videoPathURL videoStartTime:(CGFloat)startTime videoEndTime:(CGFloat)endTime viewController:(UIViewController *)viewController completion:(void(^)(NSString *outPathString,BOOL isSuccess))completionHandle;

/**
  添加背景音乐

 @param videoPathURL 视频路径
 @param audioPathURL 音频路径
 @param isOrignal 是否保留原声
 @param viewController UI操作的VC
 @param completionHandle 完成回调
 */
- (void)addBackgoundMusicWithVideoPath:(NSURL *)videoPathURL audioPath:(NSURL *)audioPathURL isOrignalSound:(BOOL)isOrignal viewController:(UIViewController *)viewController completion:(void(^)(NSString *outPathString,BOOL isSuccess))completionHandle;

/**
 选取视频

 @param sourceType 资源类型
 @param mediaType 资源类型
 @param viewController  push 的 viewController
 @param mode  拍摄类型
 @param completionHandle 完成回调(主要做 UI 操作)
 */
- (void)selectVideoWithSourceType:(UIImagePickerControllerSourceType)sourceType mediaType:(UIImagePickerControllerSourceType)mediaType pushViewController:(UIViewController *)viewController CameraCaptureMode:(UIImagePickerControllerCameraCaptureMode)mode  completion:(void(^)(NSString *outPathString,BOOL isSuccess))completionHandle;

@end

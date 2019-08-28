//
//  LJPlayerViewController.h
//  AudioAndVideo
//
//  Created by LiJie on 2017/2/20.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJPlayerViewController : UIViewController

//传入要保存视频的 url 和 拍摄时的时间
- (instancetype)initWithFileUrl:(NSURL *)fileUrl currentTime:(NSString *)timeString;

@end

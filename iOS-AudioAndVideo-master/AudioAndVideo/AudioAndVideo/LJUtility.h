//
//  LJUtility.h
//  AudioAndVideo
//
//  Created by LiJie on 2017/2/20.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LJUtility : NSObject

//获取当前的时间
+ (NSString *)stringWithCurrentTime;

//获取当前的时间戳
+ (NSString *)getNowTimeTimestamp;

//alterView
+ (void)showMsgWithTitle:(NSString *)title andContent:(NSString *)content;


@end

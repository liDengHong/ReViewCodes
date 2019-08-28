//
//  LJUtility.m
//  AudioAndVideo
//
//  Created by LiJie on 2017/2/20.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "LJUtility.h"

@implementation LJUtility

//获取当前的时间
+ (NSString *)stringWithCurrentTime {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSDate *nowDate = [NSDate date];
    NSString *time = [formatter stringFromDate:nowDate]
    ;
    return time;
}

//获取当前的时间戳
+ (NSString *)getNowTimeTimestamp {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterLongStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"Beijing"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];
    NSString *timeStamp = [NSString stringWithFormat:@"%ld", (long)[datenow timeIntervalSince1970]];
    return timeStamp;
}

+ (void)showMsgWithTitle:(NSString *)title andContent:(NSString *)content
{
    [[[UIAlertView alloc] initWithTitle:title message:content delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil] show];
}
@end

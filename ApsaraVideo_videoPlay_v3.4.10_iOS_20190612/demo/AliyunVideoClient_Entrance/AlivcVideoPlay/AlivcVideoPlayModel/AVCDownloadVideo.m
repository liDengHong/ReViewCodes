//
//  AVCDownloadVideo.m
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/4/18.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AVCDownloadVideo.h"
#import "NSString+AlivcHelper.h"


@implementation AVCDownloadVideo

@synthesize downloadStatus = _downloadStatus;

- (instancetype)initWithMedia:(AliyunDownloadMediaInfo *)media{
    self = [super init];
    if (self) {
        _mediaInfo = media;
        [self refreshSavePropertyValueWithMediaInfo:_mediaInfo];
    }
    return self;
}

- (BOOL)refreshStatusWithMedia:(AliyunDownloadMediaInfo *)media{
    if([media.vid isEqualToString:self.video_id] && media.quality == [self.video_quality integerValue] && [media.format isEqualToString:self.video_format]){
        _mediaInfo = media;
        [self refreshSavePropertyValueWithMediaInfo:_mediaInfo];
        return true;
    }
    return false;
}

/**
 刷新存储属性的值

 @param media sdk返回的视频信息
 */
- (void)refreshSavePropertyValueWithMediaInfo:(AliyunDownloadMediaInfo *)media{
    self.video_id = media.vid;
    self.video_progress = @(media.downloadProgress);
    self.video_size = @(media.size);
    self.video_title = media.title;
    self.video_imageUrlString = media.coverURL;
    self.video_quality = @(media.quality);
    self.video_fileName = media.downloadFileName;
    self.video_format = media.format;
}

- (void)setDownloadStatus:(AVCDownloadStatus)downloadStatus{
    _downloadStatus = downloadStatus;
    NSInteger value = (NSInteger)downloadStatus;
    _video_status = @(value);
}

- (AVCDownloadStatus)downloadStatus{
    NSInteger value = [_video_status integerValue];
    return (AVCDownloadStatus)value;
}

- (UIImage *)coverImage{
    if (!_coverImage) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *imageUrlString = [self coverImageurlString];
            if (imageUrlString) {
                NSURL *url = [NSURL URLWithString:imageUrlString];
                if (url) {
                    NSData *imageData = [NSData dataWithContentsOfURL:url];
                    if (imageData) {
                        _coverImage = [UIImage imageWithData:imageData];
                    }
                }
            }
          
        });
    }
    return _coverImage;
}

- (NSString *)coverImageurlString{
    NSString *imageUrlString = nil;
    if (self.mediaInfo.coverURL) {
        imageUrlString = self.mediaInfo.coverURL;
    }
    if (self.video_imageUrlString) {
        imageUrlString = self.video_imageUrlString;
    }
    return imageUrlString;
}

- (UIImage *__nullable)statusImage{
    return [AVCDownloadVideo imageWithStatus:self.downloadStatus];
}

- (NSString *__nullable)statusString{
    return [AVCDownloadVideo stringWithStatus:self.downloadStatus];
}

- (NSString *)title{
    if (_video_title) {
        return _video_title;
    }
    return self.mediaInfo.title;
}

- (NSString *)totalDataString{
    CGFloat size = 0;
    if (self.mediaInfo.size > 0) {
        size = self.mediaInfo.size;
      
    }
    if (_video_size) {
        size = [_video_size floatValue];
    }
    CGFloat mSize = size / 1024 / 1024;
    NSString *mString = [NSString stringWithFormat:@"%.1fM",mSize];
    return mString;
}

- (CGFloat )downloadProgress{
    NSInteger progress = 0;
    if (self.mediaInfo.downloadProgress) {
        progress = self.mediaInfo.downloadProgress;
    }
    if (_video_progress) {
        progress = [_video_progress integerValue];
    }
    return self.mediaInfo.downloadProgress / 100.0;
}



+ (UIImage *__nullable)imageWithStatus:(AVCDownloadStatus )status{
    switch (status) {
        case AVCDownloadStatusDownloading:
            return [UIImage imageNamed:@"avcDownloadPause"];
            break;
        case AVCDownloadStatusPause:
            return [UIImage imageNamed:@"avcDownload"];
            break;
        case AVCDownloadStatusWait:
            return [UIImage imageNamed:@"avcWait"];
            break;
        case AVCDownloadStatusFailure:
            return [UIImage imageNamed:@"avcDownload"];
            break;
        default:
            return  nil;
            break;
    }
    
}

+ (NSString *__nullable)stringWithStatus:(AVCDownloadStatus )status{
    switch (status) {
        case AVCDownloadStatusDownloading:
            return [@"下载中" localString];
            break;
        case AVCDownloadStatusWait:
            return [@"等待中" localString];
            break;
        case AVCDownloadStatusFailure:
            return [@"下载错误" localString];
            break;
        case AVCDownloadStatusPause:
            return [@"已暂停" localString];
        default:
            return  nil;
            break;
    }
}


+ (NSString *)savePath{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    return path;
}

- (BOOL)isSameWithOtherVideo:(AVCDownloadVideo *)otherVideo{
    if (self == otherVideo) {
        return true;
    }
    return  [self.video_id isEqualToString:otherVideo.video_id] && [self.video_quality isEqualToNumber:otherVideo.video_quality] && [self.video_format isEqualToString:otherVideo.video_format];
}

- (BOOL)isSameWithOtherMedia:(AliyunDownloadMediaInfo *)mediaInfo{
    return [self.video_id isEqualToString:mediaInfo.vid] && [self.video_quality integerValue] == mediaInfo.quality && [self.video_format isEqualToString:mediaInfo.format];
}

@end

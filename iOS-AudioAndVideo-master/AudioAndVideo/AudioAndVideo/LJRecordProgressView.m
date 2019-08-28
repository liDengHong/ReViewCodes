//
//  LJRecordProgressView.m
//  AudioAndVideo
//
//  Created by LiJie on 2017/3/3.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "LJRecordProgressView.h"

@implementation LJRecordProgressView

- (void)setProgress:(CGFloat)progress {
    _progress = progress;
    [self setNeedsDisplay];
}

- (void)setProgressColor:(UIColor *)progressColor {
    _progressColor = progressColor;
    [self setNeedsDisplay];
}

- (void)setLoadProgress:(CGFloat)loadProgress {
    _loadProgress = loadProgress;
    [self setNeedsDisplay];
}

- (void)setProgressBackgroundColor:(UIColor *)progressBackgroundColor {
    _progressBackgroundColor = progressBackgroundColor;
    [self setNeedsDisplay];
}

- (void)setLoadProgressColor:(UIColor *)loadProgressColor {
    _loadProgressColor = loadProgressColor;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    //获取当前的图像上下文
    CGContextRef contRef = UIGraphicsGetCurrentContext();
    
    //渲染进度的背景颜色
    CGContextAddRect(contRef, CGRectMake(0, 0, rect.size.width, rect.size.height));
    [self.progressBackgroundColor set];
    CGContextSetAlpha(contRef, 0.5);
    CGContextDrawPath(contRef, kCGPathFill);
    
    //渲染已经加载好的背景颜色
    CGContextAddRect(contRef, CGRectMake(0, 0, rect.size.width*self.loadProgress, rect.size.height));
    [self.progressBackgroundColor set];
    CGContextSetAlpha(contRef, 1);
    CGContextDrawPath(contRef, kCGPathFill);
    
    //渲染当前进度颜色
    CGContextAddRect(contRef, CGRectMake(0, 0, rect.size.width*self.progress, rect.size.height));
    [self.progressColor set];
    CGContextSetAlpha(contRef, 1);
    CGContextDrawPath(contRef, kCGPathFill);

}

@end

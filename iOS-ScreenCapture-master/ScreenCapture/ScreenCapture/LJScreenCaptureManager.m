//
//  LJScreenCaptureManager.m
//  ScreenCapture
//
//  Created by LiJie on 2018/7/31.
//  Copyright © 2018年 LiJieView. All rights reserved.
//

#import "LJScreenCaptureManager.h"

@implementation LJScreenCaptureManager

#pragma mark - 单利
static LJScreenCaptureManager *_instance = nil;
+ (instancetype)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    });
    return _instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone
{
    return [LJScreenCaptureManager defaultManager];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [LJScreenCaptureManager defaultManager];
}

- (id)mutablecopyWithZone:(NSZone *)zone
{
    return [LJScreenCaptureManager defaultManager];
}

- (void)screenCaptureForView:(__kindof UIView *)view {
    if ([view isKindOfClass:[UIScrollView class]]) {
        [self screenCaptureForScrollView:view];
    }else if ([view isKindOfClass:[UIWebView class]]) {
        UIWebView *webView = (UIWebView *)view;
        [self screenCaptureForScrollView:webView.scrollView];
    }
}

- (void)screenCaptureForScrollView:(UIScrollView *)scrollView {
    CGPoint currentOffset = scrollView.contentOffset;
    CGRect currentFrame = scrollView.frame;
    scrollView.contentOffset = CGPointZero;
    scrollView.frame = CGRectMake(0, 0, scrollView.contentSize.width, scrollView.contentSize.height);
    
    UIGraphicsBeginImageContextWithOptions(scrollView.contentSize, YES, UIScreen.mainScreen.scale);
    [scrollView.layer renderInContext:UIGraphicsGetCurrentContext()];
//    [scrollView drawViewHierarchyInRect:currentFrame afterScreenUpdates:NO];
    UIImage *screenCaptureImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    scrollView.contentOffset = currentOffset;
    scrollView.frame = currentFrame;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(screenCaptureDidFinish:)]) {
        [self.delegate screenCaptureDidFinish:screenCaptureImage];
    }
    
}

@end

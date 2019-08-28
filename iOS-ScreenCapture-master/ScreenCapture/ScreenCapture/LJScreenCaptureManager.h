//
//  LJScreenCaptureManager.h
//  ScreenCapture
//
//  Created by LiJie on 2018/7/31.
//  Copyright © 2018年 LiJieView. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol LJScreenCaptureManagerDelegate <NSObject>

- (void)screenCaptureDidFinish:(UIImage *)screenImage;

@end

@interface LJScreenCaptureManager : NSObject

+ (instancetype)defaultManager;

- (void)screenCaptureForView:(__kindof UIView *)view;

@property (nonatomic, weak) id<LJScreenCaptureManagerDelegate> delegate;


@end

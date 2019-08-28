//
//  LJScreenCaptureController.h
//  ScreenCapture
//
//  Created by LiJie on 2018/7/30.
//  Copyright © 2018年 LiJieView. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, LJScreenCaptureType) {
    LJScreenCaptureTypeScrollView,
    LJScreenCaptureTypeWKWebView,
    LJScreenCaptureTypeUIWebView
};

@interface LJScreenCaptureController : UIViewController

@property (nonatomic, assign) LJScreenCaptureType screenCaptureType;

@end

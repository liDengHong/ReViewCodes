//
//  UIViewController+LJNavHidden.h
//  根据 ScollView 操作导航栏的透明度
//
//  Created by LiJie on 2017/4/11.
//  Copyright © 2017年 LiJie. All rights reserved.
//
#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, LJNavBarHiddenTwoOptions) {
    
    LJNavBarHiddenTwoOptionsLeftItem = 0x01,
    LJNavBarHiddenTwoOptionsTitleItem = 0x01 << 1,
    LJNavBarHiddenTwoOptionsRightItem = 0x01 << 2,
    
};

@interface UIViewController (LJNavHidden)

- (void)setScrollView:(UIScrollView *)scrollView scrollViewOffsetY:(CGFloat)offsetY options:(LJNavBarHiddenTwoOptions)options;

- (void)setNavBarBackgoundImage:(UIImage *)navBarBackgoundImage;
- (void)lj_viewWillAppear:(BOOL)animated;
- (void)lj_viewWillDisappear:(BOOL)animated;
//- (void)lj_viewDidDisappear:(BOOL)animated;

@end

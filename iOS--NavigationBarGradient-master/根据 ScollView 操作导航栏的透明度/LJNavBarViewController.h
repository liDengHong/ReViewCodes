//
//  LJNavBarViewController.h
//  根据 ScollView 操作导航栏的透明度
//
//  Created by LiJie on 2017/4/11.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, LJNavBarHiddenOptions) {
    
    LJNavBarHiddenOptionsLeftItem = 0x01,
    LJNavBarHiddenOptionsTitleItem = 0x01 << 1,
    LJNavBarHiddenOptionsRightItem = 0x01 << 2,
    
};

@interface LJNavBarViewController : UIViewController

- (void)setScrollView:(UIScrollView *)scrollView scrollViewOffsetY:(CGFloat)offsetY options:(LJNavBarHiddenOptions)options;


@end

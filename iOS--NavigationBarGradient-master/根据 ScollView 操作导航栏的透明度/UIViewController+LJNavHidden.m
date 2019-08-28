//
//  UIViewController+LJNavHidden.m
//  根据 ScollView 操作导航栏的透明度
//
//  Created by LiJie on 2017/4/11.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "UIViewController+LJNavHidden.h"
#import <objc/runtime.h>

@interface UIViewController()

@property (nonatomic,strong) UIImage *navBarBackgoundImage;
@property (nonatomic,assign) CGFloat scrollViewOffsetY;
@property (nonatomic,assign) CGFloat alpha;
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,assign) LJNavBarHiddenTwoOptions hidenControlOptions;

@end

@implementation UIViewController (LJNavHidden)

- (void)setScrollView:(UIScrollView *)scrollView scrollViewOffsetY:(CGFloat)offsetY options:(LJNavBarHiddenTwoOptions)options {
    
    self.scrollView = scrollView;
    self.scrollViewOffsetY = offsetY;
    self.hidenControlOptions = options;
    /**< 添加观察者 >**/
    [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    CGPoint point = self.scrollView.contentOffset;
    self.alpha = point.y / self.scrollViewOffsetY;
    self.alpha = (self.alpha<=0)?0:self.alpha;
    self.alpha = (self.alpha>=1)?1:self.alpha;
    [self setNavBarSubViewAlpha];

}

- (void)dealloc {
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset" context:nil];
}

- (void)setNavBarSubViewAlpha {
    self.navigationItem.leftBarButtonItem.customView.alpha = self.hidenControlOptions &1?self.alpha:1;
    self.navigationItem.titleView.alpha = self.hidenControlOptions >> 1&1?self.alpha:1;
    self.navigationItem.rightBarButtonItem.customView.alpha = self.hidenControlOptions >> 2&1?self.alpha:1;
    [[[self.navigationController.navigationBar subviews]objectAtIndex:0] setAlpha:self.alpha];

}

#pragma mark -
- (void)lj_viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setBackgroundImage:self.navBarBackgoundImage forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [[UIImage alloc] init];
    [self setNavBarSubViewAlpha];
}

- (void)lj_viewWillDisappear:(BOOL)animated {
    self.navigationController.navigationBar.shadowImage = nil;
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [[[self.navigationController.navigationBar subviews]objectAtIndex:0] setAlpha:1];
}

#pragma mark - 关联属性
static const char *navBarBackgroundImageKey = "navBarBackgroundImageKey";
- (UIImage *)navBarBackgoundImage {
    return objc_getAssociatedObject(self, navBarBackgroundImageKey);
}

- (void)setNavBarBackgoundImage:(UIImage *)navBarBackgoundImage {
    objc_setAssociatedObject(self, navBarBackgroundImageKey, navBarBackgoundImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static const char *scrollViewKey = "ScrollViewKey";
- (UIScrollView *)scrollView {
    return objc_getAssociatedObject(self, scrollViewKey);
}

- (void)setScrollView:(UIScrollView *)scrollView {
    objc_setAssociatedObject(self, scrollViewKey, scrollView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static const char *scrolOffsetYKey = "offsetYKey";
- (CGFloat)scrollViewOffsetY {
    return [objc_getAssociatedObject(self, scrolOffsetYKey) floatValue];
}

- (void)setScrollViewOffsetY:(CGFloat)scrollViewOffsetY {
    objc_setAssociatedObject(self, scrolOffsetYKey, @(scrollViewOffsetY), OBJC_ASSOCIATION_ASSIGN);
}

static const char  *alphaKey = "alphaKey";
- (CGFloat)alpha {
    return [objc_getAssociatedObject(self, alphaKey) floatValue];
}

- (void)setAlpha:(CGFloat)alpha {
    objc_setAssociatedObject(self, alphaKey, @(alpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

static const char *hidenControlOptionsKey = "hidenControlOptionsKey";
- (LJNavBarHiddenTwoOptions)hidenControlOptions  {
    return [objc_getAssociatedObject(self, hidenControlOptionsKey) unsignedIntegerValue];
}

- (void)setHidenControlOptions:(LJNavBarHiddenTwoOptions)hidenControlOptions {
    objc_setAssociatedObject(self, hidenControlOptionsKey, @(hidenControlOptions), OBJC_ASSOCIATION_ASSIGN);
}

@end

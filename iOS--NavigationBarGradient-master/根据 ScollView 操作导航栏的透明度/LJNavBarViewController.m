//
//  Created by LiJie on 2017/4/11.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "LJNavBarViewController.h"

@interface LJNavBarViewController () {
    NSInteger _navBarHiddenOptions;
    CGFloat _scrollViewOffsetY;
    UIScrollView *_scrollView;
    CGFloat _alpha;
    UIImage *_navBarBackgoundImage;
}

@property (nonatomic,strong)UIScrollView *scrollView;

@end

@implementation LJNavBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)dealloc {
    [_scrollView removeObserver:self forKeyPath:@"contentOffset" context:nil];
}

#pragma mark -
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:(BOOL)animated];
    //设置背景图片
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"123"] forBarMetrics:UIBarMetricsDefault];
    //清除边框，设置一张空的图片
    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc]init]];
#warning 此处如果不加延迟 setNavBarSubViewAlpha 不会被调用
    //不明白为什么在子类是 另一个控制器 push 出来的时候,此方法中调用 setNavBarSubViewAlpha 不起作用, 加了延迟才会调用, 个人认为是push出来的子控件没还没加载完成.
    //    [self performSelector:@selector(setNavBarSubViewAlpha) withObject:nil afterDelay:0.05];
    [self setNavBarSubViewAlpha];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
    [[[self.navigationController.navigationBar subviews] objectAtIndex:0] setAlpha:1];
}


- (void)setScrollView:(UIScrollView *)scrollView scrollViewOffsetY:(CGFloat)offsetY options:(LJNavBarHiddenOptions)options {
    _navBarHiddenOptions = options;
    _scrollView = scrollView;
    _scrollViewOffsetY = offsetY;
    //添加 KVO 监听
    [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

/**
 *  监听按钮状态改变的方法
 *
 *  @param keyPath ScrollView改变的属性
 *  @param object  ScrollView
 *  @param change  改变后的数据
 *  @param context 注册监听时context传递过来的值
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    CGPoint point = _scrollView.contentOffset;
    _alpha =  point.y/_scrollViewOffsetY;
    _alpha = (_alpha <= 0)?0:_alpha;
    _alpha = (_alpha >= 1)?1:_alpha;
    [self setNavBarSubViewAlpha];
}

#pragma mark - 调整子视图的透明度
- (void)setNavBarSubViewAlpha {
    self.navigationItem.leftBarButtonItem.customView.alpha = _navBarHiddenOptions &1?_alpha:1;
    self.navigationItem.titleView.alpha = _navBarHiddenOptions >> 1&1?_alpha:1;
    self.navigationItem.rightBarButtonItem.customView.alpha = _navBarHiddenOptions >> 2&1?_alpha:1;
    [[[self.navigationController.navigationBar subviews]objectAtIndex:0] setAlpha:_alpha];
}

@end

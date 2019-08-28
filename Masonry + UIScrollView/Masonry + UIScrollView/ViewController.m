//
//  ViewController.m
//  Masonry + UIScrollView
//
//  Created by LiJie on 2018/8/7.
//  Copyright © 2018年 LiJieView. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>

@interface ViewController ()
@property (nonatomic, strong)UIScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self horizontalLayout];
}

#pragma mark - 竖向
- (void)verticalLayout {

_scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
[self.view addSubview:_scrollView];

[_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.view);
}];

UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
[self.scrollView addSubview:contentView];

[contentView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.edges.equalTo(self.scrollView);
    make.height.greaterThanOrEqualTo(@0.f);//此处保证容器View高度的动态变化 大于等于0.f的高度
}];

for (int i = 0; i < 50; i++) {
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor colorWithRed:(arc4random_uniform(256))/255.0 green:(arc4random_uniform(256))/255.0 blue:(arc4random_uniform(256))/255.0 alpha:1.0];
    [contentView addSubview:view];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(contentView.mas_top).offset(50 + (10 + 50) * i);
        make.left.mas_equalTo(contentView.mas_left).offset(20);
        make.height.mas_equalTo(50);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width - 40);
        if (i == 49) { //在最底部的 View 做边界约束, 以确定 contentView的 布局
            make.bottom.mas_equalTo(contentView.mas_bottom);
        }
    }];
}
}

#pragma mark - 横向
- (void)horizontalLayout {
    
    /** Frame 布局*/
//    _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
//    [self.view addSubview:_scrollView];
//    for (int i = 0; i < 50; i++) {
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10 + (100 + 10) * i, 100, 100, 100)];
//        view.backgroundColor = [UIColor colorWithRed:(arc4random_uniform(256))/255.0 green:(arc4random_uniform(256))/255.0 blue:(arc4random_uniform(256))/255.0 alpha:1.0];
//        [self.scrollView addSubview:view];
//        self.scrollView.contentSize = CGSizeMake(10 + (100 + 10) * 49, 0); // 此处需要重新赋值 ScrollView 的 contentSize
//    }
    
    /** Masonry 布局*/
    _scrollView = [[UIScrollView alloc] initWithFrame: CGRectZero];
    [self.view addSubview:_scrollView];
    
    UIView *view1 = [[UIView alloc] init];
    view1.backgroundColor = [UIColor redColor];
    [self.scrollView addSubview:view1];
    
    UIView *view2 = [[UIView alloc] init];
    view2.backgroundColor = [UIColor grayColor];
    [self.scrollView addSubview:view2];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.scrollView);
        make.width.equalTo(self.view.mas_width);
        make.height.equalTo(self.view.mas_height);
    }];
    
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view1.mas_right);
        make.top.bottom.right.equalTo(self.scrollView);
        make.width.equalTo(self.view.mas_width);
        make.height.equalTo(self.view.mas_height);
    }];

}

@end

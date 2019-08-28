//
//  LJShowImageController.m
//  ScreenCapture
//
//  Created by LiJie on 2018/7/30.
//  Copyright © 2018年 LiJieView. All rights reserved.
//

#import "LJShowImageController.h"

@interface LJShowImageController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation LJShowImageController

#pragma mark - super Method

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.imageView];
    self.imageView.frame = self.scrollView.frame;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat width = self.image.size.width;
    CGFloat height = self.image.size.height;
    self.scrollView.contentSize = CGSizeMake(width, height);
    self.imageView.frame = CGRectMake(0, 0, width, height);
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    if (self.image.size.height == UIScreen.mainScreen.bounds.size.height) {
//        self.scrollView.contentOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.frame.size.height);
//    }
}


- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithImage:_image];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _imageView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    }
    return _scrollView;
}

@end

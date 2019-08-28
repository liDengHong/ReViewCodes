//
//  LJVideoPlayerViewController.m
//  AudioAndVideo
//
//  Created by LiJie on 2017/5/3.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "LJVideoPlayerViewController.h"

@interface LJVideoPlayerViewController ()

@property (nonatomic,strong) NSURL *videoURL;
@property (nonatomic,strong) UIWebView *webView;

@end

@implementation LJVideoPlayerViewController

- (instancetype)initWithVideoURL:(NSURL *)videoURL
{
    self = [super init];
    if (self) {
        _videoURL = videoURL;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:_videoURL]];

}

-(UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webView.backgroundColor = [UIColor whiteColor];
    }
    return _webView;
}

#pragma mark - 支持横屏
-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
    
}

-(BOOL)shouldAutorotate
{
    return YES;
}

@end

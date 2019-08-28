//
//  LJScreenCaptureController.m
//  ScreenCapture
//
//  Created by LiJie on 2018/7/30.
//  Copyright © 2018年 LiJieView. All rights reserved.
//

#import "LJScreenCaptureController.h"
#import <WebKit/WebKit.h>
#import "LJScreenCaptureManager.h"
#import "LJShowImageController.h"

@interface LJScreenCaptureController ()<UITableViewDelegate,UITableViewDataSource,LJScreenCaptureManagerDelegate>

@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)UIWebView *webView;
@property (nonatomic, strong)WKWebView *wkWebView;

@end

@implementation LJScreenCaptureController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    switch (self.screenCaptureType) {
        case LJScreenCaptureTypeWKWebView: {
            
            [self.view addSubview:self.wkWebView];
            [self.wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://github.com/liDengHong"]]];
        }
            break;
            
        case LJScreenCaptureTypeUIWebView: {
            [self.view addSubview:self.webView];
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
        }
            break;
        case LJScreenCaptureTypeScrollView: {
            [self.view addSubview:self.tableView];
        }
            break;
        default:
            break;
    }
}

#pragma mark - getter
- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webView.backgroundColor = [UIColor yellowColor];
    }
    return _webView;
}

- (WKWebView *)wkWebView {
    if (!_wkWebView) {
        _wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        _wkWebView.backgroundColor = [UIColor greenColor];
    }
    return _wkWebView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
        _tableView.backgroundColor = [UIColor grayColor];
        _tableView.rowHeight = 30;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    }
    return _tableView;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = [NSString stringWithFormat:@"第 %ld 行",(long)indexPath.row];
    return cell;
}

#pragma mark - LJScreenCaptureManagerDelegate
- (void)screenCaptureDidFinish:(UIImage *)screenImage {
    LJShowImageController *imageViewController = [[LJShowImageController alloc] init];
    imageViewController.image = screenImage;
    [self.navigationController pushViewController:imageViewController animated:YES];
    [LJScreenCaptureManager defaultManager].delegate = nil; //防止多次委托
}

#pragma mark - 截图
- (IBAction)screenCaptureAction:(id)sender {
    [LJScreenCaptureManager defaultManager].delegate = self;
    switch (self.screenCaptureType) {
        case LJScreenCaptureTypeUIWebView:
            [[LJScreenCaptureManager defaultManager] screenCaptureForView:self.webView];
            break;
        case LJScreenCaptureTypeScrollView:
            [[LJScreenCaptureManager defaultManager] screenCaptureForView:self.tableView];
            break;
        case LJScreenCaptureTypeWKWebView:
            [[LJScreenCaptureManager defaultManager] screenCaptureForView:self.wkWebView];
            break;
            
        default:
            break;
    }
}

@end

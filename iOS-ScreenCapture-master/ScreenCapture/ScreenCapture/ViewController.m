//
//  ViewController.m
//  ScreenCapture
//
//  Created by LiJie on 2018/7/30.
//  Copyright © 2018年 LiJieView. All rights reserved.
//

#import "ViewController.h"
#import "LJScreenCaptureController.h"

@interface ViewController ()


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    LJScreenCaptureController *viewController = segue.destinationViewController;
    if ([segue.identifier isEqualToString:@"ScrollView"]) {
        viewController.screenCaptureType = LJScreenCaptureTypeScrollView;
    }else if ([segue.identifier isEqualToString:@"UIWebView"]) {
        viewController.screenCaptureType = LJScreenCaptureTypeUIWebView;
    }else {
        viewController.screenCaptureType = LJScreenCaptureTypeWKWebView;
    }
}



@end

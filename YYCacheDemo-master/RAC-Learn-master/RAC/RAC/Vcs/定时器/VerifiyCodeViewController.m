//
//  VerifiyCodeViewController.m
//  RAC
//
//  Created by Li.Mr on 2019/8/15.
//  Copyright © 2019年 Lijie. All rights reserved.
//

#import "VerifiyCodeViewController.h"

@interface VerifiyCodeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *authButton;
@property (nonatomic, assign) NSInteger time;
@property (nonatomic, strong) RACDisposable *dispoable;

@end

@implementation VerifiyCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self);
    [[self.authButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
       @strongify(self);
        NSLog(@"点击了");
        self.time = 10;
        x.enabled = NO;
        ///RAC的计时器
        self.dispoable = [[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] subscribeNext:^(NSDate * _Nullable x) {
            self.time--;
            NSString *title = self.time > 0 ? [NSString stringWithFormat:@"%ld秒后重新获取",(long)self.time] : @"点击获取验证码";
            [self.authButton setTitle:title forState:UIControlStateNormal];
            self.authButton.enabled = self.time > 0 ? NO : YES;
            if (self.time == 0) {
                [self.dispoable dispose];
            }
        }];
    }];
}


@end

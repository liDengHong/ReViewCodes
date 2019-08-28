//
//  LoginViewController.m
//  RAC
//
//  Created by Li.Mr on 2019/8/19.
//  Copyright © 2019年 Lijie. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self LoginButtonStatus];
}

- (void)LoginButtonStatus {
    ///监听文本框输入状态，确定按钮是否可以点击
    RAC(_loginButton,enabled) = [RACSignal combineLatest:@[_phoneTextField.rac_textSignal,_passwordTextField.rac_textSignal] reduce:^id _Nullable(NSString *phoneNumber,NSString *password){
        return @(phoneNumber.length && (password.length > 5));
    }];

    
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        
        RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            NSLog(@"开始请求");
            NSLog(@"请求成功");
            NSLog(@"处理数据");
            [subscriber sendNext:@"请求完成，数据给你"];
            [subscriber sendCompleted];
            return [RACDisposable disposableWithBlock:^{
                NSLog(@"结束了");
            }];
        }];
        return signal;
    }];
    
    [command.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        NSLog(@"登录成功，跳转页面");
    }];
    
    [[command.executing skip:1] subscribeNext:^(NSNumber * _Nullable x) {
        if ([x boolValue]) {
            NSLog(@"正在执行中……");
        }else{
            NSLog(@"执行结束了");
        }
    }];
    
    ///按钮事件
    [[self.loginButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"点击了  点击了");
        [command execute:@{@"account":_phoneTextField.text,@"password":_passwordTextField.text}];
    }];
}

@end

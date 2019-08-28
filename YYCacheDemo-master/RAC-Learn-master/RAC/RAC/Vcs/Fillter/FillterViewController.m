//
//  FillterViewController.m
//  RAC
//
//  Created by Li.Mr on 2019/8/16.
//  Copyright © 2019年 Lijie. All rights reserved.
//

#import "FillterViewController.h"

@interface FillterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation FillterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //此处的操作只是对信号的操作
//    [self fillterMethod]
    [self racIgnore];
}

#pragma mark - 过滤
- (void)fillterMethod {
    ///只有当 value的length > 5得时候才会订阅信号
    [[self.textField.rac_textSignal filter:^BOOL(NSString * _Nullable value) {
        return value.length > 5;
    }] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark - ignore
- (void)racIgnore {
    RACSubject *subject = [RACSubject subject];
    //TODO:忽略某一个值
//    [[subject ignore:@"123"]subscribeNext:^(id  _Nullable x) {
//        NSLog(@"%@",x);
//    }];
    //TODO:忽略所有值
//    [[subject ignoreValues] subscribeNext:^(id  _Nullable x) {
//
//    }];
    //TODO:某些值但不是全部
//    [[[[subject ignore:@"1"] ignore:@"2"] ignore:@"3"] subscribeNext:^(id  _Nullable x) {
//        NSLog(@"%@",x);
//    }];
//    [subject sendNext:@"1"];
//    [subject sendNext:@"2"];
//    [subject sendNext:@"3"];
//    [subject sendNext:@"4"];
//    [subject sendNext:@"5"];
//
//    [subject sendNext:@"a234"];
//    [subject sendNext:@"123"];
    
    //TODO: take 指定哪些信号 正序 (取前三个)
//    [[subject take:3] subscribeNext:^(id  _Nullable x) {
//        NSLog(@"%@",x);
//    }];
//    [subject sendNext:@"1"];
//    [subject sendNext:@"2"];
//    [subject sendNext:@"3"];
//    [subject sendNext:@"4"];
//    [subject sendNext:@"5"];
    
    //TODO: take 指定哪些信号 倒序 (取后三个)
//    [[subject takeLast:3] subscribeNext:^(id  _Nullable x) {
//        NSLog(@"%@",x);
//    }];
//    [subject sendNext:@"1"];
//    [subject sendNext:@"2"];
//    [subject sendNext:@"3"];
//    [subject sendNext:@"4"];
//    [subject sendNext:@"5"];
//    ///必须实现该方法
//    [subject sendCompleted];
//
    //TODO: takeUntil 标记 takeUntil需要一个信号作为标记，当标记的信号发送数据，就停止
//    RACSubject *subject1 = [RACSubject subject];
//    [[subject takeUntil:subject1] subscribeNext:^(id  _Nullable x) {
//        NSLog(@"%@",x);
//    }];
//
//    [subject1 subscribeNext:^(id  _Nullable x) {
//        NSLog(@"%@",x);
//    }];
//
//    [subject sendNext:@"1"];
//    [subject sendNext:@"2"];
//    [subject sendNext:@"3"];
//
//    [subject1 sendNext:@"Stop"];
//
//    [subject sendNext:@"4"];
//    [subject sendNext:@"5"];
    //TODO: distinctUntilChanged 信号去重(只能去重连续相同的信号) 还可以忽略掉数组、字典，但是不可以忽略模型对象
    [[subject distinctUntilChanged] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    [subject sendNext:@"1"];
    [subject sendNext:@"1"];
    [subject sendNext:@"1"];
    [subject sendNext:@"2"];
    [subject sendNext:@"1"];
    [subject sendNext:@"2"];
}


@end

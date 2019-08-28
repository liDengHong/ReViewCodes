//
//  ViewController.m
//  RAC
//
//  Created by Li.Mr on 2019/8/13.
//  Copyright © 2019年 Lijie. All rights reserved.
//

#import "ViewController.h"
#import "testView.h"
#import <RACReturnSignal.h>


@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) RACDisposable *subscriber;

@property (weak, nonatomic) IBOutlet testView *testView;
@property (weak, nonatomic) IBOutlet UIButton *testButton;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (nonatomic, strong) NSArray *vcArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //    [self createSignal];
    //    [self disposableClass];
    //    [self racSubjectAndRACReplaySubjectClass];
    //    [self basicUsage];
    self.dataArray = @[@"定时器",@"Fillter",@"登录"];
    self.vcArray = @[@"VerifiyCodeViewController",@"FillterViewController",@"LoginViewController"];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    //    [self racCommand];
    //    [self mainMethodBind];
    //    [self racTupleAndSeruence];
//    [self racLiftSelector];
    [self userMap];
}

#pragma mark - 创建信号
- (void)createSignal {
    //创建信号
    //createSignal只有在注册了消息接受者后才会调用
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        //发送信号
        [subscriber sendNext:@"你是真的不错啊"];
        return nil;
    }];
    //订阅信号
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"1-%@",x);
    }];
}

#pragma mark - RACDisposable
- (void)disposableClass {
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"创建信号");
        [subscriber sendNext:@"傻了啊你"];
        self.subscriber = subscriber;
        ///disposableWithBlock 是在对象取消订阅得时候调用 RACDisposable是用来处理取消订阅用的
        return [RACDisposable disposableWithBlock:^{
            NSLog(@"RACDisposable");
        }];
    }];
    
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark - RACSubject、RACReplaySubject
- (void)racSubjectAndRACReplaySubjectClass {
#pragma mark-RACSubject
    //创建信号
    RACSubject *subject = [RACSubject subject];
    //订阅信号(需要先订阅,可多订阅)
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"1-%@",x);
    }];
    
    [subject subscribeNext:^(id  _Nullable x) {
        NSLog(@"2-%@",x);
    }];
    //发送信号
    [subject sendNext:@"RACSubject"];
    
#pragma mark-RACReplaySubject
    //创建信号
    RACReplaySubject *replySubject = [RACReplaySubject subject];
    //发送信号
    [replySubject sendNext:@"RACReplaySubject"];
    //订阅信号
    [replySubject subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
}

#pragma mark - 基本使用(按钮event, 通知只是为了内聚代码)
- (void)basicUsage {
    
#pragma mark-监听view的方法
    [[self.testView rac_signalForSelector:@selector(testFloat)] subscribeNext:^(RACTuple * _Nullable x) {
        NSLog(@"%@",x);
    }];
    
#pragma mark-监听keyPath(1是只有当值改变了才会调用, 而2.3是只要运行就会调用)
    //TODO:1
    [self.testView rac_observeKeyPath:@"frame" options:NSKeyValueObservingOptionNew observer:nil block:^(id value, NSDictionary *change, BOOL causedByDealloc, BOOL affectedOnlyLastComponent) {
        NSLog(@"1-%@",value);
    }];
    //TODO:2
    [[self.testView rac_valuesForKeyPath:@"frame" observer:nil] subscribeNext:^(id  _Nullable x) {
        NSLog(@"2-%@",x);
    }];
    //TODO:3
    [RACObserve(self.testView, frame) subscribeNext:^(id  _Nullable x) {
        NSLog(@"3-%@",x);
    }];
    
#pragma mark-按钮event (UIControl 分类提供rac_signalForControlEvents)
    [[self.testButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        NSLog(@"%@",x);
    }];
    
#pragma mark-通知
    [[NSNotificationCenter defaultCenter] rac_addObserverForName:@"111" object:nil];
    
#pragma mark-监听textfield输入
    [[_textField rac_textSignal] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"text is %@",x);
        
    }];
    [[_textField rac_newTextChannel] subscribeNext:^(NSString * _Nullable x) {
        NSLog(@"newTextChannel is %@",x);
    }];
    //TODO:用textfield.text赋值;(返回信号)
    RAC(_label,text) = self.textField.rac_textSignal;
    
#pragma mark-代理, 使用RACSubject
    
}

#pragma mark - RACMulticastConnection
- (void)rACMulticastConnection {
    RACSignal *signal = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"发送网络请求");
        
        [subscriber sendNext:@"拿到网络数据"];
        return nil;
    }];
    //RACMulticastConnection其实是一个连接类，连接类的意思就是当一个信号被多次订阅，他可以帮我们避免多次调用创建信号中的block, 即上面的 ' [subscriber sendNext:@"拿到网络数据"];'
    RACMulticastConnection *connect = [signal publish];
    
    [connect.signal subscribeNext:^(id x) {
        NSLog(@"1 - %@",x);
    }];
    
    [connect.signal subscribeNext:^(id x) {
        NSLog(@"2 - %@",x);
    }];
    
    [connect.signal subscribeNext:^(id x) {
        NSLog(@"3 - %@",x);
    }];
    [connect connect];
}

#pragma mark - RACCommand
- (void)racCommand {
    RACCommand *command = [[RACCommand alloc] initWithSignalBlock:^RACSignal * _Nonnull(id  _Nullable input) {
        NSLog(@"%@",input);
        return [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
            [subscriber sendNext:@"大佬放过我吧"];
            return nil;
        }];
    }];
    ///一层一层的订阅,
    //    [command.executionSignals subscribeNext:^(id  _Nullable x) {
    //        NSLog(@"%@",x);
    //        [x subscribeNext:^(id  _Nullable x) {
    //            NSLog(@"这里会是什么 %@",x);
    //        }];
    //    }];
    
    //switchToLatest
    /*
     既然提到了skip那就随便可以提提其它的类似的方法
     filter过滤某些
     ignore忽略某些值
     startWith从哪里开始
     skip跳过（忽略）次数
     take取几次值 正序
     takeLast取几次值 倒序
     */
    [command.executionSignals.switchToLatest subscribeNext:^(id  _Nullable x) {
        NSLog(@"接受数据 %@",x);
    }];
    
    [[command.executing skip:1] subscribeNext:^(NSNumber * _Nullable x) {
        if ([x boolValue]) {
            NSLog(@"还在执行");
        }else{
            NSLog(@"执行结束了");
        }
    }];
    
    [command execute:@"飞吧"];
}

#pragma mark - 核心方法(bind)
- (void)mainMethodBind {
    RACSubject *subject = [RACSubject subject];
    RACSignal * signal = [subject bind:^RACSignalBindBlock _Nonnull{
        return ^RACSignal *(id _Nullable value, BOOL *stop){
            return [RACReturnSignal return:value];
        };
    }];
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"收到的数据 - %@",x);
    }];
    [subject sendNext:@"启动自毁程序"];
}

#pragma mark - 集合RACTuple、RACSequence
- (void)racTupleAndSeruence {
    
    #pragma mark-RACTuple
    //初始化数组
    //  RACTuple *tuple = [RACTuple tupleWithObjects:@"爱上京东",@"加", @122,nil];
    //从数组中添加元素
    //    RACTuple *tuple = [RACTuple tupleWithObjectsFromArray:@[@"爱上京东",@"加", @122]];
    RACTuple *tuple = [RACTuple tupleWithObjectsFromArray:@[@"爱上京东",@"加", @122] convertNullsToNils:YES];
    id value = tuple.first; //取下标值
    id value2 = tuple.last;
    NSLog(@"%@ %@",value,value2);
    
    #pragma mark-RACSequence
    NSArray * array = @[@"爱上京东",@"加", @122];
    
    RACSequence * sequence = array.rac_sequence;
    RACSignal * signal = sequence.signal;
        [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    ///链式(可代替for循环)
    [array.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    
    #pragma mark-代替字典
    NSDictionary *dict = @{@"name":@"Rac_name",
                           @"title":@"Rac_title",
                           @"decs":@"Rac_decs",
                           };
    ///此方法相当于字典遍历,会把每一个键值对遍历出来,结果是一个 RACTuple(first是key, last是value)
    [dict.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
        RACTupleUnpack(NSString *key,id value) = x;
        NSLog(@"key - %@   value - %@",key,value);
    }];
    ///字典转 模型
//    NSString * filePath = [[NSBundle mainBundle] pathForResource:@"Model.plist" ofType:nil];
//    NSArray * array = [NSArray arrayWithContentsOfFile:filePath];
//    NSMutableArray *mArray = [NSMutableArray array];
//    [array.rac_sequence.signal subscribeNext:^(id  _Nullable x) {
//        [mArray addObject:[Person personWithDict:x]];
//    }];
}

#pragma mark - racLiftSelector
- (void)racLiftSelector {
    RACSignal *signal1 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"正在下载 image1");
        [subscriber sendNext:@"image1"];
        return nil;
    }];
    RACSignal *signal2 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"正在下载 image2");
        [subscriber sendNext:@"image2"];
        return nil;
    }];
    RACSignal *signal3 = [RACSignal createSignal:^RACDisposable * _Nullable(id<RACSubscriber>  _Nonnull subscriber) {
        NSLog(@"正在下载 image3");
        [subscriber sendNext:@"image3"];
        return nil;
    }];
    [self rac_liftSelector:@selector(updateUIPic:pic2:pic3:) withSignalsFromArray:@[signal1,signal2,signal3]];
}

- (void)updateUIPic:(id)pic1 pic2:(id)pic2 pic3:(id)pic3{
    NSLog(@"我要加载了 : pic1 - %@ pic2 - %@ pic3 - %@",pic1,pic2,pic3);
}

#pragma mark - 映射
- (void)userMap {
    RACSubject *subject = [RACSubject subject];
    RACSignal *signal = [subject flattenMap:^__kindof RACSignal * _Nullable(id  _Nullable value) {
        value = [NSString stringWithFormat:@"%@ 你别问我，我也不知道！",value];
        return [RACReturnSignal return:value];
    }];
    [signal subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@",x);
    }];
    [subject sendNext:@"发生了什么?"];


    
//    [[subject map:^id _Nullable(id  _Nullable value) {
//        return [NSString stringWithFormat:@"%@ 你别问我，我也不知道！",value];
//    }] subscribeNext:^(id  _Nullable x) {
//        NSLog(@"%@",x);
//    }];
//    [subject sendNext:@"发生了什么?"];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = _dataArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Class newClass = NSClassFromString(self.vcArray[indexPath.row]);
    UIViewController *vc = [[newClass alloc] init];
    vc.title = self.dataArray[indexPath.row];
    [self.navigationController pushViewController:vc animated:YES];
}


@end





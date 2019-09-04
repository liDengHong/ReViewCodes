//
//  ViewController.m
//  GrandCentralDispatch
//
//  Created by Li.Mr on 2019/9/4.
//  Copyright © 2019 Lijie. All rights reserved.
//

/**
1. 在 GCD 中有两种队列：『串行队列』 和 『并发队列』。两者都符合 FIFO（先进先出）的原则。两者的主要区别是：执行顺序不同，以及开启线程数不同。
2. 队列和任务的组合:
    (1)同步执行 + 并发队列          不会开启新线程, 串行执行任务
    (2)异步执行 + 并发队列          会开启新线程, 并发执行任务
    (3)同步执行 + 串行队列          不会开启新线程, 串行执行任务
    (4)异步执行 + 串行队列          会开启一个新线程, 串行执行任务
    (5)同步执行 + 主队列            会死锁(主线程有一个特点：主线程会先执行主线程上的代码片段，然后才会去执行放在主队列中的任务。同步执行  dispatch_sync函数的特点：该函数只有在该函数中被添加到某队列的某方法执行完毕之后才会返回。即 方法会等待 task 执行完再返回)
    (6)异步执行 + 主队列            不会开启新的线程, 串行执行任务
 3. 住线程执行特点: 主线程执行特点，先执行主线程上的代码，再执行主队列中的任务
 */

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self concurrentQueueTest];
}

#pragma mark - 串行队列
- (void)serialQueueTest {
    //TODO:同步串行(不会开启新线程, 串行执行任务)
    NSLog(@"同步串行队列开始执行---%@",[NSThread currentThread]);
    dispatch_sync(dispatch_queue_create("serial.queue.sync.com", DISPATCH_QUEUE_SERIAL), ^{
        NSLog(@"这是一个同步串行队列---%@",[NSThread currentThread]);
    });
    NSLog(@"同步串行队列结束执行---%@",[NSThread currentThread]);
    
    NSLog(@"________________分割线______________________");

    //TODO:异步串行(会开启新线程, 串行执行任务)
    NSLog(@"异步串行队列开始执行---%@",[NSThread currentThread]);
    dispatch_async(dispatch_queue_create("serial.queue.async.com", DISPATCH_QUEUE_SERIAL), ^{
        NSLog(@"这是一个异步串行队列---%@",[NSThread currentThread]);
    });
    NSLog(@"异步串行队列结束执行---%@",[NSThread currentThread]);
}

#pragma mark - 主队列()
- (void)mainQueueTest {
    //TODO:主队列同步(死锁)
//    NSLog(@"主队列同步开始执行---%@",[NSThread currentThread]);
//    dispatch_sync(dispatch_get_main_queue(), ^{
//        NSLog(@"这是一个主队列同步---%@",[NSThread currentThread]);
//    });
//    NSLog(@"主队列同步结束执行---%@",[NSThread currentThread]);
//
    NSLog(@"________________分割线______________________");
    
    //TODO:主队列异步执行( 不会开启新的线程, 串行执行任务)
    NSLog(@"主队列异步开始执行---%@",[NSThread currentThread]);
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"这是一个主队列异步---%@",[NSThread currentThread]);
    });
    NSLog(@"主队列异步结束执行---%@",[NSThread currentThread]);
}

#pragma mark - 并行队列
- (void)concurrentQueueTest {
    
    //TODO:并行异步(会开启新线程, 并发执行任务)
    NSLog(@"并行异步队列开始执行---%@",[NSThread currentThread]);
    dispatch_async(dispatch_queue_create("concurrent.queue.async.com", DISPATCH_QUEUE_CONCURRENT), ^{
        NSLog(@"这是一个并行异步队列---%@",[NSThread currentThread]);
    });
    NSLog(@"并行异步队列结束执行---%@",[NSThread currentThread]);
    
    NSLog(@"________________分割线______________________");
    
    //TODO:并行同步(不会开启新线程, 串行执行任务)
    NSLog(@"并行同步队列开始执行---%@",[NSThread currentThread]);
    dispatch_sync(dispatch_queue_create("concurrent.queue.sync.com", DISPATCH_QUEUE_CONCURRENT), ^{
        NSLog(@"这是一个并行同步队列---%@",[NSThread currentThread]);
    });
    NSLog(@"并行同步队列结束执行---%@",[NSThread currentThread]);
    
}


@end

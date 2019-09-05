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
 
 4. 队列嵌套:
 区别              『异步执行+并发队列』嵌套『同一个并发队列』    『同步执行+并发队列』嵌套『同一个并发队列』          『异步执行+串行队列』嵌套『同一个串行队列』    『同步执行+串行队列』嵌套『同一个串行队列』
 同步（sync）        没有开启新的线程，串行执行任务               没有开启新线程，串行执行任务                      死锁卡住不执行                           死锁卡住不执行
 异步（async）       有开启新线程，并发执行任务                  有开启新线程，并发执行任务                        有开启新线程（1 条），串行执行任务          有开启新线程（1 条），串行执行任务
 
 5.
 
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
    [self dispatchBarrierAsync];
}


#pragma mark - 队列和任务的组合
#pragma mark-串行队列
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

#pragma mark-主队列()
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

#pragma mark-并行队列
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

#pragma mark - 复杂的队列嵌套
#pragma mark- 同步执行 + 并发队列, 嵌套同一个并发队列
- (void)concurrentQueueAndSyncNestconcurrent {
    //TODO:追加任务同步执行(没有开启新线程，串行执行任务)
    dispatch_queue_t queue = dispatch_queue_create("concurrentQueue.Sync.concurrent.com", DISPATCH_QUEUE_CONCURRENT);
    //    dispatch_async(queue, ^{
    //        ///同步执行
    //        dispatch_sync(queue, ^{
    //            // 追加任务 1
    //            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
    //            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
    //        });
    //    });
    
    //TODO:追加任务异步执行(有开启新线程，并发执行任务)
    dispatch_async(queue, ^{
        ///异步执行
        dispatch_async(queue, ^{
            [NSThread sleepForTimeInterval:2];              // 模拟耗时操作
            NSLog(@"1---%@",[NSThread currentThread]);      // 打印当前线程
        });
    });
}

#pragma mark - test
- (void)syncConcurrent {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"syncConcurrent---开始");
    dispatch_queue_t queue = dispatch_queue_create("syncConcurrent.com", DISPATCH_QUEUE_CONCURRENT);
    ///taskCoding
    dispatch_sync(queue, ^{
        sleep(2);
        NSLog(@"taskCodingThread---%@",[NSThread currentThread]);  // 打印当前线程
        NSLog(@"taskCoding");
    });
    
    ///taskDrinking
    dispatch_sync(queue, ^{
        sleep(2);
        NSLog(@"taskDrinkingThread---%@",[NSThread currentThread]);  // 打印当前线程
        NSLog(@"taskDrinking");
    });
    
    ///tastRest
    dispatch_sync(queue, ^{
        sleep(2);
        NSLog(@"tastRestThread---%@",[NSThread currentThread]);  // 打印当前线程
        NSLog(@"tastRest");
    });
}

#pragma mark - 线程间通讯
- (void)interthreadCommunication {
    dispatch_queue_t queue = dispatch_queue_create("interthreadCommunication.com", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        sleep(2);
        NSLog(@"task执行结束了");
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSLog(@"回到主线程了");
        });
    });
}

#pragma mark - dispatch_barrier_async
- (void)dispatchBarrierAsync {
    dispatch_queue_t queue = dispatch_queue_create("dispatchBarrierAsync", DISPATCH_QUEUE_CONCURRENT);
    
    //任务1
    dispatch_async(queue, ^{
        sleep(2);
        NSLog(@"任务1 Thread: %@",[NSThread currentThread]);
    });
    //任务2
    dispatch_async(queue, ^{
        sleep(2);
        NSLog(@"任务2 Thread: %@",[NSThread currentThread]);
    });
    //任务3
    dispatch_async(queue, ^{
        sleep(2);
        NSLog(@"任务3 Thread: %@",[NSThread currentThread]);
    });
    
    dispatch_barrier_sync(queue, ^{
        sleep(2);
        NSLog(@"任务  Thread: %@",[NSThread currentThread]);
        NSLog(@"执行 dispatch_barrier_sync");
    });
    //任务4
    dispatch_async(queue, ^{
        sleep(2);
        NSLog(@"任务4 Thread: %@",[NSThread currentThread]);
    });
    //任务 5
    dispatch_async(queue, ^{
        sleep(2);
        NSLog(@"任务5 Thread: %@",[NSThread currentThread]);
    });
    
}

@end


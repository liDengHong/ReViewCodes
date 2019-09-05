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
 
 5. dispatch_after: dispatch_after 方法并不是在指定时间之后才开始执行处理，而是在指定时间之后将任务追加到主队列中。严格来说，这个时间并不是绝对准确的，但想要大致延迟执行任务，dispatch_after 方法是很有效的 (不管在子线程还是主线程中用此方法m,最后等会回到b主线程)
 
 6. dispatch_apply: 按照指定的次数将指定的任务追加到指定的队列中，并等待全部队列执行结束(异步遍历), 等同于 enumerateObjectsWithOptions 参数为NSEnumerationConcurrent时的遍历, dispatch_apply 比 enumerateObjectsWithOptions 要快很多, 无论是在串行队列，还是并发队列中，dispatch_apply 都会等待全部任务执行完毕
 
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
    [self dispatchApply];
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

#pragma mark - dispatch_after
- (void)after {
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"asyncMain---begin");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 2.0 秒后异步追加任务代码到主队列，并开始执行
        NSLog(@"after---%@",[NSThread currentThread]);  // 打印当前线程
    });
}

#pragma mark - dispatch_once
- (void)once {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 只执行 1 次的代码（这里面默认是线程安全的）
    });
}

#pragma mark - dispatch_apply
- (void)dispatchApply {
    NSMutableArray *array = @[].mutableCopy;
    for (NSInteger i = 0; i<50000; i++) {
        [array addObject:@(1)];
    }

    ///异步遍历
    NSLog(@"开始shidsjidsjdisjdis   %@",[NSDate date]);
    ///enumerate遍历
    [array enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSLog(@"%zd-----%@----%@",idx,array[idx],[NSThread currentThread]);
    }];
    
    ///dispatch_apply遍历
//    dispatch_apply(array.count, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t index) {
//        ///异步遍历
//        NSLog(@"%zd-----%@----%@",index,array[index],[NSThread currentThread]);
//    });

    NSLog(@"结束shidsjidsjdisjdis   %@",[NSDate date]);
    NSLog(@"----------%@",[NSThread currentThread]);
}

#pragma mark - dispatch_group
- (void)dispatchGroup {
    dispatch_group_t group = dispatch_group_create();
    
}

@end


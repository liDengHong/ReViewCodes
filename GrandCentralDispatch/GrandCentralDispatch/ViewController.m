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
 
 3. 主线程执行特点: 主线程执行特点，先执行主线程上的代码，再执行主队列中的任务
 
 4. 队列嵌套:
 区别              『异步执行+并发队列』嵌套『同一个并发队列』    『同步执行+并发队列』嵌套『同一个并发队列』          『异步执行+串行队列』嵌套『同一个串行队列』    『同步执行+串行队列』嵌套『同一个串行队列』
 同步（sync）        没有开启新的线程，串行执行任务               没有开启新线程，串行执行任务                      死锁卡住不执行                           死锁卡住不执行
 异步（async）       有开启新线程，并发执行任务                  有开启新线程，并发执行任务                        有开启新线程（1 条），串行执行任务          有开启新线程（1 条），串行执行任务
 
 5. dispatch_after: dispatch_after 方法并不是在指定时间之后才开始执行处理，而是在指定时间之后将任务追加到主队列中。严格来说，这个时间并不是绝对准确的，但想要大致延迟执行任务，dispatch_after 方法是很有效的 (不管在子线程还是主线程中用此方法m,最后等会回到b主线程)
 
 6. dispatch_apply: 按照指定的次数将指定的任务追加到指定的队列中，并等待全部队列执行结束(异步遍历), 等同于 enumerateObjectsWithOptions 参数为NSEnumerationConcurrent时的遍历, dispatch_apply 比 enumerateObjectsWithOptions 要快很多, 无论是在串行队列，还是并发队列中，dispatch_apply 都会等待全部任务执行完毕
 
 7 .调用队列组的 dispatch_group_async 先把任务放到队列中，然后将队列放入队列组中。或者使用队列组的 dispatch_group_enter、dispatch_group_leave 组合来实现 dispatch_group_async,调用队列组的 dispatch_group_notify 回到指定线程执行任务。或者使用 dispatch_group_wait 回到当前线程继续向下执行（会阻塞当前线程
 
 8 . dispatch_group_wait 和 dispatch_group_notify的区别:
 1.dispatch_group_wait是当所有任务执行完成之后，才执行之后的操作会阻塞当前线程,
 2.dispatch_group_notify不会阻塞当前线程,
 
 9. dispatch_group_enter、dispatch_group_leave: 在使用dispatch_async , dispatch_group_t, dispatch_group_enter、dispatch_group_leave组合 追加任务时使用相当于 使用dispatch_group_async
 
 10. dispatch_barrier_async 该方法会等待前边追加到并发队列中的任务全部执行完毕之后，再将指定的任务追加到该异步队列中。然后在 dispatch_barrier_async 方法追加的任务执行完毕之后，异步队列才恢复为一般动作，接着追加任务到该异步队列并开始执行
 
 11. dispatch_semaphore 是持有计数的信号。类似于过高速路收费站的栏杆。可以通过时，打开栏杆，不可以通过时，关闭栏杆。在 Dispatch Semaphore 中，使用计数来完成这个功能，计数小于等于 0 时等待，不可通过。计数大于 0 时，计数减 1 且不等待，可通过
    1.Dispatch Semaphore 提供了三个方法：
        dispatch_semaphore_create：创建一个 Semaphore 并初始化信号的总量
        dispatch_semaphore_signal：发送一个信号，让信号总量加 1
        dispatch_semaphore_wait：可以使总信号量减 1，信号总量小于 0 时就会一直等待（阻塞所在线程），否则就可以正常执行。
    2.信号量的使用前提是：想清楚你需要处理哪个线程等待（阻塞），又要哪个线程继续执行，然后使用信号量。
    3.Dispatch Semaphore 作用：
        保持线程同步，将异步执行任务转换为同步执行任务
        保证线程安全，为线程加锁

 12.  dispatch_semaphore的原理: 当dispatch_semaphore_create中的参数(信号)大于0时执行 dispatch_semaphore_wait方法, 并且 信号数-1, 如果dispatch_semaphore_create中的参数(信号)不大于0, 阻塞当前线程, 不做-1操作, 直到执行了dispatch_semaphore_signal信号+1后才会把信号-1, 执行后续操作,相当于是一个while轮询
 
 12. 注意: 1. 同步操作时，在同一个串行队列中对当前队列sync操作都会导致死锁
          2. 异步操作时，如果在当前队列async，并不会开启新线程；在其他队列当中再对该串行队列进行asyn操作会开启新线程
 
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
    [self semaphoreSync];
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
    
    dispatch_barrier_async(queue, ^{
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
    
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"task 1");
        sleep(2);
        NSLog(@"task 1 Thread---%@",[NSThread currentThread]);  // 打印当前线程
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"task 2");
        sleep(2);
        NSLog(@"task 2 Thread---%@",[NSThread currentThread]);  // 打印当前线程
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"task 3");
        sleep(2);
        NSLog(@"task 3 Thread---%@",[NSThread currentThread]);  // 打印当前线程
    });
    
    dispatch_group_async(group, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"task 4");
        sleep(5);
        NSLog(@"task 4 Thread---%@",[NSThread currentThread]);  // 打印当前线程
    });
    
    
    //    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
    //        NSLog(@"执行结束了");
    //        NSLog(@"notify Thread---%@",[NSThread currentThread]);  // 打印当前线程
    //
    //    });
    
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"wait Thread---%@",[NSThread currentThread]);  // 打印当前线程
    
}

#pragma mark - leave enter
- (void)leaveAndEnter {
    dispatch_group_t group = dispatch_group_create();
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    dispatch_queue_t queue = dispatch_queue_create("leaveAndEnter.com", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        NSLog(@"task 1");
        sleep(2);
        NSLog(@"task 1 Thread---%@",[NSThread currentThread]);  // 打印当前线程
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        NSLog(@"task 2");
        sleep(2);
        NSLog(@"task 2 Thread---%@",[NSThread currentThread]);  // 打印当前线程
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        NSLog(@"task 3");
        sleep(2);
        NSLog(@"task 3 Thread---%@",[NSThread currentThread]);  // 打印当前线程
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        NSLog(@"task 4");
        sleep(2);
        NSLog(@"task 4 Thread---%@",[NSThread currentThread]);  // 打印当前线程
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        NSLog(@"task 5");
        sleep(2);
        NSLog(@"task 5 Thread---%@",[NSThread currentThread]);  // 打印当前线程
        dispatch_group_leave(group);
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 等前面的异步操作都执行完毕后，回到主线程.
        sleep(2);
        NSLog(@"3---%@",[NSThread currentThread]);      // 打印当前线程
        NSLog(@"group---end");
    });
    
}

#pragma mark - dispatch_semaphore
#pragma mark-semaphoreSync(线程同步)
- (void)semaphoreSync {
    
    __block int a = 0;
    __block int b = 0;
    NSLog(@"currentThread---%@",[NSThread currentThread]);  // 打印当前线程
    NSLog(@"semaphore---begin");
    
    dispatch_queue_t queue = dispatch_queue_create(0, DISPATCH_QUEUE_CONCURRENT);
    ///创建信号量
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    dispatch_async(queue, ^{
        sleep(2);
        a = 100;
        NSLog(@"a Thread---%@",[NSThread currentThread]);  // 打印当前线程
        ///信号量加1
        dispatch_semaphore_signal(semaphore);
    });
    
    ///信号量减1
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    dispatch_async(queue, ^{
        sleep(5);
        b = 300;
        NSLog(@"b Thread---%@",[NSThread currentThread]);  // 打印当前线程
        ///信号量加1
        dispatch_semaphore_signal(semaphore);
    });
    
    ///信号量减1
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
   
    NSLog(@"semaphore ---- end a = %d, b = %d",a,b);
}

#pragma mark - 一个神奇的面试题
- (void)test {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"A");
    });
    
    NSLog(@"B");
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    
    dispatch_sync(queue, ^{
        NSLog(@"C");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"D");
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"E");
    });
    
    [self performSelector:@selector(method) withObject:nil afterDelay:0.0];
    NSLog(@"F");
}

- (void)method {
    NSLog(@"G");
}
#pragma mark - semaphort group 搭配使用
- (void)dispatchGroupAndSemaphort {
    dispatch_group_t grp = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("concurrent.queue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_async(grp, queue, ^{
        dispatch_semaphore_t sema = dispatch_semaphore_create(0); ///创建信号量
        NSLog(@"task1 begin : %@",[NSThread currentThread]);
        dispatch_async(queue, ^{
            NSLog(@"task1 finish : %@",[NSThread currentThread]);
            dispatch_semaphore_signal(sema); ///发送信号量
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER); ///阻塞信号量
    });
    dispatch_group_async(grp, queue, ^{
        dispatch_semaphore_t sema = dispatch_semaphore_create(0); ///创建信号量
        NSLog(@"task2 begin : %@",[NSThread currentThread]);
        dispatch_async(queue, ^{
            NSLog(@"task2 finish : %@",[NSThread currentThread]);
            dispatch_semaphore_signal(sema);  ///发送信号量
        });
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);  ///阻塞信号量
    });
    dispatch_group_notify(grp, dispatch_get_main_queue(), ^{
        NSLog(@"refresh UI");
    });
}

#pragma mark - 利用dispatch_semaphore_t将数据追加到数组
- (void)addDataToArray {
    ///使用并发队列来更新数组，如果不使用信号量来进行控制，很有可能因为内存错误而导致程序异常崩溃
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    NSMutableArray *arrayM = [NSMutableArray arrayWithCapacity:10000];
    dispatch_semaphore_t sem = dispatch_semaphore_create(1);
    for (int i = 0; i < 10000; i++) {
        dispatch_async(queue, ^{
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);     // 创建为1的信号量 信号 -1
            [arrayM addObject:[NSNumber numberWithInt:i]];
            NSLog(@"%@",[NSNumber numberWithInt:i]);
            dispatch_semaphore_signal(sem); /// 一次add 操作完成后发送信号 +1
        });
    }
}

#pragma mark - 测试 异步操作时，如果在当前队列async，并不会开启新线程；在其他队列当中再对该串行队列进行asyn操作会开启新线程理论
- (void)testAsync {
    dispatch_queue_t queue = dispatch_queue_create("testAsync.com", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        NSLog(@"current thread: %@",[NSThread currentThread]); ///当前队列
        dispatch_async(queue, ^{
            NSLog(@"last thread: %@",[NSThread currentThread]); ///在当前队列中异步执行并不会开启新的线程
        });
    });
}
@end





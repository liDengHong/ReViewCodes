//
//  ViewController.m
//  LJLock
//
//  Created by Li.Mr on 2019/8/26.
//  Copyright © 2019年 Lijie. All rights reserved.
//


/**
 Thread Sanitizer :
 Xcode 8新加的功能 用来解决平时编写代码时难以调试的多线程问题, 用来解决多线程 Data races(数据抢夺)问题
 */

/**
 iOS 中的锁分类:
 1.自旋锁：是用于多线程同步的一种锁，线程反复检查锁变量是否可用。由于线程在这一过程中保持执行，因此是一种忙等待。一旦获取了自旋锁，线程会一直保持该锁，直至显式释放自旋锁。 自旋锁避免了进程上下文的调度开销，因此对于线程只会阻塞很短时间的场合是有效的
 OSSpinLock
 os_unfair_lock
 2.互斥锁（Mutex）：是一种用于多线程编程中，防止两条线程同时对同一公共资源（比如全局变量）进行读写的机制。该目的通过将代码切片成一个一个的临界区而达成。
 NSLock
 pthread_mutex
 pthread_mutex(recursive)递归锁
 @synchronized
 3.读写锁：是计算机程序的并发控制的一种同步机制，也称“共享-互斥锁”、多读者-单写者锁) 用于解决多线程对公共资源读写问题。读操作可并发重入，写操作是互斥的。 读写锁通常用互斥锁、条件变量、信号量实现。
 pthread_rwlock
 4.信号量（semaphore）：是一种更高级的同步机制，互斥锁可以说是semaphore在仅取值0/1时的特例。信号量可以有更多的取值空间，用来实现更加复杂的同步，而不单单是线程间互斥
 dispatch_semaphore
 5.条件锁：就是条件变量，当进程的某些资源要求不满足时就进入休眠，也就是锁住了。当资源被分配到了，条件锁打开，进程继续运行。
 NSCondition
 NSConditionLock
 6.递归锁
 NSRecursiveLock
 pthread_mutex(recursive)
 */

#import "ViewController.h"
#import <pthread.h>
#import <libkern/OSSpinLockDeprecated.h>



@interface ViewController ()

@property (atomic, strong) NSArray* array;
@property (atomic, strong) NSString* stringA;
@property (nonatomic,strong) NSMutableString *paper;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //    [self dataRacesExample];
    //    [self atomicTestExample];
    //    [self mutuallyExclusiveExample];
    //    [self recursionExample];
    //    [self spinExample];
    //    [self synchronizedExample];
    //    [self pthreadrwlockExample];
    //    [self recursiveLockExample];
    //    [self conditionExample];
    //    [self conditionLockExample];
    [self semaphoreExample];
}

#pragma mark - atomic示例(atomic只能保证getter setter方法的原子性, 也就是只能保证同时(严格的同时)执行getter setter方法的同步)
/**
 1.设置atomic之后，默认生成的getter和setter方法执行是原子的。也就是说，当我们在线程1执行getter方法的时候（创建调用栈，返回地址，出栈），线程B如果想执行setter方法，必须先等getter方法完成才能执行。举个例子，在32位系统里，如果通过getter返回64位的double，地址总线宽度为32位，从内存当中读取double的时候无法通过原子操作完成，如果不通过atomic加锁，有可能会在读取的中途在其他线程发生setter操作，从而出现异常值。如果出现这种异常值，就发生了多线程不安全。
 2.要想实现完全同步,需要对整个代码块加锁
 3.atomic由于加锁也会带来一些性能损耗，所以我们在编写iOS代码的时候，一般声明property为nonatomic，在需要做多线程安全的场景，自己去额外加锁做同步
 
 */
- (void)atomicTestExample {
    //TODO:数组测试
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 100000; i ++) {
            if (i % 2 == 0) {
                self.array = @[@"1", @"2", @"3"];
            }
            else {
                self.array = @[@"1"];
            }
            NSLog(@"Thread A: %@\n", self.array);
        }
    });
    
    for (int i = 0; i < 100000; i ++) {
        if (self.array.count >= 2) {  ///会有可能是在 进入这个判断的时候 self.stringA是  @[@"1", @"2", @"3"], 而getter(self.array)之后 执行 NSString* str = [self.array objectAtIndex:1]; 之前 self.array被重新赋值, 而值是 @[@"1"], 所以会报越界的错, 但不是必显
            NSString* str = [self.array objectAtIndex:1];
        }
        NSLog(@"Thread B: %@\n", self.array);
    }
    
    //TODO:字串符测试
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 100000; i ++) {
            if (i % 2 == 0) {
                self.stringA = @"a very long string";
            }
            else {
                self.stringA = @"string";
            }
            NSLog(@"Thread A: %@\n", self.stringA);
        }
    });
    
    for (int i = 0; i < 100000; i ++) {
        if (self.stringA.length >= 10) { ///会有可能是在 进入这个判断的时候 self.stringA是 @"a very long string", 而getter(self.stringA)之后 执行 NSString* subStr = [self.stringA substringWithRange:NSMakeRange(0, 10)]; 之前 self.stringA被重新赋值, 而值是 @"string", 所以会报越界的错, 但不是必显
            NSString* subStr = [self.stringA substringWithRange:NSMakeRange(0, 10)];
        }
        NSLog(@"Thread B: %@\n", self.stringA);
    }
}

#pragma mark - 资源抢夺示例
- (void)dataRacesExample {
    
    //    __block int count = 1;
    //    ///创建子线程,异步修改count
    //    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    //
    //        for (int i = 0; i < 10000; i ++) {
    //            count ++;
    //        }
    //    });
    //    ///主线程修改count
    //    for (int i = 0; i < 10000; i ++) {
    //        count ++;
    //    }
    
    NSMutableString* str = [@"" mutableCopy];
    ///创建子线程,异步修改str
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 0; i < 30000; i ++) {
            [str setString:@"123"];
            NSLog(@"str: %@",str);
        }
    });
    ///主线程修改str
    for (int i = 0; i < 30000; i ++) {
        [str setString:@"abc"];
        NSLog(@"str: %@",str);
    }
    
    //TODO:场景一:崩溃 报错data race
    /**
     ==================
     WARNING: ThreadSanitizer: data race (pid=83447)
     Write of size 4 at 0x7b0800003238 by thread T1:
     #0 __34-[ViewController dataRacesExample]_block_invoke ViewController.m:33 (LJLock:x86_64+0x100001144)
     #1 __tsan::invoke_and_release_block(void*) <null>:527008 (libclang_rt.tsan_iossim_dynamic.dylib:x86_64+0x657eb)
     #2 _dispatch_client_callout <null>:527008 (libdispatch.dylib:x86_64+0x4601)
     
     Previous write of size 4 at 0x7b0800003238 by main thread:
     #0 -[ViewController dataRacesExample] ViewController.m:38 (LJLock:x86_64+0x100001085)
     #1 -[ViewController viewDidLoad] ViewController.m:25 (LJLock:x86_64+0x100000f66)
     #2 -[UIViewController loadViewIfRequired] <null>:527008 (UIKitCore:x86_64+0x35b4e0)
     #3 start <null>:527008 (libdyld.dylib:x86_64+0x1574)
     
     Location is heap block of size 32 at 0x7b0800003220 allocated by main thread:
     #0 malloc <null>:527040 (libclang_rt.tsan_iossim_dynamic.dylib:x86_64+0x486ea)
     #1 _Block_object_assign <null>:527040 (libsystem_blocks.dylib:x86_64+0xb9b)
     #2 _Block_copy <null>:527040 (libsystem_blocks.dylib:x86_64+0x8cd)
     #3 -[ViewController dataRacesExample] ViewController.m:31 (LJLock:x86_64+0x100001044)
     #4 -[ViewController viewDidLoad] ViewController.m:25 (LJLock:x86_64+0x100000f66)
     #5 -[UIViewController loadViewIfRequired] <null>:527040 (UIKitCore:x86_64+0x35b4e0)
     #6 start <null>:527040 (libdyld.dylib:x86_64+0x1574)
     
     Thread T1 (tid=955286, running) is a GCD worker thread
     
     SUMMARY: ThreadSanitizer: data race ViewController.m:33 in __34-[ViewController dataRacesExample]_block_invoke
     ==================
     ThreadSanitizer report breakpoint hit. Use 'thread info -s' to get extended information about the report.
     */
    
    //TODO:场景二：计算出错
    /**
     最后计算的结果有很大概率小于20000，原因是count ++为非原子操作。这也是data race的场景，这种race没有crash也没有memory corruption，因此有些人把这种race称作benign race(良性的race)。
     */
    
    //TODO:场景三：乱序
    /**
     //thread 1
     count = 10;
     countFinished = true;
     
     //thread 2
     while (countFinished == false) {
     usleep(1000);
     }
     NSLog(@"count: %d", count);
     按理说，count最后会输出值10。可实际上，编译器并不知道thread 2对count和countFinished这两个变量的赋值顺序有依赖，所以基于优化的目的，有可能会调整thread 1中count = 10;和countFinished = true;生成的最后指令的执行顺序，最后也就导致count值输出的时机不对，虽然最后count的值还是10。这也可以看做是一种benign race，因为也不会crash，而是程序的流程出错。而且这种错误的调试及其困难，因为逻辑上是完全正确的，不明白其中缘由的同学甚至会怀疑是系统bug。
     
     遇到这种多线程读写状态，而且存在顺序依赖的场景，不能简单依赖代码逻辑。解决这种data race场景有一个简单办法：加锁，比如使用NSLock，将对顺序有依赖的代码块整个原子化，加锁之所以有用是因为会生成memory barrier，从而避免了编译器优化
     */
    
    //TODO:场景四：内存泄漏
    /*
     iOS刚诞生不久时，还没有多少Best Practise，不少人写单例的时候还不会用到dispatch_once_t，而是采用如下直白的写法：
     
     Singleton *getSingleton() {
     static Singleton *sharedInstance = nil;
     if (sharedInstance == nil) {
     sharedInstance = [[Singleton alloc] init];
     }
     return sharedInstance;
     }
     这种写法的问题是，多线程环境下，thread A和thread B会同时进入sharedInstance = [[Singleton alloc] init];，Singleton被多创建了一次，MRC环境就产生了内存泄漏。
     
     这是个经典的例子，也是data race的场景之一，其结果是造成额外的内存泄漏，这种race也可以算作是benign的，但也是我们平时编写代码应该避免的。
     
     上面几个是我们写iOS代码比较容易遇到的，还有其他一些就不一一举例了，只要理解了data race的含义都不难分析这些race导致的具体问题。
     **/
    
    
}

#pragma mark - 互斥锁
static pthread_mutex_t mumtexLock;
- (void)mutuallyExclusiveExample {
    //TODO:NSLock(注意：要求NSLock的lock和unlock需要在同一个Thread下面)
    ///创建互斥锁
    //    NSLock *lock = [[NSLock alloc] init];
    //    lock.name = @"lock 1";
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
    //        [lock lock]; ///加锁
    //        NSLog(@"task1 开始执行");
    //        for (int i = 0; i < 10; i++) {
    //            NSLog(@"task1 线程:%@",[NSThread currentThread]);
    //        }
    //        NSLog(@"task1 结束");
    //        [lock unlock]; ///解锁
    //    });
    //
    //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    //        [lock lock];
    //        NSLog(@"task2 开始执行");
    //        for (int i = 0; i < 10; i++) {
    //            NSLog(@"task2 线程:%@",[NSThread currentThread]);
    //        }
    //        NSLog(@"task2 结束");
    //        [lock unlock];
    //    });
    //TODO:pthread_mutex(C 语言下多线程加互斥锁的方式)
    //    pthread_mutex_init(&mumtexLock, NULL);
    //    ///创建线程1
    //    pthread_t thread1;
    //    pthread_create(&thread1, NULL, threadMethord1, NULL);
    //    ///创建线程2
    //    pthread_t thread2;
    //    pthread_create(&thread2, NULL, threadMethord2, NULL);
    
    //TODO:os_unfair_lock
    
    
}

void *threadMethord1() {
    ///加锁
    pthread_mutex_lock(&mumtexLock);
    printf("线程1\n");
    sleep(2);
    ///解锁
    pthread_mutex_unlock(&mumtexLock);
    printf("线程1解锁成功\n");
    return 0;
}

void *threadMethord2() {
    sleep(1);
    pthread_mutex_lock(&mumtexLock);
    printf("线程2\n");
    pthread_mutex_unlock(&mumtexLock);
    return 0;
}



#pragma mark - 自旋锁
- (void)spinExample {
    //TODO:OSSpinLock(10.0弃用，使用os_unfair_lock)
    __block OSSpinLock theLock = OS_SPINLOCK_INIT;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OSSpinLockLock(&theLock);
        NSLog(@"需要线程同步的操作1 开始");
        sleep(3);
        NSLog(@"需要线程同步的操作1 结束");
        OSSpinLockUnlock(&theLock);
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OSSpinLockLock(&theLock);
        sleep(1);
        NSLog(@"需要线程同步的操作2");
        OSSpinLockUnlock(&theLock);
    });
}

#pragma mark - @synchronize
- (void)synchronizedExample {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized(self) {
            sleep(2);
            NSLog(@"线程1");
        }
        sleep(1);
        NSLog(@"线程1解锁成功");
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized(self) {
            NSLog(@"线程2");
        }
    });
}

#pragma mark - pthread_rwlock(读写锁 读锁是共享锁，可以多个一起 写锁是独占锁排它锁，同时只允许一个线程)
static pthread_rwlock_t rwLock;
- (void)pthreadrwlockExample {
    self.paper = @"".mutableCopy;
    pthread_rwlock_init(&rwLock, NULL);
    ///写线程
    NSThread *threadWrite1 = [[NSThread alloc] initWithTarget:self selector:@selector(threadWrite1Action) object:nil];
    [threadWrite1 start];
    
    NSThread *threadWrite2 = [[NSThread alloc] initWithTarget:self selector:@selector(threadWrite2Action) object:nil];
    [threadWrite2 start];
    
    NSThread *threadWrite3 = [[NSThread alloc] initWithTarget:self selector:@selector(threadWrite3Action) object:nil];
    [threadWrite3 start];
    
    ///读线程
    NSThread *threadReader1 = [[NSThread alloc] initWithTarget:self selector:@selector(threadReader1Action) object:nil];
    [threadReader1 start];
    
    NSThread *threadReader2 = [[NSThread alloc] initWithTarget:self selector:@selector(threadReader2Action) object:nil];
    [threadReader2 start];
    
    NSThread *threadReader3 = [[NSThread alloc] initWithTarget:self selector:@selector(threadReader3Action) object:nil];
    [threadReader3 start];
}

- (void)threadWrite1Action {
    pthread_rwlock_wrlock(&rwLock);
    NSLog(@"threadWrite1 开始写入");
    sleep(arc4random()%5);
    [self.paper appendString:@"threadWrite1"];
    NSLog(@"threadWrite1 结束写入");
    pthread_rwlock_unlock(&rwLock);
}

- (void)threadWrite2Action {
    pthread_rwlock_wrlock(&rwLock);
    NSLog(@"threadWrite2 开始写入");
    sleep(arc4random()%5);
    [self.paper appendString:@"threadWrite2"];
    NSLog(@"threadWrite2 写入结束");
    pthread_rwlock_unlock(&rwLock);
}

- (void)threadWrite3Action {
    pthread_rwlock_wrlock(&rwLock);
    NSLog(@"threadWrite3 开始写入");
    sleep(arc4random()%5);
    [self.paper appendString:@"threadWrite3"];
    NSLog(@"threadWrite3 写入结束");
    pthread_rwlock_unlock(&rwLock);
}

- (void)threadReader1Action {
    pthread_rwlock_rdlock(&rwLock);
    NSLog(@"threadReader1 开始读取 == %@",self.paper);
    sleep(arc4random()%3);
    NSLog(@"threadReader1 读取结束 == %@",self.paper);
    pthread_rwlock_unlock(&rwLock);
}

- (void)threadReader2Action {
    pthread_rwlock_rdlock(&rwLock);
    NSLog(@"threadReader2 开始读取 == %@",self.paper);
    sleep(arc4random()%3);
    NSLog(@"threadReader2 读取结束 == %@",self.paper);
    pthread_rwlock_unlock(&rwLock);
}

- (void)threadReader3Action {
    pthread_rwlock_rdlock(&rwLock);
    NSLog(@"threadReader3 开始读取 == %@",self.paper);
    sleep(arc4random()%3);
    NSLog(@"threadReader3 读取结束 == %@",self.paper);
    pthread_rwlock_unlock(&rwLock);
}

#pragma mark - 递归锁
#pragma mark-NSRecursiveLock(NSRecursiveLock 会记录上锁和解锁的次数，当二者平衡的时候，才会释放锁，其它线程才可以上锁成功)
- (void)recursiveLockExample {
    NSRecursiveLock *lock = [[NSRecursiveLock alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static void (^RecursiveBlock)(int);
        RecursiveBlock = ^(int value) {
            [lock lock];
            if (value > 0) {
                NSLog(@"value:%d", value);
                RecursiveBlock(value - 1);
            }
            [lock unlock];
        };
        RecursiveBlock(2);
    });
}

#pragma mark-pthread_mutex递归锁
- (void)recursionExample {
    ///定义mutex
    pthread_mutex_init(&mumtexLock, NULL);
    
    ///定义mutexattr
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
    
    pthread_mutex_init(&mumtexLock, &attr);
    pthread_mutexattr_destroy(&attr);
    
    pthread_t thread;
    //    pthread_create(&thread, NULL, threadMethord, 5); /// 5 是限制递归次数
    pthread_create(&thread, NULL, threadMethord(5), NULL); ///
}

void *threadMethord(int value) {
    pthread_mutex_lock(&mumtexLock); ///加锁,
    if (value > 0) {
        printf("Value:%i\n", value);
        sleep(1);
        threadMethord(value - 1);
    }
    pthread_mutex_unlock(&mumtexLock);
    return 0;
}

#pragma mark - 条件锁
#pragma mark-NSCondition
- (void)conditionExample {
    NSCondition *condition = [[NSCondition alloc] init];
    NSMutableArray *array = [NSMutableArray array];
    //线程1
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [condition lock];
        do {
            NSLog(@"没有元素");
            [condition wait]; ///等待
        } while (!array.count);
        [array removeAllObjects];
        NSLog(@"array removeAllObjects");
        [condition unlock];
    });
    
    //线程2
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(1);//以保证让线程2的代码后执行
        [condition lock];
        [array addObject:@1];
        NSLog(@"array addObject:@1");
        [condition unlock];
        [condition signal]; ///唤起信号
    });
}

#pragma mark-NSConditionLock(NSConditionLock 还可以实现任务之间的依赖)
- (void)conditionLockExample {
    //主线程中
    NSConditionLock *lock = [[NSConditionLock alloc] initWithCondition:0];
    
    //线程1
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [lock lockWhenCondition:1];
        NSLog(@"线程1");
        sleep(2);
        [lock unlock];
    });
    
    //线程2
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);//以保证让线程2的代码后执行
        if ([lock tryLockWhenCondition:0]) {
            NSLog(@"线程2");
            [lock unlockWithCondition:2];
            NSLog(@"线程2解锁成功");
        } else {
            NSLog(@"线程2尝试加锁失败");
        }
    });
    
    //线程3
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(2);//以保证让线程2的代码后执行
        if ([lock tryLockWhenCondition:2]) {
            NSLog(@"线程3");
            [lock unlock];
            NSLog(@"线程3解锁成功");
        } else {
            NSLog(@"线程3尝试加锁失败");
        }
    });
    
    //线程4
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(3);//以保证让线程2的代码后执行
        if ([lock tryLockWhenCondition:2]) {
            NSLog(@"线程4");
            [lock unlockWithCondition:1];
            NSLog(@"线程4解锁成功");
        } else {
            NSLog(@"线程4尝试加锁失败");
        }
    });
}

#pragma mark - (dispatch_semaphore)信号量
/*
 //传入的参数为long，输出一个dispatch_semaphore_t类型且值为value的信号量。
 //值得注意的是，这里的传入的参数value必须大于或等于0，否则dispatch_semaphore_create会返回NULL。
 dispatch_semaphore_create(long value);
 
 //这个函数会使传入的信号量dsema的值减1；
 dispatch_semaphore_wait(dispatch_semaphore_t dsema, dispatch_time_t timeout);
 
 //这个函数会使传入的信号量dsema的值加1；
 dispatch_semaphore_signal(dispatch_semaphore_t dsema);
 
 **/
///使异步操作变成同步(例如网络请求中需要等一个请求回来后再执行下一个请求)
- (void)semaphoreExample {
    
    dispatch_semaphore_t signal = dispatch_semaphore_create(0); ///value 信号量数量
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"需要线程同步的操作 1 开始");
        NSLog(@"1 : %@",[NSThread currentThread]);
        sleep(3);
        NSLog(@"需要线程同步的操作 1 结束");
        ///信号量加1
        dispatch_semaphore_signal(signal);
    });
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        ///信号量 -1
        NSLog(@"需要线程同步的操作 2 开始");

        NSLog(@"2 : %@",[NSThread currentThread]);
        dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER);
        sleep(4);
        NSLog(@"需要线程同步的操作 2 结束");
        ///信号量加1
        dispatch_semaphore_signal(signal);
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"需要线程同步的操作 3 开始");

        NSLog(@"3 : %@",[NSThread currentThread]);
        ///信号量 -1
        dispatch_semaphore_wait(signal, DISPATCH_TIME_FOREVER);
        sleep(1);
        NSLog(@"需要线程同步的操作 3 结束");
    });

}

@end

//
//  ViewController.m
//  NSOperation
//
//  Created by Li.Mr on 2019/9/9.
//  Copyright © 2019 Lijie. All rights reserved.
//

/**
 1. NSOperation、NSOperationQueue 优点:
 可添加完成的代码块，在操作完成后执行。
 添加操作之间的依赖关系，方便的控制执行顺序。
 设定操作执行的优先级。
 可以很方便的取消一个操作的执行。
 使用 KVO 观察对操作执行状态的更改：isExecuteing、isFinished、isCancelled。
 
 2. 操作（Operation):
 执行操作的意思，换句话说就是你在线程中执行的那段代码。
 在 GCD 中是放在 block 中的。在 NSOperation 中，我们使用 NSOperation 子类 NSInvocationOperation、NSBlockOperation，或者自定义子类来封装操作。
 
 3. 操作队列（Operation Queues):
 这里的队列指操作队列，即用来存放操作的队列。不同于 GCD 中的调度队列 FIFO（先进先出）的原则。NSOperationQueue 对于添加到队列中的操作，首先进入准备就绪的状态（就绪状态取决于操作之间的依赖关系），然后进入就绪状态的操作的开始执行顺序（非结束执行顺序）由操作之间相对的优先级决定（优先级是操作对象自身的属性)
 操作队列通过设置最大并发操作数（maxConcurrentOperationCount）来控制并发、串行。
 NSOperationQueue 为我们提供了两种不同类型的队列：主队列和自定义队列。主队列运行在主线程之上，而自定义队列在后台执行。
 
 4. NSOperation的实现
 创建操作：先将需要执行的操作封装到一个 NSOperation 对象中。
 创建队列：创建 NSOperationQueue 对象。
 将操作加入到队列中：将 NSOperation 对象添加到 NSOperationQueue 对象中。
 之后呢，系统就会自动将 NSOperationQueue 中的 NSOperation 取出来，在新线程中执行操作。下面我们来学习下 NSOperation 和 NSOperationQueue 的基本使用。
 
 10.2 NSOperationQueue 常用属性和方法
 
 取消/暂停/恢复操作
 - (void)cancelAllOperations; 可以取消队列的所有操作。
 - (BOOL)isSuspended; 判断队列是否处于暂停状态。 YES 为暂停状态，NO 为恢复状态。
 - (void)setSuspended:(BOOL)b; 可设置操作的暂停和恢复，YES 代表暂停队列，NO 代表恢复队列。
 操作同步
 - (void)waitUntilAllOperationsAreFinished; 阻塞当前线程，直到队列中的操作全部执行完毕。
 添加/获取操作`
 - (void)addOperationWithBlock:(void (^)(void))block; 向队列中添加一个 NSBlockOperation 类型操作对象。
 - (void)addOperations:(NSArray *)ops waitUntilFinished:(BOOL)wait; 向队列中添加操作数组，wait 标志是否阻塞当前线程直到所有操作结束
 - (NSArray *)operations; 当前在队列中的操作数组（某个操作执行结束后会自动从这个数组清除）。
 - (NSUInteger)operationCount; 当前队列中的操作数。
 获取队列
 + (id)currentQueue; 获取当前队列，如果当前线程不是在 NSOperationQueue 上运行则返回 nil。
 + (id)mainQueue; 获取主队列。
 注意：
 
 这里的暂停和取消（包括操作的取消和队列的取消）并不代表可以将当前的操作立即取消，而是当当前的操作执行完毕之后不再执行新的操作。
 暂停和取消的区别就在于：暂停操作之后还可以恢复操作，继续向下执行；而取消操作之后，所有的操作就清空了，无法再接着执行剩下的操作。
 
 */

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, assign) NSInteger ticketSurplusCount;
@property (nonatomic, strong) NSLock *lock;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.lock = [[NSLock alloc] init];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self initTicketStatusNotSave];
    
    ///如果在其他线程中执行操作,则会开启新线程
    //    [NSThread detachNewThreadSelector:@selector(useInvocationOperation) toTarget:self withObject:nil];
}

#pragma mark - NSInvocationOperation
- (void)useInvocationOperation {
    
    ///在没有使用 NSOperationQueue、在主线程中单独使用使用子类 NSInvocationOperation 执行一个操作的情况下，操作是在当前线程执行的，并没有开启新线程。
    ///因为代码是在主线程中调用的，所以打印结果为主线程。如果在其他线程中执行操作，则打印结果为其他线程
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(task1) object:nil];
    [op start];
}

- (void)task1 {
    for (int i = 0; i < 2; i++) {
        sleep(2);// 模拟耗时操作
        NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
    }
}

#pragma mark - NSBlockOperation
- (void)useBlockOperation {
    ///在没有使用 NSOperationQueue、在主线程中单独使用 NSBlockOperation 执行一个操作的情况下，操作是在当前线程执行的，并没有开启新线程
    ///因为代码是在主线程中调用的，所以打印结果为主线程。如果在其他线程中执行操作，则打印结果为其他线程
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            sleep(2);// 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    
    [operation start];
}

#pragma mark - addExecutionBlock
- (void)addExecutionBlock {
    ///通过 addExecutionBlock: 就可以为 NSBlockOperation 添加额外的操作。这些操作（包括 blockOperationWithBlock 中的操作）可以在不同的线程中同时（并发）执行。只有当所有相关的操作已经完成执行时，才视为完成。
    ///如果添加的操作多的话，blockOperationWithBlock: 中的操作也可能会在其他线程（非当前线程）中执行，这是由系统决定的，并不是说添加到 blockOperationWithBlock: 中的操作一定会在当前线程中执行。（可以使用 addExecutionBlock: 多添加几个操作试试）
    ///一般情况下，如果一个 NSBlockOperation 对象封装了多个操作。NSBlockOperation 是否开启新线程，取决于操作的个数。如果添加的操作的个数多，就会自动开启新线程。当然开启的线程数是由系统来决定的。
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 2; i++) {
            sleep(2);// 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    }];
    [operation addExecutionBlock:^{
        NSLog(@"额外任务- %@",[NSThread currentThread]);
    }];
    
    [operation start];
}

- (void)addOperationToQueue {
    
    ///获取住队列
    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
    ///创建队列(添加到此队列的自动异步执行, 开启新线程)
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    /*1. maxConcurrentOperationCount 默认情况下为-1，表示不进行限制，可进行并发执行。
      2. maxConcurrentOperationCount 为1时，队列为串行队列。只能串行执行。
      3. maxConcurrentOperationCount 大于1时，队列为并发队列。操作并发执行，当然这个值不应超过系统限制，即使自己设置一个很大的值，系统也会自动调整为 min{自己设定的值，系统设定的默认最大值}
     **/
    queue.maxConcurrentOperationCount = 1;
    ///添加操作
    NSOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"操作1");
        NSLog(@"1 thread:%@",[NSThread currentThread]);

    }];
    
    NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(operationAction) object:nil];

    [queue addOperation:blockOperation];
    [queue addOperation:invocationOperation];
    
}

- (void)operationAction {
    NSLog(@"操作2");
    NSLog(@"2 thread:%@",[NSThread currentThread]);
}

#pragma mark - NSOperation 操作依赖
- (void)addDependency {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"操作1");
    }];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"操作2");
    }];
    ///添加依赖
    [op1 addDependency:op2];

    [queue addOperation:op1];
    [queue addOperation:op2];    
}

#pragma mark - NSOperation 优先级
- (void)operationQueuePriority {
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"操作1");
    }];
    
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"操作2");
    }];
    
    NSBlockOperation *op3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"操作3");
    }];
    ///设置优先级
    op2.queuePriority = NSOperationQueuePriorityVeryHigh;
    
    [queue addOperation:op1];
    [queue addOperation:op2];
    [queue addOperation:op3];
}

#pragma mark - NSOperation、NSOperationQueue 线程间的通信
- (void)communication {
    // 1.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    
    // 2.添加操作
    [queue addOperationWithBlock:^{
        // 异步进行耗时操作
        for (int i = 0; i < 2; i++) {
            [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
        
        // 回到主线程
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            // 进行一些 UI 刷新等操作
            for (int i = 0; i < 2; i++) {
                [NSThread sleepForTimeInterval:2]; // 模拟耗时操作
                NSLog(@"2---%@", [NSThread currentThread]); // 打印当前线程
            }
        }];
    }];
}

- (void)initTicketStatusNotSave {
    NSLog(@"currentThread---%@",[NSThread currentThread]); // 打印当前线程
    
    self.ticketSurplusCount = 50;
    
    // 1.创建 queue1,queue1 代表北京火车票售卖窗口
    NSOperationQueue *queue1 = [[NSOperationQueue alloc] init];
    queue1.maxConcurrentOperationCount = 1;
    
    // 2.创建 queue2,queue2 代表上海火车票售卖窗口
    NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
    queue2.maxConcurrentOperationCount = 1;
    
    // 3.创建卖票操作 op1
    NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
        [self saleTicketSafe];
    }];
    
    // 4.创建卖票操作 op2
    NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
        [self saleTicketSafe];
    }];
    
    // 5.添加操作，开始卖票
    [queue1 addOperation:op1];
    [queue2 addOperation:op2];
}


/**
 * 售卖火车票(线程安全)
 */
- (void)saleTicketSafe {
    while (1) {
    
        // 加锁
        [self.lock lock];
        
        if (self.ticketSurplusCount > 0) {
            //如果还有票，继续售卖
            self.ticketSurplusCount--;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数:%ld 窗口:%@", (long)self.ticketSurplusCount, [NSThread currentThread]]);
            [NSThread sleepForTimeInterval:0.2];
        }
        
        // 解锁
        [self.lock unlock];
        
        if (self.ticketSurplusCount <= 0) {
            NSLog(@"所有火车票均已售完");
            break;
        }
    }
}

@end




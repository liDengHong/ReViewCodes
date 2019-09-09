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
    [self addExecutionBlock];
    
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

@end




//
//  ViewController.m
//  RunLoop
//
//  Created by Li.Mr on 2019/9/12.
//  Copyright © 2019 Lijie. All rights reserved.
//

/*
 RunLoop和线程是息息相关的，我们知道线程的作用是用来执行特定的一个或多个任务，在默认情况下，线程执行完之后就会退出，就不能再执行任务了。这时我们就需要采用一种方式来让线程能够不断地处理任务，并不退出。所以，我们就有了 RunLoop。
 
 1. 每一个线程都对应一个RunLoop, 每条线程都有唯一一个与它对应的RunLoop对象
 2. RunLoop 并不能保证线程安全, 我们只能在当前线程内部操作当前线程的RunLoop对象,而不能再当前线程内部去操作其他线程的RunLoop对象方法。
 3. RunLoop 对象在第一次获取RunLoop时创建,在线程结束的时候销毁。
 4. 主线程的 RunLoop 对象系统自动创建并维护, 而子线程的RunLoop对象需要我们自己去创建和维护。
 5. 逻辑图: https://upload-images.jianshu.io/upload_images/1877784-94c6cdb3a7864593.png?imageMogr2/auto-orient/strip|imageView2/2
 6. runLoopModes : UITrackingRunLoopMode, NSDefaultRunLoopMode, NSRunLoopCommonModes
 **/

#import "ViewController.h"

@interface ViewController ()<NSMachPortDelegate>
{
    NSInteger _index;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) NSThread *thread;

@property (nonatomic, strong) NSMachPort *port;



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //
    //    NSTimer *timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(printFunc) userInfo:nil repeats:YES];
    //    // 将定时器添加到当前RunLoop的NSDefaultRunLoopMode下 (此时如果滑动textView定时器就不会走);
    //    //将定时器添加到当前RunLoop的UITrackingRunLoopMode下 (此时如果滑动textView定时器就走, 如果不滑动textView定时器就不走);
    //    // 将定时器添加到当前RunLoop的NSRunLoopCommonModes下 (此时滑动textView的时候,定时器也会走);
    //    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    //
    //此方法相当于上面的代码执行,但是把当前的runloop添加在NSDefaultRunLoopMode下, 所有此方法需要慎重使用(会有runloop冲突,导致"printFunc"方法不执行);
    //    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(printFunc) userInfo:nil repeats:YES];
    [self residentThread];
}

- (void)printFunc {
    NSLog(@"定时器");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self cancelPreviousPerform];
}

- (void)getRunLoop {
    ///Core Foundation
    ///默认只有主线程的RunLoop,
    ///获取当前的runRef
    CFRunLoopRef runRef = CFRunLoopGetCurrent();
    ///获取主线程的runRef
    CFRunLoopRef mainRef = CFRunLoopGetMain();
    
    NSRunLoop *mainRunLoop = [NSRunLoop currentRunLoop];
    NSLog(@"current: %@, main: %@, mainRunLoop: %@",runRef,mainRef,mainRunLoop);
}

- (IBAction)buttonClick:(id)sender {
    /**
     查看调用堆栈:
     首先程序启动，调用16行的main函数，main函数调用15行UIApplicationMain函数，然后一直往上调用函数，最终调用到0行的BtnClick函数，即点击函数。
     同时我们可以看到11行中有Sources0，也就是说我们点击事件是属于Sources0函数的，点击事件就是在Sources0中处理的。
     而至于Sources1，则是用来接收、分发系统事件，然后再分发到Sources0中处理的。
     */
    NSLog(@"你点我干嘛");
}

- (void)runLoopObserverRef {
    /**
     最终变成了状态 32，也就是即将进入睡眠状态，说明RunLoop之后就会进入睡眠状态。
     */
    // 创建观察者
    CFRunLoopObserverRef observerRef = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities , YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        NSLog(@"监听到RunLoop发生改变---%zd",activity);
    });
    // 添加观察者到当前RunLoop中
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observerRef, kCFRunLoopDefaultMode);
    // 释放observer，最后添加完需要释放掉
    CFRelease(observerRef);
}

#pragma mark - RunLoop的使用
/**
 1. NSTimer的使用
 2. imageView延迟显示:
 (1)有时候，我们会遇到这种情况:
 当界面中含有UITableView，而且每个UITableViewCell里边都有图片。这时候当我们滚动UITableView的时候，如果有一堆的图片需要显示，那么可能会出现卡顿的现象。
 (2)因为UITableView继承自UIScrollView，所以我们可以通过监听UIScrollView的滚动，实现UIScrollView相关delegate即可。
 (3) 利用PerformSelector设置当前线程的RunLoop的运行模式
 3. 后台常驻线程:
 */

- (void)deferLoadImage {
    ///点击屏幕后,一直滑动textView, 4秒后imageView不会加载图片,因为在滑动过程中runLoopModes 是 UITrackingRunLoopMode, 所以 setImage不会走, 只有当 runLoopModes 切回NSDefaultRunLoopMode 时才会执行
    [self.imageView performSelector:@selector(setImage:) withObject:[UIImage imageNamed:@"image"] afterDelay:4.0 inModes:@[NSDefaultRunLoopMode]];
}

- (void)residentThread {
    self.thread = [[NSThread alloc] initWithTarget:self selector:@selector(threadAction) object:nil];
    [self.thread start];
}

- (void)addTaskToResidentThread {
    // 利用performSelector，在self.thread的线程中调用run2方法执行任务
    [self performSelector:@selector(addTaskAction) onThread:self.thread withObject:nil waitUntilDone:NO];
}

- (void)threadAction {
    /**
     1. 子线程的RunLoop默认是关闭的,需要手动开启 添加下边两句代码，就可以开启RunLoop(为 runloop添加一个 port就是为了让runloop一直等待,让runloop一直循环, 不让runloop死去,)，之后self.thread就变成了常驻线程，可随时添加任务，并交于RunLoop处理
     2. runUntilDate: 这个方法，会循环调用 runMode:beforeDate: 直到达到参数 NSDate 所指定的时间，也就是超时时间。
     3. runMode:beforeDate: 这个方法才是启动一次 RunLoop! 为什么这样说，稍后再解释。
     */
    
    [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
  
    // 测试是否开启了RunLoop，如果开启RunLoop，则来不了这里，因为RunLoop开启了循环。
    NSLog(@"未开启RunLoop");
}

- (void)addTaskAction {
    NSLog(@"----addTaskAction------");
}

#pragma mark - RunLoop 启动后如何接收消息
- (void)runLoopReceiveMessage{
    NSLog(@"%@",[[NSRunLoop currentRunLoop] currentMode]);
    //创建并启动一个 thread
    self.thread = [[NSThread alloc]initWithTarget:self selector:@selector(threadTest) object:nil];
    [self.thread setName:@"Test Thread"];
    [self.thread start];
    
    //向 RunLoop 发送消息的简便方法，系统会将消息传递到指定的 SEL 里面
    [self performSelector:@selector(receiveMsg) onThread:self.thread withObject:nil waitUntilDone:NO];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //直接去的子线程 RunLoop 的一个 port，并向其发送消息，这个是比较底层的 NSPort 方式进行线程通信
        [self.port sendBeforeDate:[NSDate date] components:[@[[@"hello" dataUsingEncoding:NSUTF8StringEncoding]] mutableCopy] from:nil reserved:0];
    });
}

- (void)threadTest{
    NSLog(@"%@",@"child thread start");
    //threadTest 这个方法是在 Test Thread 这个线程里面运行的。
    NSLog(@"%@",[NSThread currentThread]);
    //获取这个线程的 RunLoop 并让他运行起来
    NSRunLoop* runloop = [NSRunLoop currentRunLoop];
    self.port = [[NSMachPort alloc]init];
    self.port.delegate = self;
    [runloop addPort:self.port forMode:NSRunLoopCommonModes];
    //约等于runUntilDate:[NSDate distantFuture]
    [runloop run];
}

- (void)receiveMsg{
    NSLog(@"%@",[NSThread currentThread]);
    NSLog(@"receive msg");
}

#pragma mark-NSMachPortDelegate
- (void)handleMachMessage:(void *)msg{
    NSLog(@"handle message thread:%@",[NSThread currentThread]);
}

#pragma mark - testForDelay
- (void)testForDelay {
    ///延时调用方法 (performSelector)
    [NSThread detachNewThreadWithBlock:^{
        NSLog(@"performThread :%@",[NSThread currentThread]);
#warning 此处需要开启当前线程的runLoop, 否则 performAction 不会调用
        [self performSelector:@selector(performAction) withObject:nil afterDelay:2];
        [[NSRunLoop currentRunLoop] addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    }];
    
    ///延时调用方法 (dispatch_after)
    [NSThread detachNewThreadWithBlock:^{
        NSLog(@"performThread :%@",[NSThread currentThread]);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self gcdAction];
        });
    }];
}

- (void)performAction {
    NSLog(@"performActionThread: %@",[NSThread currentThread]);
}

- (void)gcdAction {
    NSLog(@"gcdActionThread: %@",[NSThread currentThread]);
}

#pragma mark - cancelPreviousPerform(取消调用)
- (void)cancelPreviousPerform {
//    [self performSelector:@selector(logEvent) withObject:nil];
//    [self performSelector:@selector(logEvent) withObject:@"logEvent" afterDelay:0];
//    [self performSelector:@selector(logEvent) withObject:@"logEvent" afterDelay:3];
//    [self performSelector:@selector(logEvent) withObject:@"logEvent" afterDelay:4];
//    [self performSelector:@selector(logEvent) withObject:@"logEvent" afterDelay:5];
    ////可以取消所有的有延迟参数performSelector调用的方法,但不能够取消没有延迟参数的performSelector方法
//    [NSObject cancelPreviousPerformRequestsWithTarget:self];//可以成功取消全部。
    ////如果是带参数，那取消时的参数也要一致，否则不能取消成功
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(logEvent) object:@"logEvent"];
    
    
    ///取消连续调用的
    for (int i =  0; i < 5; i ++) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(logEvent:) object:@(i == 0 ? 0 : i-1)];
        [self performSelector:@selector(logEvent:) withObject:@(i) afterDelay:2];
        ////cancelPreviousPerformRequestsWithTarget函数执行5次,但第一次执行的时候并没有([self performSelector:@selector(logEvent) withObject:nil afterDelay:2];)函数, 所以第一次调用cancelPreviousPerformRequestsWithTarget无效, 而 performSelector方法执行五次,所以最后有效的 执行 performSelector 方法只有一次
    };
}

- (void)logEvent:(NSNumber *)index {
    NSLog(@"执行了%@",index);
}

#pragma mark - NSRunLoop (NSOrderedPerform)
- (void)orderedPerform {
    
}

@end




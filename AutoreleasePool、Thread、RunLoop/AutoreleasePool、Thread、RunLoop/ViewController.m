//
//  ViewController.m
//  AutoreleasePool、Thread、RunLoop
//
//  Created by Li.Mr on 2019/9/17.
//  Copyright © 2019 Lijie. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self autoreleasePoolTest];
}

- (void)autoreleasePoolTest {
    ///尝试一: 在 @autoreleasepool 中创建 Person, 在 @autoreleasepool 执行完以后 Person 就会销户
//    @autoreleasepool {
//        Person *person = [[Person alloc] init];
//        NSLog(@"执行autoreleasePool中的代码");
//    }
//    
    //尝试二: 不加 @autoreleasepool, Person 会在该方法体执行完成后销毁, 两者的销毁时机不一样
    Person *person = [[Person alloc] init];
    NSLog(@"执行autoreleasePool中的代码");
    NSLog(@"方法结束");

}

@end



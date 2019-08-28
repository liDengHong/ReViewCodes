//
//  ViewController.m
//  创建对象的方法
//
//  Created by 李等宏 on 2017/2/8.
//  Copyright © 2017年 lijie. All rights reserved.
//

#import "ViewController.h"
#import "CreateObject1.h"
#import "CreateObject2.h"
#import "CreateObject3.h"
#import "User.h"
#import "UserBuilder.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createObject1];
    [self createObject2];
    [self createObject3];
    [self createObject4];
}


/***
 这种代码的问题在于 property 对于外部是可写的，property 处于随时可能变化的状态。属性的不可变性是非常重要的，同样对于一个 class，我们也应该优先考虑设计成 不可变 的。 所以此方法不严谨
 ***/
#pragma mark - 以 alloc init  创建的,
- (void)createObject1{
    CreateObject1 *object1 = [[CreateObject1 alloc] init];
    object1.name = @"小明";
    object1.age = 20;
    NSLog(@"%@今年%d岁了",object1.name,object1.age);
    
}

/***
如果将 属性 都设置成 readonly 的，或者不暴露 属性，属性 的赋值都通过 initWith 的方式来初始化，就可以得到一个具备 不可变 的 class 定义了
***/
#pragma mark - initWith 方式创建
- (void)createObject2 {
    CreateObject2 *object2 = [[CreateObject2 alloc] initWithName:@"小涛"];
    NSLog(@"他的名字叫 %@",object2.name);
    
//    object2.name = @"xiaoming";
}

/***
 只初始化部分的 属性
 ***/
#pragma mark -  只初始化部分的 属性
- (void)createObject3 {
    CreateObject3 *object31 = [[CreateObject3 alloc] initWithAge:10 signature:@"时光匆匆" name:@"小刘"];
    NSLog(@"%@今年%d岁了,签名是:%@",object31.name,object31.age,object31.signature);

    CreateObject3 *object32 = [[CreateObject3 alloc] initWithAge:12 signature:@"度日如年"];
    NSLog(@"%@的签名是:%@",object32.name,object31.signature);
    
    CreateObject3 *object33 = [[CreateObject3 alloc] initWithName:@"小李" age:15];
    NSLog(@"%@今年%d岁了",object33.name,object33.age);
}

/***
 通过一个中间类进行初始化,
 ***/
- (void)createObject4 {
    //但此方法不太符合 OC 的代码规范
    UserBuilder *builder = [[[[[UserBuilder alloc] init] name:@"六子"] age:10] signature:@"时光不老"];
    User *object4 = [[User alloc] initWithBuilder:builder];
    NSLog(@"%@今年%d岁了,签名是:%@",object4.name,object4.age,object4.signature);
}


@end

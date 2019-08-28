//
//  CreateObject3.m
//  创建对象的方法
//
//  Created by 李等宏 on 2017/2/9.
//  Copyright © 2017年 lijie. All rights reserved.
//

#import "CreateObject3.h"

@implementation CreateObject3

- (instancetype)initWithName:(NSString *)name age:(int)age
{
    self = [super init];
    if (self) {
        _name = name;
        _age = age;
    }
    return self;
}

- (instancetype)initWithAge:(int)age signature:(NSString *)signature
{
    self = [super init];
    if (self) {
        //age是只读的, self.age = age 调用了 age 的 setter 方法,所以只能用_age. _age 表示成员变量,没有实现 setter 方法
        _age = age;
        _signature = signature;
    }
    return self;
}

- (instancetype)initWithAge:(int)age signature:(NSString *)signature name:(NSString *)name
{
    self = [super init];
    if (self) {
        _age = age;
        _name = name;
        _signature = signature;
    }
    return self;
}

@end

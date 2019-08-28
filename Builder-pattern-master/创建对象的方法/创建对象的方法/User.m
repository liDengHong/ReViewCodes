//
//  User.m
//  创建对象的方法
//
//  Created by 李等宏 on 2017/2/9.
//  Copyright © 2017年 lijie. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)initWithBuilder:(UserBuilder *)builder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    _age = builder.age;
    _name = builder.name;
    _signature = builder.signature;
    return self;
}

@end

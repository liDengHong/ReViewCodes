//
//  UserBuilder.m
//  创建对象的方法
//
//  Created by 李等宏 on 2017/2/9.
//  Copyright © 2017年 lijie. All rights reserved.
//

#import "UserBuilder.h"

@implementation UserBuilder
/***
 给属性赋值,返回该类自己
 ***/
- (UserBuilder *)name:(NSString *)name {
    _name = name;
    return self;
}

- (UserBuilder *)age:(int)age {
    _age = age;
    return self;
}

- (UserBuilder *)signature:(NSString *)signature {
    _signature = signature;
    return self;
}

@end

//
//  CreateObject2.m
//  创建对象的方法
//
//  Created by 李等宏 on 2017/2/8.
//  Copyright © 2017年 lijie. All rights reserved.
//

#import "CreateObject2.h"


@implementation CreateObject2

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        _name = name;
    }
    return self;
}

/***
 此时在此类中就可以从外部传入的 name 属性了, 但在外部不能修改此属性了,因为是只读的.
 ***/

@end

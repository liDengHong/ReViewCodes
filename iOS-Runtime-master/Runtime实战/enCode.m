//
//  enCode.m
//  Runtime实战
//
//  Created by 小哥 on 2017/1/18.
//  Copyright © 2017年 小哥. All rights reserved.
//

#import "enCode.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

@implementation enCode

- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int count;
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivars[i];
        const char *name = ivar_getName(ivar);
        NSString *ivarName = [NSString stringWithUTF8String:name];
        //拿到属性对应的 key 值
        id value = [self valueForKey:ivarName];
        //归档
        [aCoder encodeObject:value forKey:ivarName];
    }
    //记得释放
    free(ivars);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        unsigned int count;
        Ivar *ivars = class_copyIvarList([self class], &count);
        for (int i = 0; i < count; i++) {
            Ivar ivar = ivars[i];
            const char *name = ivar_getName(ivar);
            NSString *ivarName = [NSString stringWithUTF8String:name];
            //解档
            id value = [aDecoder decodeObjectForKey:ivarName];
            //赋值给属性
            [self setValue:value forKey:ivarName];
        }
        free(ivars);
    }
    return self;
}

@end

//
//  People.m
//  iOS 消息转发机制
//
//  Created by LiJie on 2018/3/12.
//  Copyright © 2018年 LiJie. All rights reserved.
//


/**
 消息转发流程:
 第一步: 如果在类中没有找到 @selector() 中的方法, 先通过 resolveInstanceMethod 方法查看是否利用 class_addMethod 动态的添加过属性. 如果有的话,提前结束消息转发. 返回 YES, 否则返回 NO;
 
 第二步: 如果第一步没有动态的添加方法 返回NO ,消息转发机制就会调用 forwardingTargetForSelector 方法 看是否有别的类处理此方法. 如果有别的类能处理这个方法, 消息熏坏结束. 否则继续执行第三步.
 
 第三步: 如果还是为找到此方法,则继续 调用 - (void)forwardInvocation:(NSInvocation *)anInvocation，在调用forwardInvocation:之前会调用 - (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector方法来获取这个选择子的方法签名，然后在 -(void)forwardInvocation:(NSInvocation *)anInvocation方法中你就可以通过anInvocation拿到相应信息做处理
 
 第四步: 如果以上三个不走都无法找到此方法, 则调用 - (void)doesNotRecognizeSelector:(SEL)aSelector ,然后在这个方法里面做一些处理,防止程序crash
 */

#import "People.h"
#import <objc/runtime.h>
#import "Animals.h"
#import "Monkey.h"

@implementation People

void eat(id self, SEL _cmd) {
    NSLog(@"我是 eat 方法");
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    NSLog(@"resolveInstanceMethod->SEL: %@",NSStringFromSelector(sel));
    if (sel == @selector(eat)) {
        class_addMethod([self class], sel, (IMP)eat,"v@:");
        return YES;
    }
   return [super resolveInstanceMethod:sel];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    NSLog(@"forwardingTargetForSelector->SEL: %@",NSStringFromSelector(aSelector));
    Animals *animal = [[Animals alloc] init];
    if ([animal respondsToSelector:aSelector]) {
        return animal;
    }
    return [super forwardingTargetForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    NSLog(@"forwardInvocation: %@", NSStringFromSelector([anInvocation selector]));
    SEL selector = [anInvocation selector];
    Monkey *monkey = [[Monkey alloc] init];
    if ([monkey respondsToSelector:selector]) {
        return [anInvocation invokeWithTarget:monkey];
    }
    return [super forwardInvocation:anInvocation];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    NSLog(@"method signature for selector: %@", NSStringFromSelector(aSelector));
    if (aSelector == @selector(climbTree)) {
        return [NSMethodSignature signatureWithObjCTypes:"V@:@"];
    }
    return [super methodSignatureForSelector:aSelector];
}

- (void)doesNotRecognizeSelector:(SEL)aSelector {
    NSLog(@"doesNotRecognizeSelector: %@", NSStringFromSelector(aSelector));
    [super doesNotRecognizeSelector:@selector(notFindThisMethod)];
}

- (void)notFindThisMethod {
    NSLog(@"没有发现此方法");
}

@end

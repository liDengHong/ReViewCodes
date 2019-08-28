//
//  People+Associated.m
//  Runtime实战
//
//  Created by 小哥 on 2017/1/18.
//  Copyright © 2017年 小哥. All rights reserved.
//

#import "People+Associated.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

@implementation People (Associated)

#pragma mark - 添加 associatedBust 为属性
- (void)setAssociatedBust:(NSNumber *)bust {
    //设置关联对象
    objc_setAssociatedObject(self, @selector(associatedBust), bust, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSNumber *)associatedBust {
    // 得到关联对象
    return objc_getAssociatedObject(self, @selector(associatedBust));
}

#pragma mark - 添加 callBack 为属性
- (void)setCallBack:(callBack)callBack {
    objc_setAssociatedObject(self, @selector(callBack), callBack, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (callBack)callBack {
    return objc_getAssociatedObject(self, @selector(callBack));
}


@end

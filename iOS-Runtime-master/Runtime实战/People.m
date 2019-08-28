//
//  People.m
//  Runtime实战
//
//  Created by 小哥 on 2017/1/18.
//  Copyright © 2017年 小哥. All rights reserved.
//

#import "People.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif

@implementation People

- (NSDictionary *)allIvars {
    
    unsigned int count;
    NSMutableDictionary *resultDict = [@{} mutableCopy];
    Ivar *ivars = class_copyIvarList([self class], &count);
    for (int i = 0; i < count; i++) {
        Ivar var = ivars[i];
        const char *name = ivar_getName(var);
        NSString *ivarName = [NSString stringWithUTF8String:name];
        id value = [self valueForKey:ivarName];
        if (value) {
            resultDict[ivarName] = value;
        }else {
            resultDict[ivarName] = @"字典的key对应的value不能为nil哦！";
        }
    }
    free(ivars);
    return resultDict;
}

- (NSDictionary *)allMethods {
    
    unsigned int count;
    NSMutableDictionary *resultDict = [NSMutableDictionary dictionary];
    
    Method  *methods = class_copyMethodList([self class], &count);
    for (int i = 0; i < count; i++) {
        SEL sel = method_getName(methods[i]);
        const char *name = sel_getName(sel);
        NSString *methodName = [NSString stringWithUTF8String:name];
        
        //获取方法中的参数个数
        int arguments = method_getNumberOfArguments(methods[i]);
        resultDict[methodName] = @(arguments-2);
    }
    
    free(methods);
    return resultDict;
}

- (NSDictionary *)allProperties {
    
    unsigned int count;
    NSMutableDictionary *resultDict = [@{} mutableCopy];
    objc_property_t *propertys = class_copyPropertyList([self class], &count);
    
    for (int i = 0; i < count; i++) {
        objc_property_t property = propertys[i];
        const char *name = property_getName(property);
        NSString *propertyName = [NSString stringWithUTF8String:name];
        id value = [self valueForKey:propertyName];
        if (value) {
            resultDict[propertyName] = value;
        } else {
            resultDict[propertyName] = @"字典的key对应的value不能为nil哦！";
        }
    }
    free(propertys);
    return resultDict;
}

#pragma mark - 动态添加方法
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    // 我们没有给People类声明sing方法，我们这里动态添加方法
    if ([NSStringFromSelector(sel) isEqualToString:@"peopleIsSinging"]) {
        class_addMethod(self, sel, (IMP)otherSing, "v@:");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

void otherSing(id self, SEL cmd)
{
    NSLog(@"%@ 唱歌啦！",((People *)self).name);
}

- (void)peopleIsSinging {
    
    NSLog(@"人们正在唱歌");
}
@end

//
//  Model.m
//  Runtime实战
//
//  Created by 小哥 on 2017/1/18.
//  Copyright © 2017年 小哥. All rights reserved.
//

#import "Model.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif
@implementation Model

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        for (NSString *key in dict.allKeys) {
            id value = dict[key];
            SEL setter = [self propertySetterByKey:key];
            
            if(setter){
                // 这里还可以使用NSInvocation或者method_invoke，不再继续深究了，有兴趣google。
                ((void (*)(id, SEL, id))objc_msgSend)(self, setter, value);
            }
        }
    }
    return self;
}

- (NSDictionary *)modelToDict {
    unsigned int count = 0;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    
    if (count != 0) {
        NSMutableDictionary *resultDict = [@{} mutableCopy];
        
        for (NSUInteger i = 0; i < count; i ++) {
            const void *propertyName = property_getName(properties[i]);
            NSString *name = [NSString stringWithUTF8String:propertyName];
            
            SEL getter = [self propertyGetterByKey:name];
            if (getter) {
                id value = ((id (*)(id, SEL))objc_msgSend)(self, getter);
                if (value) {
                    resultDict[name] = value;
                } else {
                    resultDict[name] = @"字典的key对应的value不能为nil哦！";
                }
                
            }
        }
        
        free(properties);
        
        return resultDict;
    }
    
    free(properties);
    
    return nil;
}

#pragma mark - 生成 setter 方法
- (SEL)propertySetterByKey:(NSString *)key {
    // 首字母大写(方法名)
    NSString *propertySetterName = [NSString stringWithFormat:@"set%@:", key.capitalizedString];
    SEL setter = NSSelectorFromString(propertySetterName);
    if ([self respondsToSelector:setter]) {
        return setter;
    }
    return nil;
}

#pragma mark - 生成 getter方法
- (SEL)propertyGetterByKey:(NSString *)key {
    //方法名
    SEL getter = NSSelectorFromString(key);
    if ([self respondsToSelector:getter]) {
        return getter;
    }
    
    return nil;
}

@end

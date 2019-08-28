//
//  Person.m
//  KVO && KVC
//
//  Created by LiJie on 2018/3/15.
//  Copyright © 2018年 LiJie. All rights reserved.
//

#import "Person.h"

@implementation Person

- (instancetype)init
{
    self = [super init];
    if (self) {
        _food = [[Food alloc] init];
        _array = [NSMutableArray array];
    }
    return self;
}

#pragma mark -是否开启自动监听, 默认是开启的
//+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
//    return NO;
//}

+ (NSSet<NSString *> *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
    NSSet *keyPath = [super keyPathsForValuesAffectingValueForKey:key];
    if ([key isEqualToString:@"food"]) {
        NSArray *arr = @[@"_food.kind",@"_food.doodName"];
        keyPath = [keyPath setByAddingObjectsFromArray:arr];
    }
    return keyPath;
}

@end

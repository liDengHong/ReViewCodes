//
//  CreateObject3.h
//  创建对象的方法
//
//  Created by 李等宏 on 2017/2/9.
//  Copyright © 2017年 lijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreateObject3 : NSObject

@property(nonatomic,copy,readonly)NSString *name;
@property(nonatomic,assign,readonly) int age;
@property(nonatomic,copy,readonly)NSString *signature;

- (instancetype)initWithName:(NSString *)name age:(int)age;
- (instancetype)initWithAge:(int)age signature:(NSString *)signature;
- (instancetype)initWithAge:(int)age signature:(NSString *)signature name:(NSString *)name;


@end

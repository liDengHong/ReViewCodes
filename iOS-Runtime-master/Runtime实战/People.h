//
//  People.h
//  Runtime实战
//
//  Created by 小哥 on 2017/1/18.
//  Copyright © 2017年 小哥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface People : NSObject {
    //成员变量
    NSString *_occupation;
    NSString *_nationality;
}

//属性
@property(nonatomic,copy)NSString *name;
@property(nonatomic,assign)NSUInteger age;

//所有的属性
- (NSDictionary *)allProperties;
//所有的成员变量
- (NSDictionary *)allIvars;
//所有的方法
- (NSDictionary *)allMethods;

//消息动态解析 -------添加sing实例方法，但是不提供方法的实现。验证当找不到方法的实现时，动态添加方法
- (void)peopleIsSinging;

@end

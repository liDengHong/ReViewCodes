//
//  UserBuilder.h
//  创建对象的方法
//
//  Created by 李等宏 on 2017/2/9.
//  Copyright © 2017年 lijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserBuilder : NSObject
@property(nonatomic,copy,readonly)NSString *name;
@property(nonatomic,assign,readonly) int age;
@property(nonatomic,copy,readonly)NSString *signature;
- (UserBuilder *)name:(NSString *)name;
- (UserBuilder *)age:(int)age;
- (UserBuilder *)signature:(NSString *)signature;
@end

//
//  CreateObject2.h
//  创建对象的方法
//
//  Created by 李等宏 on 2017/2/8.
//  Copyright © 2017年 lijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CreateObject2 : NSObject
@property(nonatomic,copy,readonly)NSString *name;

- (instancetype)initWithName:(NSString *)name;

@end

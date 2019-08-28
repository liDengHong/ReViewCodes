//
//  enCode.h
//  Runtime实战
//
//  Created by 小哥 on 2017/1/18.
//  Copyright © 2017年 小哥. All rights reserved.
//

#import <Foundation/Foundation.h>
//必须遵守NSCopying协议
@interface enCode : NSObject<NSCoding>

@property(nonatomic,copy)NSString *name;
@property(nonatomic,assign) NSInteger age;
@property(nonatomic,copy)NSString *nationality;

@end

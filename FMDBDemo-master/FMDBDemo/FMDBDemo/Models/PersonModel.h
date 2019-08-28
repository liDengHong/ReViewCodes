//
//  PersonModel.h
//  FMDBDemo
//
//  Created by LiJie on 2018/5/9.
//  Copyright © 2018年 LiJie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersonModel : NSObject

@property(nonatomic,strong) NSNumber *ID;

@property(nonatomic,copy) NSString *name;

@property(nonatomic,assign) NSInteger age;

@property(nonatomic,assign) NSInteger number;
//一个人可以拥有多辆车
@property(nonatomic,strong) NSMutableArray *carArray;

@end

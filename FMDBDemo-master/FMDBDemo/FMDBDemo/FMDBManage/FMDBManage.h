//
//  FMDBManage.h
//  FMDBDemo
//
//  Created by LiJie on 2018/5/9.
//  Copyright © 2018年 LiJie. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PersonModel;
@class CarModel;

@interface FMDBManage : NSObject

#pragma mark -单利创建
+ (instancetype)shareManager;

#pragma mark - Person
// 添加 Person
- (void)addPersonWithPerson:(PersonModel *)person;
//删除 Person
- (void)deletePersonWithPerson:(PersonModel *)person;
//更新 Person
- (void)updatePersonWithPerson:(PersonModel *)person;
//获取所有 Person
- (NSMutableArray *)getAllPerson;

#pragma mark -Car
//给 person 添加 Car
- (void)addCar:(CarModel *)car toPerson:(PersonModel *)person;
//从 Person 中删除 Car
- (void)deleteCar:(CarModel *)car fromPerson:(PersonModel *)person;
//获取 Person 的所有车辆
- (NSMutableArray *)getAllCarFromPerson:(PersonModel *)person;
//删除 Person 的所有车辆
- (void)deleteAllCarFromPerson:(PersonModel *)person;

@end

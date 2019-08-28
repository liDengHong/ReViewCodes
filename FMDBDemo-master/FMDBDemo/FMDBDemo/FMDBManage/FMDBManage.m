//
//  FMDBManage.m
//  FMDBDemo
//
//  Created by LiJie on 2018/5/9.
//  Copyright © 2018年 LiJie. All rights reserved.
//

#import "FMDBManage.h"

#import <FMDB.h>
#import "PersonModel.h"
#import "CarModel.h"

static FMDBManage *_instance = nil;

@interface FMDBManage()<NSCopying,NSMutableCopying> {
    
    FMDatabase *_fmdbBase;
}

@end


@implementation FMDBManage

#pragma mark - 单利创建
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_instance == nil) {
            _instance = [super allocWithZone:zone];
            [_instance initFMDBDataBase];
        }
    });
    return _instance;
}

+ (instancetype)shareManager {
    return [[self alloc] init];
}

-(id)copyWithZone:(NSZone *)zone
{
    return _instance;
}
-(id)mutableCopyWithZone:(NSZone *)zone
{
    return _instance;
}

#pragma mark -初始化数据库

- (void)initFMDBDataBase {
    
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    // 文件路径
    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"person.sqlite"];
    
    // 实例化FMDataBase对象
    _fmdbBase = [FMDatabase databaseWithPath:filePath];
    
    //打开数据库
    [_fmdbBase open];
    
    //创建表
    NSString *personSql = @"CREATE TABLE 'person' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,'person_id' VARCHAR(255),'person_name' VARCHAR(255),'person_age' VARCHAR(255),'person_number'VARCHAR(255)) ";
    NSString *carSql = @"CREATE TABLE 'car' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,'own_id' VARCHAR(255),'car_id' VARCHAR(255),'car_brand' VARCHAR(255),'car_price'VARCHAR(255)) ";
    
    //执行建表
    [_fmdbBase executeUpdate:personSql];
    [_fmdbBase executeUpdate:carSql];
    
    //关闭数据库
    [_fmdbBase close];
}

#warning 无论执行什么操作,都需要打开数据库, 在操作执行完后需要关闭数据库
#pragma mark - Person
// 添加 Person
- (void)addPersonWithPerson:(PersonModel *)person {
    [_fmdbBase open];
    
    NSNumber *maxID = @(0);
    // 查询库中数据
    FMResultSet *result = [_fmdbBase executeQuery:@"SELECT * FROM person"];
    
    //在库中给 数据排序 ID
    while ([result next]) {
        if ([maxID integerValue] < [[result stringForColumn:@"person_id"] integerValue]) {
            maxID = @([[result stringForColumn:@"person_id"] integerValue] ) ;
        }
    }
    maxID = @([maxID integerValue] + 1);
    
    person.ID = maxID;
    
    [_fmdbBase executeUpdate:@"INSERT INTO person(person_id,person_name,person_age,person_number)VALUES(?,?,?,?)",maxID,person.name,@(person.age),@(person.number)];
    
    [_fmdbBase close];
}
//删除 Person(根据 ID)
- (void)deletePersonWithPerson:(PersonModel *)person {
    [_fmdbBase open];
    
    [_fmdbBase executeUpdate:@"DELETE FROM person WHERE person_id = ?",person.ID];
    
    [_fmdbBase close];

}
//更新 Person(根据 ID)
- (void)updatePersonWithPerson:(PersonModel *)person {
    [_fmdbBase open];
    
    [_fmdbBase executeUpdate:@"UPDATE 'person' SET person_name = ?  WHERE person_id = ? ",person.name,person.ID];
    [_fmdbBase executeUpdate:@"UPDATE 'person' SET person_age = ? WHERE person_id = ?",@(person.age),person.ID];
    [_fmdbBase executeUpdate:@"UPDATE 'person' SET person_number = ? WHERE person_id = ?",@(person.number),person.ID];
    
    [_fmdbBase close];

}
//获取所有 Person
- (NSMutableArray *)getAllPerson {
    [_fmdbBase open];
    
    // 用数组承载数据
    NSMutableArray *personArray = [NSMutableArray array];
    FMResultSet *result = [_fmdbBase executeQuery:@"SELECT *FROM person"];
    
    while ([result next]) {
        PersonModel *model = [[PersonModel alloc] init];
        model.ID = @([[result stringForColumn:@"person_id"] integerValue]);
        model.name = [result stringForColumn:@"person_name"];
        model.age = [[result stringForColumn:@"person_age"] integerValue];
        model.number = [[result stringForColumn:@"person_number"] integerValue];
        
        [personArray addObject:model];
    }
    
    [_fmdbBase close];

    return personArray;
}

#pragma mark -Car
//给 person 添加 Car
- (void)addCar:(CarModel *)car toPerson:(PersonModel *)person {
    [_fmdbBase open];
    
    NSNumber *maxID = @(0);
    //根据该 person 是否有车辆
    FMResultSet *result = [_fmdbBase executeQuery:@"SELECT * FROM car where own_id = ?",person.ID];
    while ([result next]) {
        if ([maxID integerValue] < [[result stringForColumn:@"car_id"] integerValue]) {
            maxID = @([[result stringForColumn:@"car_id"] integerValue]);
        }
    }
    car.carId = maxID; //深拷贝浅拷贝, 在此处修改 Model ViewController 中model 的元素也会发生变化 , 读数据时是根据 ID读取的,所以 ID 一定不能为空
    maxID = @([maxID integerValue] + 1);
    [_fmdbBase executeUpdate:@"INSERT INTO car(own_id,car_id,car_brand,car_price)VALUES(?,?,?,?)",person.ID,maxID,car.brand,@(car.price)];
    
    [_fmdbBase close];
}
//从 Person 中删除 Car
- (void)deleteCar:(CarModel *)car fromPerson:(PersonModel *)person {
    [_fmdbBase open];
    
    [_fmdbBase executeUpdate:@"DELETE FROM car WHERE own_id = ?  and car_id = ? ",person.ID,car.carId];
    
    [_fmdbBase close];
}

//获取 Person 的所有车辆
- (NSMutableArray *)getAllCarFromPerson:(PersonModel *)person {
    [_fmdbBase open];
    
    NSMutableArray *carArray = [NSMutableArray array];
    
    FMResultSet *result = [_fmdbBase executeQuery:@"SELECT * FROM car where own_id = ?",person.ID];
    
    while ([result next]) {
        CarModel *model = [[CarModel alloc] init];
        model.carId = @([[result stringForColumn:@"car_id"] integerValue]);
        model.price = [[result stringForColumn:@"car_price"] integerValue];
        model.brand = [result stringForColumn:@"car_brand"];
        model.ownId = @([[result stringForColumn:@"own_id"] integerValue]);
        [carArray addObject:model];
    }
    
    [_fmdbBase close];

    return carArray;
}
//删除 Person 的所有车辆
- (void)deleteAllCarFromPerson:(PersonModel *)person {
    [_fmdbBase open];
    
    [_fmdbBase executeUpdate:@"DELETE FROM car WHERE own_id = ?",person.ID];
    
    [_fmdbBase close];
    
}

@end

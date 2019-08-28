//
//  CarModel.h
//  FMDBDemo
//
//  Created by LiJie on 2018/5/9.
//  Copyright © 2018年 LiJie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CarModel : NSObject
//车的所有者
@property(nonatomic,strong ) NSNumber *ownId;

@property(nonatomic,strong) NSNumber *carId;

@property(nonatomic,copy) NSString *brand;

@property(nonatomic,assign) NSInteger price;

@end

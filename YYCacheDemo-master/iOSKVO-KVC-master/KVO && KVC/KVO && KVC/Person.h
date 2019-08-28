//
//  Person.h
//  KVO && KVC
//
//  Created by LiJie on 2018/3/15.
//  Copyright © 2018年 LiJie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Food.h"

@interface Person : NSObject

@property (nonatomic, copy)NSString *name;
@property (nonatomic, strong)Food *food;
@property (nonatomic, strong)NSMutableArray *array;  

@end

//
//  Model.h
//  Runtime实战
//
//  Created by 小哥 on 2017/1/18.
//  Copyright © 2017年 小哥. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSNumber *age;
@property (nonatomic, copy) NSString *occupation;

//生成 Model
- (instancetype)initWithDictionary:(NSDictionary *)dict;
// 转换成字典
- (NSDictionary *)modelToDict;

@end

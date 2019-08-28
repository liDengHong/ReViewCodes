//
//  People+Associated.h
//  Runtime实战
//
//  Created by 小哥 on 2017/1/18.
//  Copyright © 2017年 小哥. All rights reserved.
//

#import "People.h"

typedef void (^callBack)();

@interface People (Associated)

@property (nonatomic, strong) NSNumber *associatedBust; // 胸围
@property (nonatomic, copy) callBack callBack;  // 写代码

@end

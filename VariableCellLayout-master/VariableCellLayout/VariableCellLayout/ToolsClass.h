//
//  ToolsClass.h
//  VariableCellLayout
//
//  Created by lijie on 2017/2/6.
//  Copyright © 2017年 lijie. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ToolsClass : NSObject

@property(nonatomic,copy)NSString *identifier;
@property(nonatomic,strong)id data;
@property(nonatomic,assign) float rowHight;

- (instancetype)initWithCellIdentifier:(NSString *)cellIdentifier data:(id)data rowHight:(float)rowHight;

@end

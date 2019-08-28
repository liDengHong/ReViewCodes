//
//  ToolsClass.m
//  VariableCellLayout
//
//  Created by lijie on 2017/2/6.
//  Copyright © 2017年 lijie. All rights reserved.
//

#import "ToolsClass.h"

@implementation ToolsClass

- (instancetype)initWithCellIdentifier:(NSString *)cellIdentifier data:(id)data rowHight:(float)rowHight
{
    self = [super init];
    if (self) {
        self.identifier = cellIdentifier;
        self.data = data;
        self.rowHight = rowHight;
    }
    return self;
}

@end

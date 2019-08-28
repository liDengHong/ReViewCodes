//
//  ViewController.m
//  NSPredicateTest
//
//  Created by 秀健身admin on 2018/11/16.
//  Copyright © 2018年 秀健身admin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self testLogicalOperation];
}

#pragma mark - 比较运算符
- (void)testCompareOperation{
    /*
     <1>, =、==：判断两个表达式是否相等，在谓词中=和==是相同的意思都是判断，而没有赋值这一说
     <2>,>=，=>：判断左边表达式的值是否大于或等于右边表达式的值
     <3>,<=，=<：判断左边表达式的值是否小于或等于右边表达式的值
     <4>,>：判断左边表达式的值是否大于右边表达式的值
     <5>,<：判断左边表达式的值是否小于右边表达式的值
     <6>,!=、<>：判断两个表达式是否不相等
     <7>,BETWEEN：BETWEEN表达式必须满足表达式 BETWEEN {下限，上限}的格式，要求该表达式必须大于或等于下限，并小于或等于上限
     
     predicateWithFormat 中的key必须是所计算实例的属性, 例如: longValue
     
     **/
    NSNumber *testNumber = @3000;
    NSPredicate *numberPre = [NSPredicate predicateWithFormat:@"longValue > 1232"];
    if ([numberPre evaluateWithObject:testNumber]) {
        NSLog(@"testing : %@",testNumber);
    }else {
        NSLog(@"失败 : %@",testNumber);
    }
    
    NSPredicate *numBetweenberPre = [NSPredicate predicateWithFormat:@"longValue BETWEEN{1000,2000}"];
    if ([numBetweenberPre evaluateWithObject:testNumber]) {
        NSLog(@"在区间内testing : %@",testNumber);
    }else {
        NSLog(@"不在区间内 : %@",testNumber);
    }
}

#pragma mark - 逻辑运算符
- (void)testLogicalOperation {
    
    /*
     <1>,AND、&&：逻辑与，要求两个表达式的值都为YES时，结果才为YES。
     <2>,OR、||：逻辑或，要求其中一个表达式为YES时，结果就是YES
     <3>,NOT、 !：逻辑非，对原有的表达式取反
     **/
    NSArray *testArray = @[@1, @565, @455, @677, @5, @6,@60];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"longValue > 100 OR longValue < 50"];
    NSArray *resultArray = [testArray filteredArrayUsingPredicate:predicate];
    NSLog(@"%@",resultArray);
    NSNumber *indexOne = @10;
    NSNumber *indexTwo = @20;
    NSPredicate *noPredicate = [NSPredicate predicateWithFormat:@"longValue > %ld",indexOne];
    if([noPredicate evaluateWithObject:indexTwo]) {
        NSLog(@"indexOne == indexTwo ");
    }else {
        NSLog(@"indexOne != indexTwo ");
    };
}

#pragma mark - 字符串之间的运算
/*
    BEGINSWITH : 检查某个字符串是否以指定的字符串
    ENDSWITH : 检查某个字符串是否以指定的字符结尾
    CONTAINS : 检查某个字符串是否包含指定的字符串
 **/

@end

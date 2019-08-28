//
//  ViewController.m
//  iOS 常用算法
//
//  Created by LiJie on 2018/3/5.
//  Copyright © 2018年 LiJie. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //    [self bubbleSortAscendingAndDescendingForC];
    
    //    [self bubbleSortAscendingAndDescendingForOC];
    
    //    [self SelectionSortingForOC];
    
    //    [self insertionAscendingSortingAscendingAndDescendingForOC];
    
    //      [self twoPointFindDataForOC];
    //    NSMutableArray *array = [NSMutableArray arrayWithObjects:@65,@34,@56,@78,@89,@332,@123, nil];
    //    [self quickSortingWithArray:array firstIndex:0 lastIndex:[array count] - 1];
    //    NSLog(@"快排结果: %@",array);
    //    [self flashBackFindString];
    [self insertNumber];
}

#pragma mark - C实现冒泡排序升序和降序
- (void)bubbleSortAscendingAndDescendingForC {
    
    //*********** 冒泡降序排序 **********//
    int array[11] =  {12,34,4546,667,78,9,90,233,121,2443,545};
    int numbers = sizeof(array)/sizeof(int);
    for (int i = 0; i < numbers - 1; i++) {
        for (int j = 0; j < numbers - 1 - i; j++) {
            if (array[j] < array[j + 1]) {
                int tap = array[j];
                array[j] = array[j + 1];
                array[j + 1] = tap;
            }
        }
    }
    
    for (int i = 0; i < numbers; i++) {
        printf("%d\t\n", array[i]);
    }
    
    printf("-----分割线-----\n");
    
    //*********** 冒泡升序排序 **********//
    for (int i = 0; i < numbers - 1; i++) {
        for (int j = 0; j < numbers - 1 - i; j++) {
            if (array[j] > array[j + 1]) {
                int tamp = array[j];
                array[j] = array[j + 1];
                array[j + 1] = tamp;
            }
        }
    }
    
    for (int i = 0; i < numbers; i++) {
        printf("升序: %d\t\n", array[i]);
    }
}


#pragma mark - OC实现冒泡排序升序和降序
- (void)bubbleSortAscendingAndDescendingForOC {
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@12,@23243,@43546,@3435,@345678,@1235,@324,@3454678,@12, nil]; //必须使用可变数组,
    for (int i = 0; i < array.count; i++) {
        for (int j = 0; j < array.count - 1 - i; j++) {
            NSInteger ascendingIndex = [array[j] integerValue];
            if ([array[j] integerValue] < [array[j + 1] integerValue]) {
                array[j] = array[j + 1];
                array[j + 1] = [NSNumber numberWithInteger:ascendingIndex];
            }
        }
    }
    
    NSLog(@"降序: %@",array);
    
    //*********** 冒泡升序排序 **********//
    for (int i = 0; i < array.count; i++) {
        for (int j = 0; j < array.count - 1 - i; j++) {
            NSInteger descendingIndex = [array[j] integerValue];
            if ([array[j] integerValue] > [array[j + 1] integerValue]) {
                array[j] = array[j + 1];
                array[j + 1] = [NSNumber numberWithInteger:descendingIndex];
            }
        }
    }
    NSLog(@"升序: %@",array);
    
}

#pragma mark - 选择排序
- (void)SelectionSortingForOC {
    //*********** 选择排序升序排序 **********//
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@12,@23243,@43546,@3435,@345678,@1235,@324,@3454678,@12, nil]; //必须使用可变数组, 不可变数组在循环内无法修改
    for (int i = 0; i < array.count; i++) {
        for (int j = i + 1; j < array.count; j++) {
            if ([array[i] integerValue] > [array[j] integerValue]) {
                NSInteger tamp = [array[i] integerValue];
                array[i] = array[j];
                array[j] = [NSNumber numberWithInteger:tamp];
            }
        }
    }
    NSLog(@"升序: %@",array);
    
    //*********** 选择排序降序排序 **********//
    for (int i = 0; i < array.count; i++) {
        for (int j = i + 1; j < array.count; j++) {
            if ([array[i] integerValue] < [array[j] integerValue]) {
                NSInteger tamp1 = [array[j] integerValue];
                array[j] = array[i];
                array[i] = [NSNumber numberWithInteger:tamp1];
            }
        }
    }
    NSLog(@"降序: %@",array);
}

#pragma mark - 插入排序
- (void)insertionAscendingSortingAscendingAndDescendingForOC {
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@12,@23243,@43546,@3435,@345678,@1235,@324,@3454678,@12, nil]; //必须使用可变数组,
    
    //*********** 插入排序升序排序 **********//
    for (int i = 0; i < array.count; i++) {
        NSInteger tamp = [array[i] integerValue];
        for (int j = i - 1; j >= 0 && tamp < [array[j] integerValue] ; j--) {
            array[j + 1] = array[j];
            array[j] = [NSNumber numberWithInteger:tamp];
        }
    }
    NSLog(@"升序：%@",array);
    
    //*********** 插入排序降序排序 **********//
    for (int i = 0; i < array.count; i++) {
        NSInteger tamp1 = [array[i] integerValue];
        for (int j = i - 1; j >= 0 && tamp1 > [array[j] integerValue]; j--) {
            array[j + 1] = array[j];
            array[j] = [NSNumber numberWithInteger:tamp1];
        }
    }
    NSLog(@"降序：%@",array);
}

#pragma mark - 二分查找
- (void)twoPointFindDataForOC {
    
    // 普通的查找方法
    NSArray *array = @[@"小明",@"小黄",@"小洋",@"小邓",@"小斌"];
    NSString *searchString = @"小黄";
    NSRange searchRange = NSMakeRange(0, [array count]);
    NSInteger findIndex = [array indexOfObject:searchString inRange:searchRange];
    NSLog(@"要查找的元素的下标: %ld",findIndex);
    
    //二分查找
    NSInteger index = [self binarySearch:array target:@"小黄"];
    NSLog(@"要查找的元素的下标----: %ld", index);
    
    NSLog(@"要查找的数字的下标----: %ld", [self binarySearchInt:@[@12,@343,@1213,@2345,@6678,@6768] findNumber:@(6768)]);
}
// 二分查找字符串
- (NSInteger)binarySearch:(NSArray *)array target:(id)key {
    NSInteger left = 0;
    NSInteger right = [array count] - 1;
    NSInteger middle = [array count] / 2;
    while (right >= left) {
        middle = (right + left) / 2;
        if (array[middle] == key) {
            return middle;
        }
        if (array[middle] > key) {
            right = middle - 1;
        }else if (array[middle] < key) {
            left = middle + 1;
        }
    }
    return -1;
}
// 二分查找数字
- (NSInteger)binarySearchInt:(NSArray *)intArray findNumber:(id)number {
    NSInteger first = 0;
    NSInteger last = intArray.count - 1;
    NSInteger middle = intArray.count / 2;
    while (last >= first) {
        middle = (first + last) / 2;
        if (intArray[middle] == number) {
            return middle;
        }
        if (intArray[middle] > number) {
            last = middle - 1;
        }else if (intArray[middle] < number) {
            first = middle + 1;
        }
    }
    return -1;
}

#pragma mark - 快速排序
- (void)quickSortingWithArray:(NSMutableArray *)array firstIndex:(NSInteger)firstIndex lastIndex:(NSInteger)lastIndex {
    if (firstIndex >= lastIndex) {//如果数组长度为0或1时返回
        return ;
    }
    NSInteger i = firstIndex;
    NSInteger j = lastIndex;
    NSInteger key = [array[i] integerValue];
    
    while (i < j) {
        while (i < j && [array[j] integerValue] >= key) {
            j--;
        }
        array[i] = array[j];
        while (i < j && [array[i] integerValue] <= key) {
            i++;
        }
        array[j] = array[i];
    }
    array[i] = @(key);
    [self quickSortingWithArray:array firstIndex:firstIndex lastIndex:i - 1];
    [self quickSortingWithArray:array firstIndex:i + 1 lastIndex:lastIndex];
}


#pragma mark - 倒序遍历
// 从一个字符串数组中找出含有 adc 的元素删除
- (void)flashBackFindString {
    
    NSMutableArray *array = [NSMutableArray arrayWithObjects:@"abc",@"shi",@"eryueabc",@"shdsia6cb",@"abcgyydye",@"chjcbca",@"abcjjuoiojk",nil];
    for (NSInteger i = array.count - 1; i >= 0; i--) {
        NSString *string = array[i];
        if ([string rangeOfString:@"abc"].location != NSNotFound) {
            [array removeObjectAtIndex:i];
        }
    }
    NSLog(@"删除后的数组是: %@", array);
    
}

#pragma mark - 在一个排好序的数组中插入一个数字到合适的位置

- (void)insertNumber {
    
    NSMutableArray *mutableArray = [NSMutableArray arrayWithObjects:@1,@5,@3,@38,@36,@31,@37,nil];
    
    //1. 用冒泡先排好序
    for (int i = 0; i < mutableArray.count - 1; i++) {
        //外层for循环控制循环次数
        for (int j = 0; j < mutableArray.count - 1 - i; j++) {
            //内层for循环控制交换次数
            if ([mutableArray[j] integerValue] > [mutableArray[j + 1] integerValue]) {
                [mutableArray exchangeObjectAtIndex:j withObjectAtIndex:j + 1];
            }
        }
    }
    NSLog(@" 排好序的数组 : %@",mutableArray);
    NSArray *array = [self insetNumber:30 Array:mutableArray first:0 last:mutableArray.count - 1];
    NSLog(@" 插入后的数组 : %@",array);
}

- (NSArray *)insetNumber:(NSInteger)number Array:(NSMutableArray *)array first:(NSInteger)first last:(NSInteger)last {
    if ([array[first] integerValue] > number) {
        [array insertObject:@(number) atIndex:first];
    }else if([array[last] integerValue] < number) {
        [array insertObject:@(number) atIndex:last + 1];
    }else {
        NSInteger middle;
        while (last >= first) {
            middle = (first + last) / 2;
            if ( [array[middle] integerValue]<number && [array[middle +1] integerValue] > number) {
                [array insertObject:@(number) atIndex:middle+1];
                return array;
            }else if ([array[middle] integerValue] == number){
                [array insertObject:@(number) atIndex:middle+1];
                return array;
            }
            if ([array[middle] integerValue] > number) {
                last = middle - 1;
            } else {
                first = middle + 1;
            }
        }
    }
    return array;
}

@end


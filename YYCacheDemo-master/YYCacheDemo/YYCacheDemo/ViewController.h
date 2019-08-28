//
//  ViewController.h
//  YYCacheDemo
//
//  Created by LiJie on 2018/8/8.
//  Copyright © 2018年 LiJieView. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 
 1.  NS_ASSUME_NONNULL_BEGIN
 Foundation供了一对宏NS_ASSUME_NONNULL_BEGIN、NS_ASSUME_NONNULL_END，包在里面的对象默认加 nonnull 修饰符，如果是nullable的,只需要把 nullable 的指出来就行
 
 2.  command+鼠标左键UNAVAILABLE_ATTRIBUTE，
 发现宏定义#define UNAVAILABLE_ATTRIBUTE __attribute__((unavailable)),
 __attribute__是Clang提供的一种源码注解，方便开发者向编译器表达某种要求,括号里是传达某种命令.
 为方便使用，一些常用属性也被Cocoa定义成宏,
 比如UNAVAILABLE_ATTRIBUTE、NS_CLASS_AVAILABLE_IOS(9_0).
 unavailable告诉编译器该方法失效.
 在封装单例或初始化某个类前必须做一些事时,对一些方法禁用是非常不错的选择.
 */

NS_ASSUME_NONNULL_BEGIN

@interface ViewController : UIViewController

@property (nonatomic, strong)NSString *name; // name 不可空

- (nullable NSArray *)textNullable; //用 nullable 指出可空

- (void)setupUI UNAVAILABLE_ATTRIBUTE;  // 表示此方法已经禁用, 如果再调用就会报错,在AppDelegate.m中有测试调用

- (void)setupUIText __attribute__((unavailable("此方法不可用"))); //等同于上面方法,只是加了注释

@end
NS_ASSUME_NONNULL_END

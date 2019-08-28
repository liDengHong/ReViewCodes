//
//  ViewController.m
//  strong & copy
//
//  Created by LiJie on 2018/3/12.
//  Copyright © 2018年 LiJie. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong)NSString *string1;
@property (nonatomic, copy)NSString *string2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    //定义可变字符串
    NSMutableString *mutableString = [NSMutableString stringWithFormat:@"Lijie"];

    //赋值给属性字符串
    self.string1 = mutableString;
    self.string2 = mutableString;

    //在赋值完成后修改原来的可变字符串, 观察string1,string2 的变化;
    [mutableString setString:@"程序员"];

    NSLog(@"mutableString 指针--->%p, 值---->%@",mutableString,mutableString);
    NSLog(@"string1 指针--->%p, 值---->%@",self.string1,self.string1);
    NSLog(@"string2 指针--->%p, 值---->%@",self.string2,self.string2);


//    NSMutableString *mutableString = [NSMutableString stringWithFormat:@"Lijie"];
//
//    //赋值给属性字符串
//    _string1 = mutableString;
//    _string2 = mutableString;
//
//    //在赋值完成后修改原来的可变字符串, 观察string1,string2 的变化;
//    [mutableString setString:@"程序员"];
//
//    NSLog(@"mutableString 指针--->%p, 值---->%@",mutableString,mutableString);
//    NSLog(@"string1 指针--->%p, 值---->%@",_string1,_string1);
//    NSLog(@"string2 指针--->%p, 值---->%@",_string2,_string2);
    /**
     log结果:
     2018-03-12 10:18:50.608993+0800 strong & copy[1328:53444] mutableString 指针--->0x60400025f320, 值---->程序员
     2018-03-12 10:18:50.609728+0800 strong & copy[1328:53444] string1 指针--->0x60400025f320, 值---->程序员
     2018-03-12 10:18:50.610514+0800 strong & copy[1328:53444] string2 指针--->0xa000065696a694c5, 值---->Lijie
    
    /**
     小结 : 从 log 结果
     1. 看出把一个可变字符串赋值给 strong 修饰的 NSString 字符串, 在赋值后改变可变字符串的值, 该字符串也编程赋值后的可变字符串的值,不会开辟新的内存空间, 也就是引用计数 +1. 而使用 Copy 的字符串在赋值后值没发生改变内存地址却发生了改变, 也就是开辟了新的内存空间, 是复制了值后放到一个新的内存中去, 所以在改变可变字符串的值后他的值不会变.
     
     2. 如果使用_xxx调用, 无论使用 strong 还是 copy 都会使用最新的值, 因为_ xxx 是对局部变量进行操作不存在引用计数的加减
    
     */
    
    
    /**
     self.和下划线的区别:
     1.首先通过self.xxx 通过访问的方法的引用：包含了set和get方法。而通过下划线是获取自己的实例变量，不包含set和get的方法。
     
         2.self.xxx是对属性的访问；而_xxx是对局部变量的访问。所有被声明为属性的成员，再ios5之前需要使用编译指令@synthesize 来告诉编译器帮助生成属性的getter和setter方法，之后这个指令可以不用认为的指定了，默认情况下编译器会帮助我们生成。编译器在生成getter，setter方法时是有优先级的，他首先查找当前的类中用户是否定义属性的getter，setter方法，如果有，则编译器会跳过，不会再生成，使用用户定义的方法。也就是说你在使用self.xxx时是调用一个getter方法。会使引用计数加一，而_xxx不会使用引用技术加一的。
     
         所有使用self.xxx是更好的选择，因为这样可以兼容懒加载，同时也避免了使用下滑线的时候忽略了self这个指针，后者容易在BLock中造成循环引用。同时，使用 _是获取不到父类的属性，因为它只是对局部变量的访问。
     
     最后总结：self方法实际上是用了get和set方法间接调用，下划线方法是直接对变量操作。
     */
}


@end

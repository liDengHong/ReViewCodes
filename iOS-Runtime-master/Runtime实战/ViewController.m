//
//  ViewController.m
//  Runtime实战
//
//  Created by 小哥 on 2017/1/18.
//  Copyright © 2017年 小哥. All rights reserved.
//

#import "ViewController.h"
#import "People.h"
#import "Model.h"
#import "Bird.h"
#import "People+Associated.h"
#if TARGET_IPHONE_SIMULATOR
#import <objc/objc-runtime.h>
#else
#import <objc/runtime.h>
#import <objc/message.h>
#endif


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    //动态创建类
//    [self dynamicallyCreateClass];
//    //获取属性.成员变量,
//    [self getClassIvarAndMethod];
//    //关联对象
//    [self relatedObject];
//    //字典转模型
//    [self dictionaryToModel];
//    //动态的解析方法
//    [self addMethod];
    [self replaceMethod];

}

#pragma mark - 使用 Runtime 动态创建类
- (void)dynamicallyCreateClass {
    // 动态创建对象 创建一个Person 继承自 NSObject类
    Class People = objc_allocateClassPair([NSObject class], "People", 0);
    
    //为类动态的添加属性
    class_addIvar(People, "_name", sizeof(NSString *), log2(sizeof(NSString *)), @encode(NSString *));
    
    class_addIvar(People, "_age", sizeof(NSString *), log2(sizeof(NSString *)), @encode(NSString *));
    
    //注册方法名为 say 的方法
    SEL sel = sel_registerName("say:");
    
    //为该类添加方法名为 say 的方法
    class_addMethod(People, sel, (IMP)sayFunctions, "v@:@");
    
    //注册该类
    objc_registerClassPair(People);
    
    //创建 people 类的实例
    id peopleInstance = [[People alloc] init];
    
    //KVC 修改 People 类中的属性
    [peopleInstance setValue:@"苍老师" forKey:@"name"];
    
    NSLog(@"%@",[peopleInstance valueForKey:@"name"]);
    
    //拿到_ age 属性
    Ivar ageIvar = class_getInstanceVariable(People, "_age");
    
    //为_age 属性赋值
    object_setIvar(peopleInstance, ageIvar, @18);
    
    // 调用 peopleInstance 对象中的 s 方法选择器对于的方法
    // objc_msgSend(peopleInstance, s, @"大家好!"); // 这样写也可以，请看我博客说明
    ((void (*)(id,SEL,id)) objc_msgSend)(peopleInstance ,sel,@"大家好,我是你们喜爱的苍老师");
    peopleInstance = nil; //当People类或者它的子类的实例还存在，则不能调用objc_disposeClassPair这个方法；因此这里要先销毁实例对象后才能销毁类；
    
    // 销毁类
    objc_disposeClassPair(People);
}

#pragma mark - 使用 Runtime 创建的方法
// 自定义一个方法
void sayFunctions(id self,SEL _cmd,id some) {
    NSLog(@"%@岁的%@说:  %@,",object_getIvar(self, class_getInstanceVariable([self class], "_age")),[self valueForKey:@"name"],some);
}

#pragma mark - 获取类的属性,方法和成员变量
- (void)getClassIvarAndMethod {
    
    People *cangTeacher = [[People alloc] init];
    cangTeacher.name = @"苍井空";
    cangTeacher.age = 18;
    [cangTeacher setValue:@"老师" forKey:@"occupation"];
    
    NSDictionary *propertyResultDic = [cangTeacher allProperties];
    for (NSString *propertyName in propertyResultDic.allKeys) {
        NSLog(@"propertyName:%@, propertyValue:%@",propertyName, propertyResultDic[propertyName]);
    }
    
    NSDictionary *ivarResultDic = [cangTeacher allIvars];
    for (NSString *ivarName in ivarResultDic.allKeys) {
        NSLog(@"ivarName:%@, ivarValue:%@",ivarName, ivarResultDic[ivarName]);
    }
    
    NSDictionary *methodResultDic = [cangTeacher allMethods];
    for (NSString *methodName in methodResultDic.allKeys) {
        NSLog(@"methodName:%@, argumentsCount:%@", methodName, methodResultDic[methodName]);
    }
    
}

#pragma mark - 关联对象
- (void)relatedObject {
    People *people = [[People alloc] init];
    people.name = @"流氓";
    people.age = 20;
    people.associatedBust = @36;
    [people setValue:@"老师" forKey:@"occupation"];
    
    //block 内容
    people.callBack = ^ (){
        NSLog(@"流氓老师耍流氓了");
    };
    
    //执行 block
    people.callBack();
    
    NSDictionary *propertyResultDic = [people allProperties];
    for (NSString *propertyName in propertyResultDic.allKeys) {
        NSLog(@"propertyName:%@, propertyValue:%@",propertyName, propertyResultDic[propertyName]);
    }
    
    NSDictionary *methodResultDic = [people allMethods];
    for (NSString *methodName in methodResultDic.allKeys) {
        NSLog(@"methodName:%@, argumentsCount:%@", methodName, methodResultDic[methodName]);
    }
}

#pragma mark - 字典转模型
- (void)dictionaryToModel {
    NSDictionary *dict = @{
                           @"name" : @"苍井空",
                           @"age"  : @18,
                           @"occupation" : @"老师",
                           };
    
    // 字典转模型
     Model*model = [[Model alloc] initWithDictionary:dict];
    NSLog(@"%@岁的%@%@",model.age,model.name,model.occupation);
    
    // 模型转字典
    NSDictionary *ModelDict = [model modelToDict];
    NSLog(@"%@",ModelDict);

}

#pragma mark - 动态添加方法的实现
- (void)addMethod {
    People *people = [[People alloc] init];
    people.name = @"捷哥哥";
    [people peopleIsSinging];

}

#pragma mark - 替换方法
- (void)replaceMethod {
    Bird *bird = [[Bird alloc] init];
    bird.name = @"小小鸟";
    ((void (*)(id, SEL))objc_msgSend)((id)bird, @selector(peopleIsSinging));

}


@end

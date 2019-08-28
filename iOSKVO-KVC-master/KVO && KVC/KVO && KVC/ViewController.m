//
//  ViewController.m
//  KVO && KVC
//
//  Created by LiJie on 2018/3/15.
//  Copyright © 2018年 LiJie. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"

@interface ViewController ()

@property (nonatomic, strong)Person *person;
@property (nonatomic, assign)NSInteger index;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.person = [[Person alloc] init];
    
    /**
     1. 对一个对象的多个属性进行监测, 最直接的方法就是添加多个观察者方法,在观察结束时根据 keyPath 判断处理
     2.如果只想在特定的情况下监听, 则 在被监听对象里实现 + (BOOL)automaticallyNotifiesObserversForKey 方法, return NO. 取消自动监听. 在特定情况的判断方法里面实现 - (void)willChangeValueForKey:(NSString *)key 和 - (void)didChangeValueForKey:(NSString *)key方法.
     3.在 KVO 中访问对象属性中的属性keyPath 直接用点语法, 例如: food.kind   是属性之间的依赖.
     4.KVO监听的是 setter 方法, 监听属性的容器类属性血药结合 KVC,
     */
    
    //添加 KVO 观察者
//    [self.person addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
//    _index = 1;
//
//    //监听对象属性中的对象
//    [self.person addObserver:self forKeyPath:@"food.kind" options:NSKeyValueObservingOptionNew context:nil];
//
//    [self.person addObserver:self forKeyPath:@"array" options:NSKeyValueObservingOptionNew context:nil];
    
    [self.person addObserver:self forKeyPath:@"food" options:NSKeyValueObservingOptionNew context:nil];
//    
}

// 监测被观察者的属性变化
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"name"]) {
        NSLog(@"nameChange : %@",change);
    }else if([keyPath isEqualToString:@"food.kind"]){
        NSLog(@"foodChange: %@",change);
    }else {
        NSLog(@"aarrayChange : %@",change);
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _index ++;
//    self.person.name = [NSString stringWithFormat:@"xiaohuang%ld",(long)self.index];
    self.person.food.kind = [NSString stringWithFormat:@"kind%ld",self.index];
    self.person.food.foodName = [NSString stringWithFormat:@"foodName%ld",self.index];
    
    //此处不能监听到, 此处的 addObject 并不是 array 的 setter 方法, KVO 监听的是属性的 setter 方法. 所以无法观察到.,
//    [self.person.array addObject:@(self.index)];
    
    //特定条件才监听
//    if (_index == 10) {
//        [self.person willChangeValueForKey:@"name"]; //即将开始监听
//        [self.person didChangeValueForKey:@"name"];  //结束监听
//    }
    
    [self.view setNeedsLayout];  //添加标记
    [self.view layoutIfNeeded];  //如果对象调用了 setNeedsLayout 就调用 layoutIfNeeded 进行布局, setNeedsLayout 不参与 UI 交互, 只是做标记.
}


@end

//
//  ViewController.m
//  iOS 消息转发机制
//
//  Created by LiJie on 2018/3/12.
//  Copyright © 2018年 LiJie. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "People.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self viewAddButton];
    People *people = [[People alloc] init];
//    [people performSelector:@selector(eat)];
//    [people performSelector:@selector(run)];
//    [people performSelector:@selector(climbTree)];
    
    //此方法在消息转发四步骤里面也无法找到.
    [people performSelector:@selector(singing)];
    
}

#pragma mark - button测试
- (void)viewAddButton {
    
    /**
      1.如果 buttonClick 方法没有实现的话点击按钮程序就会崩溃 报错 "-[ViewController buttonClick]: unrecognized selector sent to instance 0x7fcb76e10220" 无法找到该方法
"
     */
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    button.backgroundColor = [UIColor blueColor];
    [self.view addSubview:button];
    button.center = self.view.center;
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
}

//- (void)buttonClick {
//
//}

void buttonClickDidNoFindMethed(id self, SEL _cmd){
    NSLog(@"找不到buttonClick这个方法,所以buttonClickDidNoFindMethed代替");
}

#pragma mark - 实现此方法
+ (BOOL)resolveInstanceMethod:(SEL)sel {
    // 使用场景, 例如在 OC 与 JS 交互的时候, 如果 JS 与 OC 商定的方法中 JS 方法名与 OC 方法不一样的时候,可以防止程序奔溃.
    if (sel == @selector(buttonClick)) {
        // 为了防止找不到此方法,可以把在本对象中添加一个函数去替代buttonClick方法. 必须是函数.
        class_addMethod([self class], sel, (IMP)buttonClickDidNoFindMethed, "V@:");
        //执行完上面的代码就不会往下执行, 所以不会再去父类去查找方法,提前结束消息转发
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

@end

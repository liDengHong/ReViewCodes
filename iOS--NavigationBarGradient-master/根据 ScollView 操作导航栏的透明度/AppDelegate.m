//
//  AppDelegate.m
//  根据 ScollView 操作导航栏的透明度
//
//  Created by LiJie on 2017/4/11.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
    
}

/**<
 
 实现方式两种:
 
 1. 创建一个继承与 UIViewController 的类,  在此类中做逻辑处理, 其他需要操作导航栏的透明度的 ViewController 继承这个类.
 2. 创建 UIViewController 的分类, 在分类中做逻辑处理, 在其他需要调整导航栏透明度的 ViewController 中实现分类的方法接口.
 
 实现思路:
 
 1. 考虑是否在导航栏隐藏的时候隐藏导航栏上的文字, 导航栏上的文字包括 left, right, title
 2. 隐藏导航栏是依赖于 ScrollView 的 offset.y, 所以确定是哪个 ScrollView.
 3. 清楚 navigationBar 的组成部分, 添加导航栏的背景图片
 4. 使用 KVO 监听 offset 的变化.
 5. 记得 delloc 方法中 removeObserver.
 
 >**/

/**< 
 demo 实现中遇到以下两个问题 :
 1. 在 此 demo 中用到了两种实现导航栏渐变效果的方法, "UIViewController+LJNavHidden"分类中的一些方法和 "LJNavBarViewController" 基控制器的一些方法会有冲突, 例如: delloc 方法, 所以这个写 demo时,如果在一个项目中这两种方法都存在的话, 最好不要有 push pop  present dismiss 操作. 会有调用已 release 对象的错误.
 
 2. #warning 此处如果不加延迟 setNavBarSubViewAlpha 不会被调用
 
 >**/


@end

//
//  LJTestTableViewController.m
//  根据 ScollView 操作导航栏的透明度
//
//  Created by LiJie on 2017/4/11.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "LJTestTableViewController.h"

static  NSString *cellID = @"cell";
@interface LJTestTableViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *tableView;

@end

@implementation LJTestTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor redColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellID];
    [self setScrollView:_tableView scrollViewOffsetY:500 options:LJNavBarHiddenOptionsLeftItem|LJNavBarHiddenOptionsTitleItem];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectZero];
    lable.text = @"我是 tableView";
    [lable sizeToFit];
    lable.textColor = [UIColor greenColor];
    self.navigationItem.titleView = lable;
    
    
    [self.view addSubview:_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.textLabel.text = @"点我是没用的 😁😁😁";
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.navigationController popViewControllerAnimated:YES];
    exit(0);
}


@end

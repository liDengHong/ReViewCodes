//
//  TableViewController.m
//  TbleViewlinkage
//
//  Created by LiJie on 2018/4/9.
//  Copyright © 2018年 LiJie. All rights reserved.
//

#import "TableViewController.h"
#import "LeftTableViewCell.h"
#import "RightTableViewCell.h"

static float kLeftTableViewWidth = 80.f;
static NSString *leftTableViewCell = @"leftTableViewCell";
static NSString *rightTableViewCell = @"rightTableViewCell";

@interface TableViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong)UITableView *leftTableView;
@property (nonatomic, strong)UITableView *rightTableView;


@end

@implementation TableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor blueColor];

    [self.view addSubview:self.leftTableView];
    [self.view addSubview:self.rightTableView];
    
}


- (UITableView *)leftTableView
{
    if (!_leftTableView)
    {
        _leftTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kLeftTableViewWidth, [UIScreen mainScreen].bounds.size.height)];
        _leftTableView.delegate = self;
        _leftTableView.dataSource = self;
        _leftTableView.rowHeight = 55;
        [_leftTableView registerClass:[LeftTableViewCell class] forCellReuseIdentifier:leftTableViewCell];
    }
    return _leftTableView;
}

- (UITableView *)rightTableView
{
    if (!_rightTableView)
    {
        _rightTableView = [[UITableView alloc] initWithFrame:CGRectMake(kLeftTableViewWidth, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
        _rightTableView.delegate = self;
        _rightTableView.dataSource = self;
        _rightTableView.rowHeight = 80;
        [_rightTableView registerClass:[RightTableViewCell class] forCellReuseIdentifier:rightTableViewCell];
    }
    return _rightTableView;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 80;
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//}

@end


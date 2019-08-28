//
//  ViewController.m
//  FMDBDemo
//
//  Created by LiJie on 2018/5/9.
//  Copyright © 2018年 LiJie. All rights reserved.
//

#import "ViewController.h"
#import "FMDBManage.h"
#import "PersonModel.h"
#import "CarController.h"
#import "PersonController.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addData)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"车库" style:UIBarButtonItemStylePlain target:self action:@selector(watchCars)];
    
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - buttonAction
- (void)watchCars {
    CarController *carViewController = [[CarController alloc] init];
    [self.navigationController pushViewController:carViewController animated:YES];
}

- (void)addData {
    int nameRandom = arc4random_uniform(1000);
    NSInteger ageRandom  = arc4random_uniform(80) + 1;
    NSInteger numberRandom  = arc4random_uniform(200) + 1;
    NSString *name = [NSString stringWithFormat:@"person_%d号",nameRandom];
    NSInteger age = ageRandom;
    
    PersonModel *model = [[PersonModel alloc] init];
    model.age = age;
    model.number = numberRandom;
    model.name = name;
    
    [[FMDBManage shareManager] addPersonWithPerson:model];
    [self.dataArray addObject:model];
    
    [self.tableView beginUpdates];
    NSIndexPath *indexPathOfNewItem = [NSIndexPath indexPathForItem:_dataArray.count - 1  inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPathOfNewItem] withRowAnimation:UITableViewRowAnimationLeft];
    [self.tableView endUpdates];
    [self.tableView scrollToRowAtIndexPath:indexPathOfNewItem atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 40;
    }
    return _tableView;
}

-(NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[FMDBManage shareManager] getAllPerson];
    }
    return _dataArray;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PersonModel *model = self.dataArray[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = model.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"age:%ld, number:%ld",(long)model.age,(long)model.number];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    PersonModel *model = self.dataArray[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[FMDBManage shareManager] deletePersonWithPerson:model];
        [[FMDBManage shareManager] deleteAllCarFromPerson:model];
        [self.tableView beginUpdates];
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView endUpdates];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PersonModel *model = self.dataArray[indexPath.row];
    PersonController *personViewController = [[PersonController alloc] initWithPersonModel:model];
    [self.navigationController pushViewController:personViewController animated:YES];
}

@end

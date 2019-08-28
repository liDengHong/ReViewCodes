//
//  PersonController.m
//  FMDBDemo
//
//  Created by LiJie on 2018/8/8.
//  Copyright © 2018年 LiJie. All rights reserved.
//

#import "PersonController.h"
#import "FMDBManage.h"
#import "CarModel.h"
#import "PersonModel.h"

@interface PersonController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong)PersonModel *personModel;

@end

@implementation PersonController

- (instancetype)initWithPersonModel:(PersonModel *)personModel
{
    self = [super init];
    if (self) {
        _personModel = personModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = _personModel.name;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addData)];
    [self.view addSubview:self.tableView];
    self.tableView.tableFooterView = [UIView new];
}

#pragma mark - buttonAction
- (void)addData {
    NSArray *carNameArray = @[@"奔驰",@"宾利",@"路虎",@"保时捷",@"迈巴赫",@"凯迪拉克",@"沃尔沃",@"奥迪",@"宝马"];
    NSInteger index = arc4random_uniform((int)carNameArray.count);
    CarModel *model = [[CarModel alloc] init];
    model.ownId = _personModel.ID;
    model.brand = carNameArray[index];
    model.price = arc4random_uniform(1000000000);
    [[FMDBManage shareManager] addCar:model toPerson:_personModel];
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
        _dataArray = [[FMDBManage shareManager] getAllCarFromPerson:_personModel];
    }
    return _dataArray;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CarModel *model = self.dataArray[indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = model.brand;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"price: ¥%ld元",(long)model.price];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    CarModel *model = self.dataArray[indexPath.row];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[FMDBManage shareManager] deleteCar:model fromPerson:_personModel];
        [self.tableView beginUpdates];
        [self.dataArray removeObjectAtIndex:indexPath.row];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
        [self.tableView endUpdates];
    }
}

@end

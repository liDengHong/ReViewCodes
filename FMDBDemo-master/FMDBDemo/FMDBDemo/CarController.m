//
//  CarController.m
//  FMDBDemo
//
//  Created by LiJie on 2018/8/8.
//  Copyright © 2018年 LiJie. All rights reserved.
//

#import "CarController.h"
#import "PersonModel.h"
#import "CarModel.h"
#import "FMDBManage.h"

@interface CarController ()

@property(nonatomic,strong) NSMutableArray *dataArray;
@property(nonatomic,strong) NSMutableArray *carArray;

@end

@implementation CarController

- (instancetype)init
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        _dataArray = [NSMutableArray array];
        _carArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"车库";
    
    self.dataArray = [[FMDBManage shareManager] getAllPerson];
    for (PersonModel *model in self.dataArray) {
        NSArray *carArray = [[FMDBManage shareManager] getAllCarFromPerson:model];
        [self.carArray addObject:carArray];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *carArray = self.carArray[section];
    return carArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"carcell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"carcell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    NSMutableArray *carArray = self.carArray[indexPath.section];
    CarModel *carModel = carArray[indexPath.row];
    cell.textLabel.text = carModel.brand;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"price: ¥% ld",carModel.price];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *label =  [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
    PersonModel *person = self.dataArray[section];
    label.text = [NSString stringWithFormat:@"%@ 的车",person.name];
    label.font = [UIFont systemFontOfSize:13];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor grayColor];
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.00001;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 35;
}


@end
